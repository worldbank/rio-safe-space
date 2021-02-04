/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 				 Clean compliance pilot demographic survey task			 	   *
********************************************************************************
	
	REQUIRES:	${dt_raw}/compliance_pilot_deidentified_corrected.dta
				${doc_rider}/compliance-pilot/codebooks/demo.xlsx
	CREATES:	${dt_int}/compliance_pilot_demographic.dta	
	
	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]
	
********************************************************************************
*					PART 0:  Load data and select variables					   *
********************************************************************************/
	
	* Load data
	* ---------
	use 	"${dt_raw}/compliance_pilot_deidentified.dta", clear
	keep 	if entity_uuid == "fe5adbb1-e4eb-4067-a89f-735789d0b13e"			// Keep only demographic data
	
	* Check for duplicate entries
	* ---------------------------
	codebook 		user_uuid													// 197 obs -- 196 unique values
	duplicates tag 	user_uuid, 	gen (dupl_id)
	gsort 			user_uuid 	-submitted										// drop duplicate entries -- order on submission time and keep the last submission for that ID
	bysort			user_uuid:	drop if [_n] >=2								// 1 obs dropped
	drop if 		user_uuid == "2e4ef69a-0734-438c-958f-025bd876a533"			// user only completed demographic survey (as returning, then new user) and didn't take any rides
	
	* Keep only demo task vars
	* ------------------------
	keep	user* return_group_id
	drop 	user_line
	
********************************************************************************
*					PART 1:  Create commute pattern variables			 	   *
********************************************************************************

	foreach trip in commute return {

		* Period of day
		rename user_`trip'_period		user_`trip'_period_str
		encode user_`trip'_period_str, 	gen(user_`trip'_period)
		recode user_`trip'_period 		(2=3) (3=2)
		
		* Time of travel
		gen double 	user_`trip'_hour = clock(user_`trip'_morning, "hm")		if 	user_`trip'_period == 1
		replace 	user_`trip'_hour = clock(user_`trip'_afternoon, "hm")	if 	user_`trip'_period == 2
		replace 	user_`trip'_hour = clock(user_`trip'_evening, "hm")		if 	user_`trip'_period == 3
		format  	user_`trip'_hour %tcHH:MM:SS
		
	}
	
********************************************************************************
*							PART 2:  Encode string data			 		  	   *
********************************************************************************
	
	* Encode other variables imported as strings
	foreach varAux of varlist 	user_marital user_gender user_age user_ed ///
								user_ses user_earnings user_employment ///
								user_other_transport {
		encode 	`varAux', 	gen(`varAux'_) label(`varAux')
		drop 	`varAux'
		rename 	`varAux'_ 	`varAux'
	}

		* Returning user?
	gen 	user_new	= (return_group_id == "new_rider")
	
********************************************************************************
*								PART 8:  Order data						   	   *
********************************************************************************

	order 	user_uuid user_new user_marital user_gender user_age user_ed user_ses ///
			user_household_size user_earnings user_employment ///
			user_weekly_rides user_other_transport user_commute* user_return* 
	sort 	user_uuid
	

	isid user_uuid
	
********************************************************************************
*								PART 9:  Save data						   	   *
********************************************************************************

	dropmiss, force
	compress
	
	iecodebook apply using "${doc_rider}/compliance-pilot/codebooks/demo.xlsx", drop
	
	save 			 "${dt_int}/compliance_pilot_demographic.dta", replace
	iemetasave using "${dt_int}/compliance_pilot_demographic.txt", replace

********************************************************************* C'est fini!
