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
	
**************************************************************** End of do-file!

