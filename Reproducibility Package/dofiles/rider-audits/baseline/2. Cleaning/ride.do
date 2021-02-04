/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*   				    Clean baseline survey ride task				  	   	   *
********************************************************************************
	
	** REQUIRES:	${dt_raw}/baseline_raw_deidentified.dta
					${doc_rider}/baseline-study/codebooks/ride.xlsx
																			
	** CREATES:	  	${dt_int}/baseline_ride
				  
	** WRITEN BY:  Astrid Zwager [azwager@worldbank.org]	

********************************************************************************
	Load data set and keep ride variables
*******************************************************************************/

	use "${dt_raw}/baseline_raw_deidentified.dta", clear

	* Keep  only entries that refer to ride task	
	keep if inlist(spectranslated, "Regular Car", "Women Only Car")
	
	* Sort observations
	isid user_uuid session, sort
			
	* Keep only questions answered during this task	
	* (all others will be missing for these observations)
	dropmiss, force
		 
/*******************************************************************************
	Encode variables
*******************************************************************************/
	
	* Crowd rate
	encode 	ride_crowd_rate, gen(RI_crowd_rate)
	
	* Compliance
	replace ride_men_present = approx_percent_men if missing(ride_men_present)
	encode 	ride_men_present, gen(RI_men_present) 
	
	* Did you look in the cars before you made your choice	
	foreach var in sv_choice_pink sv_choice_regular {
		gen `var'_ = (`var' == "Sim") if (!missing(`var') & `var' != "NA")
	}	
	
	* Adjust for phase 3 variable names
	replace sv_choice_pink_ = 		(studied_fem_car == "Sim") if !missing(studied_fem_car) & missing(sv_choice_pink_)
	replace sv_choice_regular_ =	(studied_mix_car == "Sim") if !missing(studied_mix_car) & missing(sv_choice_regular_)
	
	* Ride comfort questions 
	foreach var in pa light ac push spot alone police_present {
		gen 	RI_`var' = (ride_`var' == "Sim") if (!missing(ride_`var') & ride_`var' != "NA")
		
	}
	* Adjust for phase 3 variable names
	replace RI_push = (crowded_push == "Sim") if !missing(crowded_push) & missing(RI_push)
	replace RI_spot = (avoid_crowds == "Sim") if !missing(avoid_crowds) & missing(RI_spot)

	* Are you riding with someone you know										// We'll rename to together in the codebook
	replace RI_alone = 1  if known_rider == "Sim"
	replace RI_alone = 0  if regexm(known_rider, "N")
	
	* What was offered on top -- pink or mixed?	
	gen 	CI_top_car = .
	replace CI_top_car = 1 if entity_uuid =="8a50a2f1-3e9e-45ee-af9e-27d8c85e42a6" | entity_uuid == "5cd0cafd-c927-44b9-a643-594458884077"
	replace CI_top_car = 0 if entity_uuid =="3003fbb6-754e-4f3d-91c6-c9533e9243b6" | entity_uuid == "7eb266cd-f9fc-4a2c-ba05-d79641132176"
	
/*******************************************************************************
	Clean up and save
*******************************************************************************/	
	
	compress
	
	iecodebook apply using "${doc_rider}/baseline-study/codebooks/ride.xlsx", drop
	
	order 	user_uuid session RI_pa - RI_police_present CI_top_car RI_look_pink ///
			RI_look_mixed RI_crowd_rate RI_men_present
	

	save 			 "${dt_int}/baseline_ride.dta", replace
	iemetasave using "${dt_int}/baseline_ride.txt", replace
	
*********************************************************************** That's it!
