/*******************************************************************************
*								Rio Pink Car								   *
*			  			  IMPORT PLATFORM SURVEY						  	   *
********************************************************************************

	** PURPOSE:  	Import Platform Survey data into Stata format
	
	** OUTLINE:		PART 1: Load survey data from first day
					PART 2: Load survey from all other days
					PART 3: Merge everything
					
	** REQUIRES:	${encrypt}/Platform survey/rio_pinkcar_survey_day1.csv
					${doc_platform}/iedupreportday1.xlsx
					${encrypt}/Platform survey/rio_pinkcar_survey_iat_day1.csv
					${encrypt}/Platform survey/rio_pinkcar_survey_iat.csv
					${doc_platform}/iedupreportsurvey_iat.xlsx
					${dt_raw}/rio_pinkcar_survey.csv
					${doc_platform}/iedupreportsurvey.xlsx
																			
	** CREATES:	  	${dt_raw}/platform_survey_raw.dta
										  
	** NOTES:		Participants who did not take the IAT had a shorter 
					questionnaire, delivered at the platform. Participants who
					took the IAT answered only a few questions in the platform,
					then alswer a longer questionnaire at the IAT location.
	
********************************************************************************
*					PART 1: Load survey data from first day
*******************************************************************************/

	* First day of survey had a slightly different questionnaire, so it was 
	* exported separately
	
// Survey ----------------------------------------------------------------------

	* Load data
	import delimited "${encrypt}/Platform survey/rio_pinkcar_survey_day1.csv", delimiter(";") clear
	
	* The ID variable was only assigned to people who accepted to take the survey.
	* However, we still want to keep the observations of people who did not accept
	* to count the number of people approached, so we will assign an ID to them
	qui count if response_intro == 1 & id == . & whyleave_closed != 1
	assert r(N) == 0
	
	* ID will be assign by order of start time, so it is stable when new observations come in
	cap unique id starttime
	assert r(unique) == _N
	
	replace id = 888000 + _n if id == .
		
	* A few ID values were used for different people. They are listed and
	* explained in the duplicates report below
	ieduplicates id using "${doc_platform}/duplicate-reports/iedupreportday1.xlsx" ///
				 , ///
				 uniquevars(key submissiondate) ///
				 keepvars(starttime enumeratorname)
	
	* Adjust variables formats to match IAT data
	tostring general_notes, replace
	
	* Save tempfile
	tempfile day1
	save 	 `day1'

// IAT -------------------------------------------------------------------------

	* Load data
	import delimited "${encrypt}/Platform survey/rio_pinkcar_survey_iat_day1.csv", clear
	
	* Adjust variables formats to match survey
	tostring username, replace

// Merge both datasets ---------------------------------------------------------

	* All observations in the IAT should match, since they also took the survey.
	* However, not all observations in the survey dataset should be present in the IAT
	merge 1:1 id using `day1', update assert(2 5) nogen 
	
// Format corrections ---------------------------------------------------------

	* Flag for robustness checks
	gen 	flag_day1 = 1
	
	* A group of variables was modified after the first day, the code below
	* makes this data consistent with the remaining days.
	rename q8 usual_car
	foreach varAux in	set1_q8_15 set1_q8_30 set1_q8_65 set2_q8_15 set2_q8_65 ///
						set2_q8_30 set3_q8_30 set3_q8_15 set3_q8_65 set4_q8_30 ///
						set4_q8_65 set4_q8_15 set5_q8_65 set5_q8_15 set5_q8_30 ///
						set6_q8_65 set6_q8_30 set6_q8_15 {
		gen `varAux' = .
	}

	forvalues q = 9/10 {
	
		replace set1_q8_15 = set1_q`q'_1 if set1_q`q'_1 != .
		replace set1_q8_30 = set1_q`q'_2 if set1_q`q'_2 != .
		replace set1_q8_65 = set1_q`q'_3 if set1_q`q'_3 != .
		replace set2_q8_15 = set2_q`q'_1 if set2_q`q'_1 != .
		replace set2_q8_65 = set2_q`q'_2 if set2_q`q'_2 != .
		replace set2_q8_30 = set2_q`q'_3 if set2_q`q'_3 != .
		replace set3_q8_30 = set3_q`q'_1 if set3_q`q'_1 != .
		replace set3_q8_15 = set3_q`q'_2 if set3_q`q'_2 != .
		replace set3_q8_65 = set3_q`q'_3 if set3_q`q'_3 != .
		replace set4_q8_30 = set4_q`q'_1 if set4_q`q'_1 != .
		replace set4_q8_65 = set4_q`q'_2 if set4_q`q'_2 != .
		replace set4_q8_15 = set4_q`q'_3 if set4_q`q'_3 != .
		replace set5_q8_65 = set5_q`q'_1 if set5_q`q'_1 != .
		replace set5_q8_15 = set5_q`q'_2 if set5_q`q'_2 != .
		replace set5_q8_30 = set5_q`q'_3 if set5_q`q'_3 != .
		replace set6_q8_65 = set6_q`q'_1 if set6_q`q'_1 != .
		replace set6_q8_30 = set6_q`q'_2 if set6_q`q'_2 != .
		replace set6_q8_15 = set6_q`q'_3 if set6_q`q'_3 != .
		
	}	
	
	
	* Save tempfile
	tempfile day1
	save 	 `day1'
	
	
********************************************************************************
*					PART 2: Load survey from all other days
********************************************************************************

// IAT -------------------------------------------------------------------------

	* Load data
	import delimited "${encrypt}/Platform survey/rio_pinkcar_survey_iat.csv", clear delimiter(";")
	
	* Drop variables with metadata. They have rounding issues that were creating problems in ieduplicates
	drop deviceid subscriberid simid
	
	* Adjust format to match other data sets
	foreach varAux of varlist random_order {
		replace `varAux' = subinstr(`varAux',",",".",.)
		destring `varAux', replace
	}
	
	* Correct problematic IDs based on field notes
	replace id = 6121 if id == 6122 // 6121 accepted the IAT. It was recorded at the IAT location as 6122
	replace id = 2261 if id == 2262 // Sent the wrong ID to the platform. At the platform, 2261 accepted the IAT but at the IAT location the label tag was marked as 2262
	replace id = 2284 if id == 2283 // The IAT scores were recorded as 2283, it is 2284
	
	* There is only one duplicated answer, with no changes in the responses,
	* due to connectivity issues
	ieduplicates id using "${doc_platform}/duplicate-reports/iedupreportsurvey_iat.xlsx" ///
				 , ///
				 uniquevars(key submissiondate) ///
				 keepvars(starttime enumeratorname)
	
	* Rename gender variable (so we can replace it if it doesn't match)
	rename gender_interview gender_interview_iat
	
	* Save tempfile
	tempfile iat
	save	 `iat'
	
// Survey ----------------------------------------------------------------------
	
	* Load survey for other respondents
	import delimited "${encrypt}/Platform survey/rio_pinkcar_survey.csv", bindquotes(strict) clear delimiter(";")
	
	* Identify observations
	qui count if id != id_check
	assert r(N) == 0
	drop id_check
	
	* Adjust format to match other data sets
	foreach varAux of varlist random_iat {
		replace `varAux' = subinstr(`varAux',",",".",.)
		destring `varAux', replace
	}
	
	* The ID variable was only assigned to people who accepted to take the survey.
	* However, we still want to keep the observations of people who did not accept
	* to count the number of people approached, so we will assign an ID to them
	qui count if response_intro == 1 & id == . & whyleave_closed != 1
	assert r(N) == 0
	
	* ID will be assign by order of start time, so it is stable when new observations come in
	cap unique id starttime key
	assert r(unique) == _N
	
	replace id = 999000 + _n if id == . // (slightly different ID rule than day1)
	
	ieduplicates id using "${doc_platform}/duplicate-reports/iedupreportsurvey.xlsx" ///
				 , ///
				 uniquevars(key submissiondate) ///
				 keepvars(starttime enumeratorname)
	
********************************************************************************
*							PART 3: Merge everything 
********************************************************************************

	* Merge iat survey
	* ----------------
	* All observations in the IAT should match, since they also took the survey.
	* However, not all observations in the survey dataset should be present in the IAT
	merge 1:1 id using `iat', update replace assert(1 5) nogen
	
	
	* Merge to day 1
	* --------------
	* All the IDs should be different in this case
	merge 1:1 id using `day1', assert(1 2) nogen
	
********************************************************************************
*							PART 4: Save data
********************************************************************************
	
	* Corrections based on enumerators notes when respondents refused to answer
	* and random option selected
	replace reputation_change = .r 			if inlist(id, 2353, 6355) 	// 6355 is from day 1, has different question numbers
	replace reputation_self = .r 			if id == 6355 				// 6355 is from day 1, has different question numbers
	replace intervene_pink_people = .r 		if inlist(id, 2478, 6182)
	replace intervene_mixed_people = .r 	if inlist(id, 2478, 6182)
	replace crime = .						if id == 6069 				// not sure if refused, note only says "should be missing" 
	
	* Identified version
	isid id, sort
	compress
	
	save 			 "${encrypt}/Platform survey/platform_survey_raw.dta", replace
	iemetasave using "${dt_raw}/platform_survey_raw.txt", replace short
	
	* De-identify: remove confidential variables only
	iecodebook apply using "${doc_platform}/codebooks/raw_deidentify.xlsx", drop

	isid id, sort
	
	save 			 "${dt_raw}/platform_survey_raw_deidentified.dta", replace
	iemetasave using "${dt_raw}/platform_survey_raw_deidentified.txt", replace
		
************************************************************************* End of do-file