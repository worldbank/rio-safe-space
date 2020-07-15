/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*	 				 Import and de-identify baseline data			 		   *
********************************************************************************

	REQUIRES:	"${encrypt}/Baseline/07112016/Contributions 07112016"
				"${doc_rider}/baseline-study/codebooks/raw.xlsx"
				"${doc_rider}/baseline-study/codebooks/raw_deidentify.xlsx"
	CREATES:	"${encrypt}/baseline_raw.dta"
				"${dt_raw}/baseline_raw_deidentified.dta"
				
	WRITEN BY:  Luiza Andrade [lcardoso@worldbank.org]
	
	NOTES:		Access to encrypted, identified data is required to run this file
	
********************************************************************************
	Import raw data and save as dta
********************************************************************************/
	
	import delimited using "${encrypt}/Baseline/07112016/Contributions 07112016", delim (",")  varnames(1) clear
	
	* ----------------
	* Make corrections
	* ----------------
	
	preserve
	
		import delimited using "${doc_rider}/baseline-study/demo-data-corrections.csv", encoding(utf8) clear 
		
		tempfile demo_corr
		save	`demo_corr'

	restore
	
	merge m:1 user_uuid using `demo_corr', assert(1 3) nogen
	
	drop if drop_user == 1 														// drop users that are found to be fraudulent
	
	replace user_gender = user_gender_corr if !missing(user_gender_corr)
	
	* -----------------
	* Clean up and save
	* -----------------
	
	iecodebook apply using "${doc_rider}/baseline-study/codebooks/raw.xlsx", drop

	compress
		
	save 			 "${encrypt}/baseline_raw.dta", replace
	iemetasave using "${dt_raw}/baseline_raw.txt", short replace

	
/*******************************************************************************
	Unify station variables
	- Different station variables were created originally, one for each line
	- Variable names also changed across between data handovers from app firm
*******************************************************************************/
	
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
	
/*******************************************************************************
	Stations not linked to a line
*******************************************************************************/
	
	foreach var in user exit {	
	
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

/*******************************************************************************
	Save
*******************************************************************************/

	compress
	dropmiss, force
	
	iecodebook apply using "${doc_rider}/baseline-study/codebooks/raw_deidentify.xlsx", drop
	
	
	save 			 "${dt_raw}/baseline_raw_deidentified.dta", replace
	iemetasave using "${dt_raw}/baseline_raw_deidentified.txt", replace
	
********************************************************************* C'est tout!
