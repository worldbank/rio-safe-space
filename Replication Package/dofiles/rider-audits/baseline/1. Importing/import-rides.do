/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*	 				 Import and de-identify baseline data			 		   *
********************************************************************************

	REQUIRES:	"${encrypt}/Baseline/07112016/Contributions 07112016"
				"${doc_rider}/baseline-study/codebooks/raw.xlsx"
				"${doc_rider}/baseline-study/raw-duplicates.xlsx"
				"${doc_rider}/baseline-study/codebooks/raw_deidentify.xlsx"
	CREATES:	"${encrypt}/baseline_raw.dta"
				"${dt_raw}/baseline_raw_deidentified.dta"
				
	WRITEN BY:  Luiza Andrade [lcardoso@worldbank.org]
	
	NOTES:		Access to encrypted, identified data is required to run this file
				Station and line NAMES are considered identifying data
	
********************************************************************************
	1 RIDES DATA
********************************************************************************/
	
// Import to Stata format ======================================================
	import delimited using "${encrypt}/Baseline/07112016/Contributions 07112016", ///
		delim (",") ///
		bindquotes(strict) ///
		varnames(1) ///
		clear  
	
	* Label variables
	iecodebook apply using "${doc_rider}/baseline-study/codebooks/raw.xlsx", drop

	* There are two duplicated values for obs_uid, each with two submissions.
	* All four entries are demographic survey from the same user, who seems to 
	* have submitted the data twice, each time creating two entries. 
	* Possibly a connectivity issue
	ieduplicates obs_uid using "${doc_rider}/baseline-study/raw-duplicates.xlsx", uniquevars(v1) keepvars(created submitted started)

	* Save in Stata format
	isid user_uuid obs_uid, sort
	compress
	dropmiss, force
		
	save 			 "${encrypt}/baseline_raw.dta", replace
	iemetasave using "${dt_raw}/baseline_raw.txt",  replace short

	
// Corrections =================================================================

/*	Unify station variables: ---------------------------------------------------
	station names were originally saved in different variables, one for each line. 
	Variable names also changed across between data handovers from app firm */
	
	* From demographic survey
	foreach var in user user_commute user_home {
		gen 			`var'_station = ""
		
		forvalues station = 1/9  {
			cap replace `var'_station = `var'_station`station' if !missing(`var'_station`station')
		}
	}
	
	replace user_line = using_line if missing(user_line) & !missing(using_line)
	
	* From ride tasks
	gen exit_station = ""
	foreach line in roxo deodoro japeri cruz saracuruna teleferico {
			replace exit_station = exit_line_phiii_`line' if !missing(exit_line_phiii_`line')
		cap replace user_station = user_line_phiii_`line' if !missing(user_line_phiii_`line')
	}
	
/*	Stations not linked to a line ----------------------------------------------
	Line was missing for some stations for an unknown reason. These cases were
	corrected by looking up the SuperVia sation map. */
	
	rename user_line_home user_home_line
	
	foreach var in user exit user_home {	
	
		replace `var'_line = "Ramal Santa Cruz" if 	(inlist(`var'_station, "Inhoaiba", ///
																		   "Inhoaíba", ///
																		   "Benjamin do Monte", ///
																		   "Santa Cruz") ///
														  & `var'_line == "Ramal Deodoro")
		
		replace `var'_line = "Ramal Saracuruna" if 	(inlist(`var'_station, "Gramacho","BrÃ¡s de Pina") ///
														  & `var'_line == "Ramal Deodoro")
		replace `var'_line = "Ramal Japeri" 	if 	(inlist(`var'_station, "Japeri", "Austin") ///
														  & `var'_line == "Ramal Deodoro")
														  
		replace `var'_line = "Ramal Saracuruna" if 	(`var'_station == "Manguinhos"	 	& `var'_line == "Ramal Belford Roxo")
		replace `var'_line = "Ramal Saracuruna" if 	(`var'_station == "Penha" 		 	& `var'_line != "Ramal Saracuruna")
		replace `var'_line = "Ramal Santa Cruz" if  (`var'_station == "Campo Grande" 	& `var'_line != "Ramal Santa Cruz")
		replace `var'_line = "Ramal Saracuruna" if 	(`var'_station == "Parada de Lucas" & `var'_line == "Ramal Santa Cruz")
		replace `var'_line = "Ramal Paracambi" 	if 	(`var'_station == "Lages" 		  	& `var'_line == "Ramal Deodoro")
		replace `var'_line = "Ramal Japeri" 	if 	(`var'_station == "Nova IguaÃ§u" 	& `var'_line == "Ramal Belford Roxo")
		
		* Encode stations
		rename 	`var'_line 		lineVar
		rename 	`var'_station 	stationVar
		do 		"${do}/ado/encode stations.do"
		rename	(lineCode stationCode) (`var'_line `var'_station)
		drop	lineVar stationVar

	}
	
	* Got right station from geolocation when check-in and check-out stations were the same
	merge m:1 session spectranslated using "${doc_rider}/baseline-study/station_corrections.dta", ///
			  update replace ///
			  assert(1 4 5) ///
			  nogen
	
//	Save =======================================================================

	* Corrected, identified data
	isid user_uuid obs_uid, sort
	compress
	dropmiss, force

	save 			 "${encrypt}/baseline_raw_corrected.dta", replace
	iemetasave using "${dt_raw}/baseline_raw_corrected.txt", short replace
	

//	Deidentify =================================================================

	* Remove identifying variables
	iecodebook apply using "${doc_rider}/baseline-study/codebooks/raw_deidentify.xlsx", drop
	
	isid user_uuid obs_uid, sort
	compress
	dropmiss, force
	
	save 			 "${dt_raw}/baseline_raw_deidentified.dta", replace
	iemetasave using "${dt_raw}/baseline_raw_deidentified.txt", replace
	
********************************************************************* C'est tout!
