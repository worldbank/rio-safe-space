/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*	 				   Clean baseline demographic survey			 		   *
********************************************************************************

	** REQUIRES:	"${dt_raw}/baseline_raw_deidentified.dta"
					"${doc_rider}/baseline-study/codebooks/demo.xlsx"											
	** CREATES:	  	"${dt_int}/baseline_demographic.dta"
				  
	** WRITEN BY:  Astrid Zwager [azwager@worldbank.org]	
	
********************************************************************************
	 Load data and select variables					  
********************************************************************************/

	use "${dt_raw}/baseline_raw_deidentified.dta", clear

	* Only keep entries that refer to demo task	
	keep if entity_uuid == "8cdf559b-fe40-4569-833b-19b18078e91b"
	keep 	user* submitted
	
/*******************************************************************************
	Check for duplicated entries
********************************************************************************/

	codebook user_uuid															// 539 obs -- 463 unique values
	
	* Drop duplicate entries:
	* order on submission time and keep the last submission for that ID
	* --------------------------------------------------------------------------
	duplicates tag 	user_uuid, gen (dupl_id)	
	gsort  			user_uuid -submitted
	bysort 			user_uuid: drop if [_n] >=2   								// 76 users dropped	
	
/*******************************************************************************
	Clean commuting pattern data
********************************************************************************/
	
	* Make names consistent so they can be used in a loop
	rename 	user_commute_hour 		user_commute_period
	rename 	user_commute_return 	user_return_period
	rename  user_comute_afternoon 	user_commute_afternoon
	
	// there is commute data even for people that are not employed
	
	* Change trip hour variable to datetime type
	foreach trip in commute return {
		
		* Usual hour of travel
		gen 	temp_`trip' = user_`trip'_morning 	if regex(user_`trip'_period, "manh") // Problem with special character
		replace temp_`trip' = user_`trip'_afternoon if user_`trip'_period == "tarde"
		replace temp_`trip' = user_`trip'_evening 	if user_`trip'_period == "noite"
		gen 	user_`trip'_hour = clock(temp_`trip', "hm")
		format  user_`trip'_hour %tcHH:MM:SS
		drop 	temp_`trip'
	
		* Usual period of travel
		replace user_`trip'_period = "" 	if user_`trip'_period == "NA"
		encode	user_`trip'_period,    	   gen(user_`trip'_period_)
		drop 	user_`trip'_period
	}
	
/*******************************************************************************
	Encode and label string data
********************************************************************************/

	foreach var of varlist 	user_marital user_gender user_age user_ed user_ses ///
							user_earnings user_employment  {
							
		replace `var' = "" if `var' == "NA"
		encode 	`var', gen(`var'_) label(`var')
		drop	`var'
	}

/*******************************************************************************
	Clean up and save
*******************************************************************************/
		
	iecodebook apply using "${doc_rider}/baseline-study/codebooks/demo.xlsx", drop
	
	order 	user_uuid user_marital user_gender user_age user_ed user_ses ///
			user_earnings user_employment ///
			user_commute_period	user_commute_hour user_return_period user_return_hour
			
	sort	 user_uuid
	compress
	
	save 			 "${dt_int}/baseline_demographic.dta", replace
	iemetasave using "${dt_int}/baseline_demographic.txt", replace

******************************* The end ****************************************
