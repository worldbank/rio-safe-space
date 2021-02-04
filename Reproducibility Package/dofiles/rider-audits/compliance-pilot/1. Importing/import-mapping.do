/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*		  	 	Clean compliance pilot platform observations		 		   *
********************************************************************************

	* REQUIRES:  	${encrypt}/Compliance pilot/02212017/Mapping 02212017
					${doc_rider}/compliance-pilot/codebooks/mapping.xlsx
	* CREATES:		${dt_int}/compliance_pilot_mapping.dta
				  
	* WRITEN BY:   Luiza Andrade [lcardoso@worldbank.org]
	
********************************************************************************
*	Import mapping data
********************************************************************************/

// Load data -------------------------------------------------------------------

	import 	delimited using "${encrypt}/Compliance pilot/02212017/Mapping 02212017", ///
				delim (",")  varnames(1) clear

	isid obs_uuid, sort

// Corrections: some observations have missing lines and stations --------------
		
	replace station = "Central do Brasil" if missing(station) & ///
		inlist("central", user_station1, user_station2, user_station3, user_station4, ///
						  user_station5, user_station6, user_station7, user_station8)
	replace station = strproper(user_station7)  if inlist(user_station7, "queimados", "austin")
	replace station = "Nova Iguacu"				if user_station7 == "nova_iguacu"
	replace station = "Comendador Soares"		if user_station7 == "comendador_soares"
	replace station = "Ricardo de Albuquerque"	if user_station7 == "ricardo_de_albuquerque"

	
// De-identify: remove station and line names ----------------------------------

	rename 	line 		lineVar
	rename 	station 	stationVar
	do 		"${do}/ado/encode stations.do"
	rename	(lineCode stationCode) (line station)
	drop	lineVar stationVar

// Save variables in a more efficient format -----------------------------------

	* Date of obsevation 
	split 		created_at, p("")
	split 		created_at1, p("-")
	destring 	created_at11 created_at12 created_at13, replace
	split 		created_at2, p(":")
			
	gen double 	MA_date = mdy(created_at12, created_at13, created_at11)
	format 		MA_date 	%td
			
	* Categorical variables for congestion and compliance
	foreach var in 	regular_ride_men_present pink_ride_men_present ///
					regular_ride_crowd pink_ride_crowd police_present ///
					time_bin {
					
		encode 	`var', gen(`var'_)
		drop	`var'
		
	}

// Clean up and save -----------------------------------------------------------

	* Label variables and remove redundancies 
	iecodebook apply using "${doc_rider}/compliance-pilot/codebooks/mapping.xlsx", drop

	order line station, after(time_bin)
	compress

	* Save
	save 			 "${dt_int}/compliance_pilot_mapping.dta", replace
	iemetasave using "${dt_int}/compliance_pilot_mapping.txt", replace
		
***************************************************************** End of do-file


