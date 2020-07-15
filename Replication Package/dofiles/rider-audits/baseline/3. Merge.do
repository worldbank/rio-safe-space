/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*	 						 Merge data sources			 					   *
********************************************************************************

		
	* REQUIRES:		${dt_int}/baseline_ci.dta
					${dt_int}/baseline_ride.dta
					${dt_int}/baseline_co.dta
					${dt_int}/baseline_demographic.dta
					${dt_int}/baseline_exit.dta
					${dt_int}/baseline_mapping_long.dta
					${doc_rider}/baseline-study/codebooks/merged.xlsx
																			
	* CREATES:		${dt_int}/baseline_merged.dta
										  
	* WRITEN BY:  	Luiza Andrade [lcardoso@worldbank.org]

********************************************************************************/

/*******************************************************************************
	Merge data sets
*******************************************************************************/

	* Ride tasks
	* ----------
	use 					"${dt_int}/baseline_ci.dta", clear
	merge 1:1 session using "${dt_int}/baseline_ride.dta", assert(3) nogen
	merge 1:1 session using "${dt_int}/baseline_co.dta", assert(3) nogen
	
	* Demographic survey
	* ------------------
	merge m:1 user_uuid using "${dt_int}/baseline_demographic.dta", gen(demo_merge)	// 551 riders completed demo survey
	
	* Merged users
	unique user_uuid if demo_merge == 3
	assert r(unique) == 309
	
	* No rides	
	unique user_uuid if demo_merge == 2
	assert r(unique) == 247
	drop if demo_merge == 2														// drop users with no ride data

	* No demo
	unique user_uuid if demo_merge == 1
	assert r(unique) == 197
	drop demo_merge
	
	gen 	flag_nodemovars = (user_age == .)
	
	* ----------------
	* Make corrections
	* ----------------
	
	preserve
	
		import delimited using "${doc_rider}/baseline-study/demo-data-corrections.csv", encoding(utf8) clear 
		
		tempfile demo_corr
		save	`demo_corr'

	restore
	
	merge m:1 user_uuid using `demo_corr', assert(1 3) nogen
	
	drop if drop_user == 1 														// drop users that are found to be fraudulent
	
	replace user_gender = user_gender_corr if !missing(user_gender_corr)

	isid 	session
	sort 	session
	order 	user_uuid session
	compress
	
	save 			 "${dt_int}/baseline_merged_rides.dta", replace
	iemetasave using "${dt_int}/baseline_merged_rides.txt", replace

/*******************************************************************************
	Prepare mapping to merge with rides
********************************************************************************/	
		
	use "${dt_int}/baseline_mapping.dta", clear

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
	recode 	pink_car_compliance 	(1 = .05)  ///
									(2 = .2)   ///
									(3 = .4)   ///
									(4 = .6)   ///
									(5 = .8)   ///
									(6 = .95), ///
			gen(MA_men_present_pink)
	
	recode 	regular_car_compliance 	(1 = .05)  ///
									(2 = .2)   ///
									(3 = .4)   ///
									(4 = .6)   ///
									(5 = .8)   ///
									(6 = .95), ///
			gen(MA_men_present_mix)

					
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

	
/*******************************************************************************
	Merge mapping and rides
********************************************************************************/	
	
	use "${dt_int}/baseline_merged_rides.dta", clear
	
	* Change time variable to Rio time
	* --------------------------------
	foreach task in CI RI {
	
		split	`task'_started, p(" ")
		gen 	`task'_date = clock(`task'_started1, "YMD")
		replace `task'_date = dofc(`task'_date)
		format 	`task'_date %td
	
		gen		`task'_time = clock(`task'_started2, "hms")
		
		gen 	`task'_hour = hh(`task'_time)				// zulu time
		replace `task'_hour = `task'_hour - 3			    // rio time
		replace `task'_hour = `task'_hour + 1 ///
								if 	`task'_date > 20378 & ///
									`task'_date < 20512	   // rio daylights saving time: 18 Oct - 21 Fev
		
		gen 	`task'_min 	= mm(`task'_time)
			
}
	
	* Generate time bins that allow us to merge with mapping data
	* -----------------------------------------------------------
	gen 	RI_time_bin = .
	replace RI_time_bin = 1	 if RI_hour == 6	& RI_min <= 30
	replace RI_time_bin = 2	 if RI_hour == 6	& RI_min >  30
	replace RI_time_bin = 3	 if RI_hour == 7	& RI_min <=	30
	replace RI_time_bin = 4	 if RI_hour == 7	& RI_min >  30
	replace RI_time_bin = 5	 if RI_hour == 8	& RI_min <=	30
	replace RI_time_bin = 6	 if RI_hour == 8	& RI_min >  30
	replace RI_time_bin = 6  if RI_hour == 9	& RI_min == 00
	replace RI_time_bin = 7	 if RI_hour == 17	& RI_min <=	30
	replace RI_time_bin = 8	 if RI_hour == 17	& RI_min >  30
	replace RI_time_bin = 9	 if RI_hour == 18	& RI_min <= 30
	replace RI_time_bin = 10 if RI_hour == 18	& RI_min >  30
	replace RI_time_bin = 11 if RI_hour == 19	& RI_min <=	30
	replace RI_time_bin = 12 if RI_hour == 19	& RI_min >  30
	replace RI_time_bin = 12 if RI_hour == 20	& RI_min == 00

	* Generate station bins that allow us to merge with mapping data
	* -----------------------------------------------------------
	gen 	station_bin = .
	replace station_bin = 1  if inlist(CI_station, 101,102,103,104,105)
	replace station_bin = 2  if inlist(CI_station, 106,107,108,109,110)
	replace station_bin = 3  if inlist(CI_station, 111,112,113,114,115)
	replace station_bin = 4  if inlist(CI_station, 116,117,118,119)
	replace station_bin = 5  if inlist(CI_station, 201,202,203,204,205)
	replace station_bin = 6  if inlist(CI_station, 207,208,209,210,211)
	replace station_bin = 7  if inlist(CI_station, 212,213,214,215,216)
	replace station_bin = 8  if inlist(CI_station, 217,218,219,220)
	replace station_bin = 9  if inlist(CI_station, 221,222,223,224)
	replace station_bin = 10 if inlist(CI_station, 301,302,303,304,305,306)
	replace station_bin = 11 if inlist(CI_station, 307,308,309,310,311)
	replace station_bin = 12 if inlist(CI_station, 312,313,314,315)
	replace station_bin = 13 if inlist(CI_station, 316,317,318,319,320)
	replace station_bin = 14 if inlist(CI_station, 401,402,403,404,405)
	replace station_bin = 15 if inlist(CI_station, 406,407,408,409,410)
	replace station_bin = 16 if inlist(CI_station, 411,412,413,414,415)
	replace station_bin = 17 if inlist(CI_station, 416,417,418,419)
	replace station_bin = 18 if inlist(CI_station, 501,502,503,504,505)
	replace station_bin = 19 if inlist(CI_station, 506,507,508,509,510)
	replace station_bin = 20 if inlist(CI_station, 511,512,513,514)
	replace station_bin = 21 if inlist(CI_station, 515,516,517)
	replace station_bin = 22 if inlist(CI_station, 518,519,520)
	
	* Now merge
	* ---------
	merge m:1 	station_bin RI_time_bin ///
				using "${dt_int}/baseline_mapping_long.dta"
				
	* Two time-station bin combinations from ride not present in mapping
	qui count if _merge == 1
	assert r(N) == 875
	
	* Drop mapping data that is not present in rides
	qui count if _merge == 2
	assert r(N) == 7
	drop if _merge == 2
	drop	_merge
	
/*******************************************************************************
	Clean up and save
*******************************************************************************/
	
	* Change gender based on first CI date being after the recruitment was limited to women	
	* ------------------------------------------------------------------------------------
	bysort 	user_uuid: egen 	first_CI = min(CI_date)
	replace user_gender = 1 if 	first_CI >= 20390 
	
	compress
	isid session
	
	iecodebook apply using "${doc_rider}/baseline-study/codebooks/merged.xlsx", drop
	
	save 			 "${dt_int}/baseline_merged.dta", replace
	iemetasave using "${dt_int}/baseline_merged.txt", replace
	
***************************************************************** End of do-file
