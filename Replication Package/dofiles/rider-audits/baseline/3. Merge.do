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
	
	* Merged users: 307
	unique user_uuid if demo_merge == 3
	assert r(unique) == 307
	
	* No rides: 244	
	unique user_uuid if demo_merge == 2
	assert r(unique) == 244
	drop if demo_merge == 2														// drop users with no ride data

	* No demo: 193
	unique user_uuid if demo_merge == 1
	assert r(unique) == 193
	drop demo_merge
	
	gen 	flag_nodemovars = (user_age == .)
	
/*******************************************************************************
	Merge to mapping
*******************************************************************************/

	* Change time variable to Rio time
	* --------------------------------
	foreach task in CI RI {
	
		gen 	`task'_date = dofc(`task'_started)
		format 	`task'_date %td
	
		gen 	zulu_time = `task'_started
		format 	zulu_time %tc_hh:mm:SS
		
		gen 	`task'_time = zulu_time - 10800000
		format 	`task'_time %tc_hh:mm:SS
		drop	zulu_time
		
/*	Sunday, October 18, 2015, 12:00:00 Midnight clocks were turned forward 1 hour to // rio
	Sunday, October 25, 2015, 2:00:00 AM clocks were turned backward 1 hour to  	 // gmt
	(clock was changed at GMT so already adjusted in time that was recorded)		 */
		replace `task'_time = `task'_time + 3600000 if `task'_date > 20378
	
	}
	
	* Generate time bins that allow us to merge with mapping data
	* -----------------------------------------------------------
	gen 	RI_time_bin =.
	replace RI_time_bin = 1	 if RI_time <= 23340000
	replace RI_time_bin = 2	 if RI_time >= 23400000 & RI_time <= 25140000
	replace RI_time_bin = 3	 if RI_time >= 25200000	& RI_time <= 26940000
	replace RI_time_bin = 4	 if RI_time >= 27000000	& RI_time <= 28740000
	replace RI_time_bin = 5	 if RI_time >= 28800000	& RI_time <= 30540000
	replace RI_time_bin = 6	 if RI_time >= 30600000	& RI_time <= 32340000
	replace RI_time_bin = 7	 if RI_time >= 61200000	& RI_time <= 62940000
	replace RI_time_bin = 8	 if RI_time >= 63000000	& RI_time <= 64740000
	replace RI_time_bin = 9	 if RI_time >= 64800000	& RI_time <= 66540000
	replace RI_time_bin = 10 if RI_time >= 66600000	& RI_time <= 68340000
	replace RI_time_bin = 11 if RI_time >= 68400000	& RI_time <= 70140000
	replace RI_time_bin = 12 if RI_time >= 70200000

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
	assert r(N) == 463
	
	* Drop mapping data that is not present in rides
	qui count if _merge == 2
	assert r(N) == 200
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

	

	
	

