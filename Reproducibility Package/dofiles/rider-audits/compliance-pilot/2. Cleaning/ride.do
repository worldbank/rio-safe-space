/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 				    Clean compliance pilot ride survey task			 	       *
********************************************************************************
	
	REQUIRES:	${dt_raw}/compliance_pilot_deidentified.dta
				${doc_rider}/compliance-pilot/codebooks/ride.xlsx
	CREATES:	${dt_int}/compliance_pilot_ride.dta
	
	WRITEN BY:  Luiza Andrade [lcardoso@worldbank.org]
	
********************************************************************************
*					PART 0:  Load data and select variables					   *
********************************************************************************/

	use 	"${dt_raw}/compliance_pilot_deidentified.dta", clear
	keep 	if task == "Ride"													// Select ride data
	
	* Generate a variable for the phase 
	* ---------------------------
	encode 		stage, gen(phase)
	
	* Keep only demo task vars
	* ------------------------
	keep 	entity_uuid user_uuid session ride* phase crowded_push known_rider ///
			studied_fem_car studied_mix_car approx_percent_men spec_translated ///
			started
	drop 	ride_comments ride_stare ride_concern ride_touch ride_comfort ///
			entity_uuid
		

********************************************************************************
*					PART 1:  Complete missing observations 			 	 	   *
********************************************************************************
	
	* These variables are the same, but Premise exported them with diffente names
	* in different submissions	
	foreach var in 	ride_alone ride_push ride_men_present {
												
		local	ride_aloneSub		known_rider
		local	ride_pushSub		crowded_push
		local	ride_spotSub		avoid_crowds
		local	ride_men_presentSub	approx_percent_men
		
		local typeVar: type `var'
		if substr("`typeVar'",1,1) != "s" {
			tostring 	`var', replace
		}
		
		local typeSub : type  ``var'Sub'
		if substr("`typeSub'",1,1) == "s" {	
			replace		`var' = ``var'Sub'		if `var' == ""
			drop 		``var'Sub'
		}
		else {
			drop 		``var'Sub'
		}
	}	
	
********************************************************************************
*						PART 2:  Create dummy variables 			 	 	   *
********************************************************************************

	rename 		studied_fem_car		ride_look_pink
	rename 		studied_mix_car 	ride_look_mixed
	rename 		ride_alone 			ride_together
		
	foreach varAux in 	pa light ac push spot together police_present look_pink ///
						look_mixed {
		gen 		RI_`varAux' = (ride_`varAux' =="Sim" )
		replace 	RI_`varAux' = . if ride_`varAux'=="" | ride_`varAux'=="NA"
		drop 		ride_`varAux' 
		
	}
	
	gen			CI_women_car	= (spec_translated == "Women Only Car")

********************************************************************************
*							PART 4:  Encode variables 				 	 	   *
********************************************************************************
	
	encode	ride_crowd_rate, 	gen(RI_crowd_rate)
	encode	ride_men_present, 	gen(RI_men_present)
	
********************************************************************************
*								PART 9:  Save data						   	   *
********************************************************************************

	dropmiss, force
	compress
	
	iecodebook apply using "${doc_rider}/compliance-pilot/codebooks/ride.xlsx", drop

	order 	user_uuid session phase RI_pa - RI_police_present
	sort 	session

	save 			 "${dt_int}/compliance_pilot_ride.dta", replace
	iemetasave using "${dt_int}/compliance_pilot_ride.txt", replace
	
********************************************************************* C'est fini!
