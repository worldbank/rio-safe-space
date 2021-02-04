/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*				Merge admin congestion data to rides data					   *
********************************************************************************

	* REQUIRES:  	"${dt_int}/pooled_rider_audit_rides_coverage_direction.dta"
					"${dt_int}/congestion_station_level.dta"
					"${dt_int}/congestion_station_level_wide.dta"
	* CREATES:		"${dt_int}/pooled_rider_audit_rides_congestion.dta"
	
	* WRITEN BY:   Luiza Andrade

********************************************************************************
*						   PART 0:  Open rides data							   *
********************************************************************************/
	
	use	"${dt_int}/pooled_rider_audit_rides_coverage_direction.dta", clear
	
********************************************************************************
*					 PART 1:  Create variables to merge						   *
********************************************************************************

	gen 	year 		= year(RI_date)
	gen 	month_merge = month(RI_date)
	gen 	hora = .
	replace	hora = 6 	if inlist(RI_time_bin,1,2)
	replace	hora = 7 	if inlist(RI_time_bin,3,4)
	replace	hora = 8 	if inlist(RI_time_bin,5,6)
	replace	hora = 17 	if inlist(RI_time_bin,7,8)
	replace	hora = 18 	if inlist(RI_time_bin,9,10)
	replace	hora = 19 	if inlist(RI_time_bin,11,12)
	
********************************************************************************
*				 PART 4:  Merge to station level congestion					   *
********************************************************************************
	
	merge 	m:1 year month_merge hora CI_direction CI_station ///
			using "${dt_final}/congestion_station_level.dta", ///
			keepusing(CI_loadfact) keep(1 3) nogen
	
	
********************************************************************************
*		 PART 5:  Merge to wide congestion data if didn't switch lines		   *
********************************************************************************

	* Merge
	* -----
	merge 	m:1 year month_merge hora CI_direction ///
			using "${dt_int}/congestion_station_level_wide.dta", ///
			keep (1 3) nogen
			
	* Replace by missing if station wasn't covered by ride
	* ----------------------------------------------------
	local stations	101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 ///
					201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 ///
					301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 ///
					401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 418 419 ///
					501 502 503 504 505 506 507 508 509 510 511 512 513 514 515 516 517 518 519 520
	
	foreach stationCode of local stations {
		if !inlist(`stationCode',105,204,205,304) {
			foreach varAux in timemin_ lengthkm_ {
				replace `varAux'`stationCode' = . if cover_`stationCode' != 1
			}
		}
	}
	
	
********************************************************************************
*			 PART 6:  Merge to wide congestion data if switched lines		   *
********************************************************************************

	* Get data for check-in line
	* --------------------------
	preserve
		
		keep 	if CI_direction == .c
		keep 	user_uuid session year month_merge hora CI_line CI_direction_1st_line cover*
		rename 	CI_direction_1st_line CI_direction
		
		merge 	m:1 year month_merge hora CI_direction ///
				using "${dt_int}/congestion_station_level_wide.dta", ///
				keep(3) nogen
				
		foreach stationCode of local stations {
			if !inlist(`stationCode',105,204,205,304) {
				foreach varAux in timemin_ lengthkm_ {
					replace `varAux'`stationCode' = . if cover_`stationCode' != 1 | ///
														 floor(`stationCode'/100) != CI_line
					rename 	`varAux'`stationCode' 	`varAux'`stationCode'_CI_line
				}
			}
		}
		
		tempfile 	congestion_CI_line
		save		`congestion_CI_line'

	restore
	
	
	* Get data for check-out line
	* ---------------------------
	preserve
	
		keep 	if CI_direction == .c
		keep 	user_uuid session year month_merge hora CO_line CI_direction_2nd_line cover*
		rename 	CI_direction_2nd_line CI_direction
		
		merge 	m:1 year month_merge hora CI_direction ///
				using "${dt_int}/congestion_station_level_wide.dta", ///
				keep(3) nogen
				
		foreach stationCode of local stations {
			if !inlist(`stationCode',105,204,205,304) {
				foreach varAux in timemin_ lengthkm_ {
					replace `varAux'`stationCode' = . if cover_`stationCode' != 1 | ///
														 floor(`stationCode'/100) != CO_line
					rename 	`varAux'`stationCode' 	`varAux'`stationCode'_CO_line
				}
			}
		}
		
		tempfile 	congestion_CO_line
		save		`congestion_CO_line'
		
	restore
	
	* Merge all
	* ---------
	merge 1:1 user_uuid session	using `congestion_CO_line', nogen
	merge 1:1 user_uuid session	using `congestion_CI_line', nogen
	
	

********************************************************************************
*		  PART 7:  Merge to station level congestion if switched lines		   *
********************************************************************************

	preserve
	
		keep if CI_direction == .c
		keep 	year month_merge CI_direction_1st_line hora CI_station user_uuid session
		
		rename 	CI_direction_1st_line CI_direction
		
		merge 	m:1 year month_merge hora CI_direction CI_station ///
				using "${dt_final}/congestion_station_level.dta", ///
				keepusing(CI_loadfact) keep(3) nogen
				
		rename 	CI_loadfact load_factor
		
		tempfile	load_factor
		save		`load_factor'

	restore
	
	merge 1:1	user_uuid session			using `load_factor', nogen
	replace		load_factor = CI_loadfact 	if load_factor == .
		
	
********************************************************************************
*					 PART 8:  Create total over ride vars					   *
********************************************************************************

	egen 	time_min = rowtotal(timemin*)
	replace time_min = . if time_min == 0
	
	egen	length_km = rowtotal(lengthkm*)
	replace length_km = . if length_km == 0	

	
********************************************************************************
*							 PART 9:  Clean-up								   *
********************************************************************************

	drop 	lengthkm* timemin* cover_* CI_direction_2nd_line CI_direction_1st_line ///
			hora month_merge year CI_loadfact
	
	lab var time_min 		"Time of travel (min)"
	lab var length_km 		"Length of travel (km)"
	lab var	load_factor		"Average ride load factor"
	

********************************************************************************
*							 PART 10: Save data								   *
********************************************************************************
	
	compress
	
	save				"${dt_int}/pooled_rider_audit_rides_congestion.dta", replace
	iemetasave using 	"${dt_int}/pooled_rider_audit_rides_congestion.txt", replace
	
*************************** End of do file *************************************
