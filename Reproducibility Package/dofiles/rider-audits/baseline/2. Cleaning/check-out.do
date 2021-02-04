/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*   				   Clean baseline survey check-out task				  	   *
********************************************************************************

	** PURPOSE:  	Clean check-out task
	
	** REQUIRES:	${dt_raw}/baseline_raw_deidentified.dta
					${doc_rider}/baseline-study/codebooks/check_out.xlsx																		
	** CREATES:	  	${dt_int}/baseline_co.dta
							
	** WRITEN BY:  Astrid Zwager [azwager@worldbank.org]	

********************************************************************************
	Load data set and keep check-out variables
*******************************************************************************/
	
	use "${dt_raw}/baseline_raw_deidentified.dta", clear

	* only keep entries that refer to check-out task
	keep if   entity_uuid == "1cd89d7c-97e7-4a93-a51e-e20f099031f9" /// PHASE 1
			| entity_uuid == "af516444-0526-407e-b802-0c1e2765651d" /// PHASE 2
		    | entity_uuid == "239a37d3-ef82-04dd-22f0-63ea-27a193e3" // PHASE 3

/*******************************************************************************
	Encode variables
*******************************************************************************/

	gen 	phase = .
	replace phase = 1 if entity_uuid == "1cd89d7c-97e7-4a93-a51e-e20f099031f9"
	replace phase = 2 if entity_uuid == "af516444-0526-407e-b802-0c1e2765651d"
	replace phase = 3 if entity_uuid == "239a37d3-ef82-04dd-22f0-63ea-27a193e3"
	
	destring ride_comfort, replace
	encode   feeling_reflection, gen(CO_feel_compare)
	
/*******************************************************************************
	Reconcile questions that were named differently in different rides
*******************************************************************************/

	foreach harassment in comments stare concern touch {
		gen 	CO_`harassment' = (ride_`harassment' == "Sim") 		if !missing(ride_`harassment')
	}
	
	replace CO_comments = (stranger_comments		== "Sim")	if !missing(stranger_comments) 			& missing(CO_comments)
	replace CO_stare	= (stranger_staring 		== "Sim")	if !missing(stranger_staring) 			& missing(CO_stare)
	replace CO_concern 	= (concern_stranger_touched == "Sim")	if !missing(concern_stranger_touched) 	& missing(CO_concern)
	replace CO_touch 	= (stranger_touched 		== "Sim")	if !missing(stranger_touched) 			& missing(CO_touch)
	
	
	gen		CO_line = user_line
	replace CO_line = exit_line if missing(CO_line)
	
	gen 	CO_station = user_station
	replace	CO_station = exit_station if missing(CO_station)

	gen 	 CO_switch = inlist("Sim", sv_switch_car, switch_cars) if (!missing(sv_switch_car) | !missing(switch_cars))
			
/*******************************************************************************
	Clean up and save
*******************************************************************************/

	iecodebook apply using "${doc_rider}/baseline-study/codebooks/check_out.xlsx", drop
	
	order 	user_uuid session phase CO_line CO_station CO_comments CO_stare CO_concern CO_touch CO_comfort
	isid 	session
	
	dropmiss, force
	compress
		
	save 			 "${dt_int}/baseline_co.dta", replace
	iemetasave using "${dt_int}/baseline_co.txt", replace
	
******************************* The end ****************************************
