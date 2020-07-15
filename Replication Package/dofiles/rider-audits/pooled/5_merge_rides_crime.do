/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*	 				 Merge crime rates to rider panel						   *
********************************************************************************

	REQUIRES:  	"${dt_int}/crime_rates_bystation.dta"
				"${encrypt}/compliance_pilot_raw_corrected.dta"
				"${encrypt}/baseline_raw_corrected.dta"
				"${dt_int}/pooled_rider_audit_rides_congestion.dta"
	
	CREATES:	"${dt_int}/crime_rates_home_station.dta"
				"${dt_final}/pooled_rider_audit_rides.dta"

	WRITEN BY:   Luiza Andrade
	
	NOTES:		Access to encrypted, identified data is required to run 
				part of this file
	
********************************************************************************
	Merge to user home station (encrypted information)
*******************************************************************************/

	if ${encrypted} {
	
	// Prepare crime data
		use 	"${dt_int}/crime_rates_bystation.dta", clear
		rename	CI_station	user_home_station
		
		tempfile homestation
		save 	`homestation'
		
	// Get identified data on crime rate at home station for pilot riders
	
		use "${encrypt}/compliance_pilot_raw_corrected.dta", clear 
		
		* Rename to match baseline
		rename 	user_id user_uuid
		
		* Keep only demo entries
		drop if missing(user_home_station)
		
		* Keep only relevant variables
		keep user_uuid user_home_station
		gen  stage = 1 
		
		* Save tempfile
		isid user_uuid stage
		
		tempfile pilot
		save	`pilot'
		
	// Get identified data on crime rate at home station for baseline riders
	
		use "${encrypt}/baseline_raw_corrected.dta", clear
	
		* Demo entries
		keep if entity_uuid == "8cdf559b-fe40-4569-833b-19b18078e91b"
		
		* Keep latest submission of riders who completed the demo survey more than once
		duplicates tag 	user_uuid, gen (dupl_id)	
		gsort  			user_uuid -submitted
		bysort 			user_uuid: drop if [_n] >=2 
		
		* Keep only relevant variables
		keep user_uuid user_home_station
		gen stage = 0
		
		* Clean up
		drop if missing(user_home_station)
		isid user_uuid stage
		
	// Merge data
	
		* BL + pilot
		append using `pilot'
		
		* Merge to crime data
		merge m:1 user_home_station using `homestation', keep(1 3)
		
		* Check merge
		assert user_home_station == 925 if _merge == 1
		drop _merge user_home_station						// Drop identifying information		
		
		* Rename variables, as we'll have more than one crime variable per user
		foreach crime in allcrime violent rape theft {
			rename rate_`crime' home_rate_`crime'
		}	
		
		isid user_uuid stage

		save "${dt_int}/crime_rates_home_station.dta", replace
		
	}
	
/*******************************************************************************
	Merge crime data at check-in station
*******************************************************************************/ 

	use	"${dt_int}/pooled_rider_audit_rides_congestion.dta", clear
	
	* Merge
	merge m:1 CI_station using "${dt_int}/crime_rates_bystation.dta", keep(1 3) // stations that did not match are not in this dataset
	
	* Check merge
	assert (CI_station == 519 | missing(CI_station)) if _merge == 1 			// we also have no crime data for station 519
	drop _merge
	
	* Identify variables
	foreach crime in allcrime violent rape theft {
		rename rate_`crime' CI_rate_`crime'
	}
		

/*******************************************************************************
	Clean up and save
*******************************************************************************/ 

	merge m:1 user_uuid stage using "${dt_int}/crime_rates_home_station.dta", keep(1 3) nogen
	
	compress
	
	save				"${dt_final}/pooled_rider_audit_rides.dta", replace
	iemetasave using 	"${dt_final}/pooled_rider_audit_rides.txt", replace
	
********************************* The end **************************************
