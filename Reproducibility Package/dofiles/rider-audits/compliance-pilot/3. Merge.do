/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 						 Merge compliance pilot ride tasks				 	   *
********************************************************************************

	REQUIES:	${dt_int}/compliance_pilot_ci.dta
				${dt_int}/compliance_pilot_ride.dta
				${dt_int}/compliance_pilot_co.dta
				${dt_int}/compliance_pilot_demographic.dta
				${dt_int}/compliance_pilot_clean_mapping_long.dta
				${doc_rider}/compliance-pilot/codebooks/merged.xlsx
				
	CREATES:	${dt_int}/compliance_pilot_merged.dta
				  
	WRITEN BY:  Luiza Andrade 

********************************************************************************
*	Merge ride tasks
********************************************************************************/

	* Only trips with all three ride tasks were accepted in the server,
	* so they should always merge
	use 	"${dt_int}/compliance_pilot_ci.dta", clear
	merge 1:1 	session 	using "${dt_int}/compliance_pilot_ride.dta", assert(3) nogen
	merge 1:1 	session 	using "${dt_int}/compliance_pilot_co.dta",  assert(3) nogen
	
********************************************************************************
*	Merge demographic survey
********************************************************************************

	merge m:1 	user_uuid 	using "${dt_int}/compliance_pilot_demographic.dta"
	
	* 3 users have rides data, but no demo 
	unique user_uuid if _merge == 1
	assert r(unique) == 3
	
	* 49 users have demo data, but no rides: these are dropped
	unique user_uuid if  _merge == 2
	assert r(unique) == 49
	drop if _merge == 2
	
	* 185 users have ride & demo data
	unique user_uuid if  _merge == 3
	assert r(unique) == 185
	
	gen 	flag_nodemovars = (user_age == .)
	
	drop _merge	
	
********************************************************************************
*						 	 PART 3:  Order data							   *
********************************************************************************

	* Change time variable to Rio time
	* --------------------------------
	foreach task in CI RI CO {
	
		split	`task'_started, p(" ")
		gen 	`task'_date = clock(`task'_started1, "YMD")
		replace `task'_date = dofc(`task'_date)
		format 	`task'_date %td
	
		gen		`task'_time = clock(`task'_started2, "hms")
		
		gen 	`task'_hour = hh(`task'_time)							// zulu time
		replace `task'_hour = `task'_hour - 3			    			// rio time
		replace `task'_hour = `task'_hour + 1 if `task'_date >= 20743	// rio daylights saving time: 16 Oct - 19 Fev (sample ends in Feb 17)

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
	* --------------------------------------------------------------
	gen 	station_bin = .
	replace station_bin =  1 if inlist(CI_station,101,102,103,104,105)
	replace station_bin =  2 if inlist(CI_station,106,107,108,109,110)
	replace station_bin =  3 if inlist(CI_station,111,112,113,114,115)
	replace station_bin =  4 if inlist(CI_station,116,117,118,119)
	replace station_bin =  5 if inlist(CI_station,201,202,203,204,205)
	replace station_bin =  6 if inlist(CI_station,207,208,209,210,211)
	replace station_bin =  7 if inlist(CI_station,212,213,214,215,216)
	replace station_bin =  8 if inlist(CI_station,217,218,219,220)
	replace station_bin =  9 if inlist(CI_station,221,222,223,224)
	replace station_bin = 10 if inlist(CI_station,301,302,303,304,305,306)
	replace station_bin = 11 if inlist(CI_station,307,308,309,310,311)
	replace station_bin = 12 if inlist(CI_station,312,313,314,315)
	replace station_bin = 13 if inlist(CI_station,316,317,318,319,320)
	replace station_bin = 14 if inlist(CI_station,401,402,403,404,405)
	replace station_bin = 15 if inlist(CI_station,406,407,408,409,410)
	replace station_bin = 16 if inlist(CI_station,411,412,413,414,415)
	replace station_bin = 17 if inlist(CI_station,416,417,418,419)
	replace station_bin = 18 if inlist(CI_station,501,502,503,504,505)
	replace station_bin = 19 if inlist(CI_station,506,507,508,509,510)
	replace station_bin = 20 if inlist(CI_station,511,512,513,514)
	replace station_bin = 21 if inlist(CI_station,515,516,517)
	replace station_bin = 22 if inlist(CI_station,518,519,520)
		
		
	* Now merge
	* ---------
	merge m:1 RI_time_bin station_bin using "${dt_int}/compliance_pilot_clean_mapping_long.dta"
	
	* 4 station bins were not observed at the last time bin
	* These will have no mapping obs
	qui count if _merge == 1
	assert r(N) == 160
	
	* Mapping obser with no rides will be dropped
	qui count if _merge == 2
	assert r(N) == 6
	drop if _merge == 2
	drop	_merge
	
********************************************************************************
*							  PART 7:  Save data	  					       *
********************************************************************************
	
	iecodebook apply using "${doc_rider}/compliance-pilot/codebooks/merged.xlsx", drop
	
	compress
	
	save 			 "${dt_int}/compliance_pilot_merged.dta", replace
	iemetasave using "${dt_int}/compliance_pilot_merged.txt", replace
		
********************************************************************* That's all
