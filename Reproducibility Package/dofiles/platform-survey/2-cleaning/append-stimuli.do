********************************************************************************
*					PART 4: Stimulus-level data set
********************************************************************************

	do 	"${do_platform}/0. Importing/Security stimuli.do"
	do 	"${do_platform}/0. Importing/Reputation stimuli.do"
	do 	"${do_platform}/0. Importing/Career stimuli.do"
	
	append using "${dt_platform_int}/iat_security.dta"
	append using "${dt_platform_int}/iat_reputation.dta"
	
	* From field notes
	recode time 	(. = .n) 		if inlist(id, 2130, 1268, 2396, 3476, 6151, 6022, ///
												  6265, 2059, 2007, 2066, 2104, 2106, ///
												  2130, 2396) 
	recode time		(. = .n) 		if inlist(id, 2152, 2186, 6235, 2019, 6235, 2060) 			  & version == "Career"
	recode time		(. = .n) 		if inlist(id, 2186, 6040, 2018, 2019, 2103, 2091, 6374, 6503) & version == "Reputation"
	recode time		(. = .n) 		if inlist(id, 2429, 6246, 6235, 6392, 2018, 2357, 6503, 2060) & version == "Security"

	foreach varAux of varlist time* {
		replace `varAux' = .n if id == 2507 // invalid test: user couldn't see without glasses, enumerator responded
	}
	
	drop if id == 0 						// This was probably a test. It's the only observation in Oct 4, 2017
	drop if inlist(id, 2476, 6227, 6234) 	// system failure: IAT not computed
	
	* Manual fixes (view Platform Survey/Documentation/Platform Survey Issues)
	recode id 	(6122 = 6121) /// 6121 accepted the IAT. It was recorded at the IAT location as 6122
				(2262 = 2261) /// Sendo the wrong ID to the platform. At the platform, 2261 accepted the IAT but at the IAT location the label tag was marked as 2262
				(2283 = 2284) // The IAT scores were recorded as 2283, it is 2284
	
	compress
	saveold 		 "${dt_platform_int}/iat_stimuli.dta", replace v(13)
	iemetasave using "${dt_platform_int_git}/iat_stimuli.txt", replace
	
************************************************************* That's all, folks!
