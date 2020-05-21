/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 			    Clean compliance pilot check-out survey task		 	       *
********************************************************************************
	
	REQUIRES:	${dt_raw}/compliance_pilot_deidentified.dta
	CREATES:	${dt_rider_int}/compliance_pilot_co.dta
	
	WRITEN BY:  Luiza Andrade [lcardoso@worldbank.org]
	
********************************************************************************
*					PART 0:  Load data and select variables					   *
********************************************************************************/

	use 	"${dt_raw}/compliance_pilot_deidentified.dta", clear
	keep 	if task == "Checkout"												// Select check-out data
	
	* Keep only check-out task vars
	* -----------------------------
	keep 	user_line user_station* stranger_touched ///
			user_uuid session feeling_now feeling_reflection ///
			frustrated happy relaxed sad satisfied yes_no_switch_cars switch_cars ///
			tense ride_comments ride_stare ride_concern ride_touch ride_comfort ///
			stranger_comments stranger_staring concern_stranger_touched started
			
			
********************************************************************************
*					PART 2:  Complete missing observations 			 	 	   *
********************************************************************************

	* These variables are the same, but were them with diffente names
	* in different submissions	
	foreach var in ride_comments ride_stare ride_concern ride_touch yes_no_switch_cars {
		
		local ride_commentsSub 		stranger_comments
		local ride_stareSub			stranger_staring
		local ride_concernSub		concern_stranger_touched
		local ride_touchSub 		stranger_touched
		local yes_no_switch_carsSub switch_cars
				
		* Make sure var is a string (won't be if it has only missing values)
		tostring 	`var', replace
		
		* If the other-named variable has non missing values, 
		*save them in the first var
		local typeSub : type ``var'Sub'
		if substr("`typeSub'",1,1) == "s" {	
			replace		`var' = ``var'Sub'		if `var' == ""
		}
		
		* Then drop the extra variable
		drop 		``var'Sub'
		
	} 
	
********************************************************************************
*				PART 4:  Rename variables to match previous round			   *
********************************************************************************

	rename		yes_no_switch_cars	ride_switch
	
	foreach varAux of varlist 	happy sad tense relaxed	frustrated satisfied {
		rename 	`varAux' 		CO_`varAux'
	}	
	
********************************************************************************
*							PART 5:  Encode variables 				 	 	   *
********************************************************************************
	
	gen 	CO_feel_compare = .
	replace CO_feel_compare = 1 	if feeling_reflection == "Pihor"
	replace CO_feel_compare = 2		if feeling_reflection == "Igual"
	replace CO_feel_compare = 3 	if feeling_reflection == "Melhor"
	drop 	feeling_reflection 
	
		foreach varAux in 	comments stare concern touch switch {
	
		gen 		CO_`varAux' = (ride_`varAux' == "Sim" ) | ///
								  (ride_`varAux' == "yes" ) | ///
								  (ride_`varAux' == "sim" )   ///
							 if !((ride_`varAux' == ""    ) | ///
								  (ride_`varAux' == "NA"))
		drop 		ride_`varAux' 
		
	}

********************************************************************************
*							PART 8:  Order data							   	   *
********************************************************************************
		
	dropmiss, force
	compress

	iecodebook apply using "${doc_rider}/compliance-pilot/codebooks/check_out.xlsx", drop
	
	order 	user_uuid session CO_line CO_station ///
			CO_comments CO_stare CO_concern CO_touch CO_comfort user_uuid ///
			CO_feel_level CO_happy CO_sad CO_tense CO_relaxed ///
			CO_frustrated CO_satisfied CO_feel_compare CO_switch
	sort 	session
	
	save 			 "${dt_int}/compliance_pilot_co.dta", replace
	iemetasave using "${dt_int}/compliance_pilot_co.txt", replace

*********************************************************************** è finito!
