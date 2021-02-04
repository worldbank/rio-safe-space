/*******************************************************************************
*								Rio Pink Car								   *
*				  			 IMPORT IAT SURVEY							  	   *
********************************************************************************

	** PURPOSE:  	IAT survey's data on response time and correct answers are 
					exported in a .txt file that is not easily imported into
					stata. This do-file extracts the last IAT data and merges
					it to IAT data set. These variables will not be part of the 
					final data set, they're only used to evaluate the stimuli
	
	** OUTLINE:		PART 1: Version-level data set
					PART 1.1: Import scores and merge across versions
					PART 1.2: Manual fixes from field notes
					PART 1.3: Save data set
					PART 4: Stimulus-level data set
					
	** REQUIRES:	$dt_platform_raw/IAT_team_security_alldata_raw.txt
					$dt_platform_raw/IAT_team_reputation_alldata_raw.txt
					$dt_platform_raw/IAT_team_career_alldata_raw.txt
					$dt_platform_raw/iat_security_alldata
					$dt_platform_raw/iat_reputation_alldata
					$dt_platform_raw/iat_career_alldata
	
																			
	** CREATES:	  	$dt_platform_int/security_score.dta
					$dt_platform_int/reputation_score.dta
					$dt_platform_int/career_score.dta
					$dt_platform_int/security_time.dta
					$dt_platform_int/repuation_time.dta
					$dt_platform_int/career_time.dta
					$dt_platform_int/iat_scores.dta
								
				  
	** WRITEN BY:   Luiza Andrade [lcardosodeandrad@worldbank.org]
	
********************************************************************************
*	PART 1: Version-level data set
*******************************************************************************/

/*------------------------------------------------------------------------------
	PART 1.1: Import scores and merge across versions
------------------------------------------------------------------------------*/
	varabbrev {
	
		foreach version in career reputation security {
		
			di "Importing `version' IAT"

			* Import
			import 	delimited "${encrypt}/Platform survey/iat_`version'_scoresonly.txt", delimiter(space) clear
			
			* Fix error in import of variable name
			* (this is probably an issue with the encoding of the data)
			capture confirm variable v1
			if _rc {
				rename 	ï  id
			}
			else {
				rename 	v1 id 
			}
			
			* Calculate score		
			gen 	 score = v2
			replace  score = ".f" if score == "TooFast"	// When the association was made too fast, no score is calculated, as it's probably random clicking
			replace  score = subinstr(score,",",".",.)
			destring score,  replace
			
			* Calculate date of IAT for duplicates report
			gen 	date 	 = date(v10,"DMY")
			gen 	hour 	 = clock(v11,"hms")
			gen 	datetime = date*24*60*60*1000 + hour
			format 	datetime %tc		
			
			* Drop blank observations
			drop 	date hour
			drop if datetime == . & score == .
			destring id, replace
					
			* Identify version
			gen version = "`version'"
			
			* Clean up
			keep id score version
			duplicates drop
			
			drop if version == "security" & id == 2103 & score > 0					// took IAT twice, removing second score
			
			
			* Save tempfile
			save 			 "${dt_raw}/`version'_score.dta"	 , replace
			iemetasave using "${dt_raw}/`version'_score.txt", replace
		}	
	}

	* Merge all version
	append using "${dt_raw}/career_score.dta"
	append using "${dt_raw}/reputation_score.dta"
	
	isid id version

/*------------------------------------------------------------------------------
	PART 1.2: Manual fixes from field notes
	(see Platform Survey/Documentation/Platform Survey Issues)
------------------------------------------------------------------------------*/
	
	recode id 	(6122 = 6121) /// 6121 accepted the IAT. It was recorded at the IAT location as 6122
				(2262 = 2261) /// 2261 accepted the IAT but at the IAT location the label tag was marked as 2262
				(2283 = 2284) //  The IAT scores were recorded as 2283, it is 2284
	
	* Change level of observation to respondent
	reshape wide score, i(id) j(version) string
	
	* From field notes
	recode score* 		 	(. = .n) 		if inlist(id, 2130, 1268, 2396, 3476, 6151, 6022, ///
														  6265, 2059, 2007, 2066, 2104, 2106, ///
														  2130, 2396) 
	recode score*		 	(. = .n) 		if inlist(id, 2476, 6227, 6234) // system failure: IAT not computed
	recode *career			(. = .n) 		if inlist(id, 2152, 2186, 6235, 2019, 6235, 2060)
	recode *reputation		(. = .n) 		if inlist(id, 2186, 6040, 2018, 2019, 2103, 2091, 6374, 6503)
	recode *security		(. = .n) 		if inlist(id, 2429, 6246, 6235, 6392, 2018, 2357, 6503, 2060)

	foreach varAux of varlist score* {
		replace `varAux' = .n if id == 2507 // invalid test: user couldn't see without glasses, enumerator responded
	}

	drop if id == 0 // This was a test. It's the only observation in Oct 4, 2017
	
	* Drop IDs that responded to IAT randomly or incorrectly
	drop if inlist(id, 2060, 2091, 2136, 2152, 2269, 2344, 2348, 6151, 6174) // From field issues
	
/*------------------------------------------------------------------------------
	PART 1.3: Save data set
------------------------------------------------------------------------------*/

	isid id, sort
	compress
	save 			 "${dt_int}/iat_scores.dta", replace
	iemetasave using "${dt_int}/iat_scores.txt", replace
		
***************************************************************** End of do-file