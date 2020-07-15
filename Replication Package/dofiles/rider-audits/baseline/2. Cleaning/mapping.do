/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 			  	 	Clean baseline platform observations			 		   *
********************************************************************************

	* REQUIRES:		${encrypt}/Baseline/07112016/Mapping 07112016
					${encrypt}/Baseline/mapping_task_key
					${doc_rider}/baseline-study/codebooks/mapping.xlsx
					${doc_rider}/baseline-study/codebooks/mapping_long.xlsx
																			
	* CREATES:	 	${dt_int}/baseline_mapping.dta
					${dt_int}/baseline_mapping_long.dta
				  
	* WRITEN BY:  	Luiza Andrade [lcardoso@worldbank.org]

********************************************************************************
*	Clean mapping data (requires access to identified data)
********************************************************************************/
	
	if ${encrypted} {
	
		import 	delimited using "${encrypt}/Baseline/07112016/Mapping 07112016", ///
				delim (",") ///
				varnames(1) ///
				clear

		* Date of obsevation 
		* ------------------
		split 		created_at, p("")
		split 		created_at1, p("-")
		destring 	created_at11 created_at12 created_at13, replace
		split 		created_at2, p(":")
				
		gen double 	MA_date = mdy(created_at12, created_at13, created_at11)
		format 		MA_date 	%td
		
		* Categorical variables for congestion and compliance
		* ---------------------------------------------------
		foreach var in 	regular_car_compliance pink_car_compliance ///
						regular_car_congestion pink_car_congestion {
				
			encode `var', gen(`var'_)
			drop `var'
		}
								
		* Save tempfile to merge later
		* ----------------------------
		tempfile map
		save `map', replace
											
	*-------------------------------------------------------------------------------
	*	Prepare identifying variables
	* 	(The meaning of the item_uid variable was shared in a separate file, and
	*	 is necessary to merge mapping and ride observations)
	*-------------------------------------------------------------------------------

		* Load time and station bin identifiers
		* -------------------------------------
		import 	delimited using "${encrypt}/Baseline/mapping_task_key", ///
				delim (",")  ///
				varnames(1) ///
				clear
		
		
		* Clean identifying variables
		* ----------------------------
		split 	item_uid, p(":")
		replace item_uid = item_uid2	// To merge back to mapping observations
		
		* Station bin ---------------------------------
		* Recode from alphabetical order to line order
		* ---------------------------------------------
		encode  station_bin, gen(stationbin)
		recode 	stationbin  (1 = 8)  (2 = 19) (3 = 20)  (4 = 10)  (6 = 14)  (7 = 18) ///
							(8 = 1)  (9 = 15) (10 = 11) (11 = 21) (13 = 3)  (14 = 6) ///
							(15 = 4) (16 = 7) (17 = 16) (18 = 2)  (19 = 17)
		
		* Time bin
		encode 	timerestriction_id, gen(time_bin)

	*-------------------------------------------------------------------------------
	* 	Merge and save
	*-------------------------------------------------------------------------------
		
		merge 1:m item_uid using `map', assert(1 3) keep(3) nogen 					// 4 station bins were never observed at a few time bins, creating a total of 9 missing time-station bin combinations
		
		iecodebook apply using "${doc_rider}/baseline-study/codebooks/mapping.xlsx", drop
		
		save 			 "${dt_int}/baseline_mapping.dta", replace
		iemetasave using "${dt_int}/baseline_mapping.txt", replace
	}
	
********************************************************************************
*	Prepare to merge with rides
********************************************************************************/	
	
	use "${dt_int}/baseline_mapping.dta"

*-------------------------------------------------------------------------------
* 	Identifying variables
*	(These are the variables that we need to merge with ride data)
*-------------------------------------------------------------------------------

	* Correct line
	* ------------	
	gen 	CI_line = .
	replace CI_line = 1 if station_bin >= 1 & station_bin <= 4
	replace CI_line = 2 if station_bin >= 5 & station_bin <= 9
	replace CI_line = 3 if station_bin >= 10 & station_bin <= 13
	replace CI_line = 4 if station_bin >= 14 & station_bin <= 17
	replace CI_line = 5 if station_bin >= 18 & station_bin <= 22

	* Create unique time and station bin identifier
	* ---------------------------------------------
	gen 	time_station_bin = station_bin * 1000 + time_bin
	gen 	stage = 0
		
*-------------------------------------------------------------------------------
* 	Collapse observations
*	(Because we have multiple observations for each time and station bin,
*	 we need to aggregate them)
*-------------------------------------------------------------------------------
	
	* Continuous version of compliance variables -------------------------------
	* (We need a granular version of this variable, so cannot just use the median.
	*  We'll create a continuous version of it using the median value of the
	*  interval, so we can aggregate using the average)
	* --------------------------------------------------------------------------
	gen MA_men_present_pink = pink_car_compliance
	gen MA_men_present_mix  = regular_car_compliance
	
	foreach var in MA_men_present_pink MA_men_present_mix {
		replace `var' = 0.05 if `var' == 1
		replace `var' = 0.20 if `var' == 2
		replace `var' = 0.40 if `var' == 3
		replace `var' = 0.60 if `var' == 4
		replace `var' = 0.80 if `var' == 5
		replace `var' = 0.95 if `var' == 6
	}
					
	* Calculate mean compliance and median congestion
	* -----------------------------------------------
	collapse  	CI_line											    ///
				(mean) 	 MA_men_present_pink MA_men_present_mix   	/// 
				(median) MA_crowd_rate_mix = regular_car_congestion ///
						 MA_crowd_rate_pink = pink_car_congestion,  ///
				by		(station_bin time_bin)
	
	* Round median congestion so it's still a categorical variable
	* ------------------------------------------------------------
	foreach varAux in MA_crowd_rate_mix MA_crowd_rate_pink {
		replace `varAux' = round(`varAux')
	}
	
	isid station_bin time_bin
	
	iecodebook apply using "${doc_rider}/baseline-study/codebooks/mapping_long.xlsx"
			
	save 			 "${dt_int}/baseline_mapping_long.dta", replace
	iemetasave using "${dt_int}/baseline_mapping_long.txt", replace

**************************************************************** End of do-file!

