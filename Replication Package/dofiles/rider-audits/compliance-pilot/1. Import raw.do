/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 				 Import and de-identify compliance pilot data			 	   *
********************************************************************************

	REQUIRES:	"${encrypt}/Compliance pilot/02212017\Contributions 02212017.csv"
				"${doc_rider}/compliance-pilot/codebooks/raw.xlsx"
	CREATES:	"${encrypt}/compliance_pilot_raw.dta"
				"${dt_raw}/compliance_pilot_deidentified.dta"
				
	WRITEN BY:  Luiza Andrade [lcardoso@worldbank.org]
	NOTES:		Access to encrypted, identified data is required to run this file
	
********************************************************************************
	Save raw data
********************************************************************************/

	import	delimited using "${encrypt}/Compliance pilot/02212017\Contributions 02212017.csv", ///
			clear bindquotes(strict) delimiters(",")
	
	compress
	
	save				"${encrypt}/compliance_pilot_raw.dta", replace
	iemetasave using	"${dt_raw}/compliance_pilot_raw.txt", short replace

/*******************************************************************************
	Corrections
*******************************************************************************/

	* Remove accents from strings
	* ---------------------------
	local oldStr "á ão ã ç é ê í ó ú Á É Í Ó Ú"
	local newStr "a ao a c e e i o u a e i o u"

	forvalue letterPos = 1/13 {
		foreach var in 	user_commute_station1  ///
						user_commute_station4 ///
						user_commute_station5 ///
						user_commute_station7 user_commute_station8 ///
						user_station1 user_station2 ///
						user_station4 user_station5 user_station6 ///
						user_station7 user_station8 ///
						user_line_phiii_cruz user_line_phiii_deodoro ///
						user_line_phiii_japeri ///
						user_line_phiii_paracambi user_line_phiii_roxo ///
						user_line_phiii_saracuruna ///
						advantages_sv_open disadvantages_sv_open ///
						exit_line exit_line_phiii_cruz exit_line_phiii_deodoro ///
						exit_line_phiii_japeri exit_line_phiii_paracambi ///
						exit_line_phiii_roxo exit_line_phiii_saracuruna {
						
			local type_var: type `var'
			if substr("`type_var'",1,1) == "s" {		
				replace `var' = regexr(`var', ///
									   "`:word `letterPos' of `oldStr''", ///
									   "`:word `letterPos' of `newStr''")
			
			}
		}
	}
 
	* Unify variables
	* ---------------
	replace user_line = using_line 							if user_line == ""
	replace user_line = exit_line 							if user_line == ""
	drop	using_line user_commute_afternoon

	* Create unified station variable
	* -------------------------------
	gen 	user_station = ""
	foreach stationCode in 1 2 4 5 7 8  {
		replace 	user_station = user_station`stationCode' 	if user_station`stationCode' != ""
	}

	foreach lineName in roxo deodoro japeri cruz saracuruna {
		local typeVar : type user_line_phiii_`lineName'
		if substr("`typeVar'",1,1) == "s" {	
			replace 	user_station = user_line_phiii_`lineName' if user_line_phiii_`lineName' != ""
		}
	}
		
	* Correct lines that don't match station
	* --------------------------------------
	replace user_line = "Ramal Santa Cruz" 	if user_station == "Campo Grande" & user_line == "Ramal Deodoro"
	replace user_line = "Ramal Japeri" 		if user_station == "Japeri" & user_line == "Ramal Deodoro"
	
	foreach var in user {
		rename 	`var'_line 		lineVar
		rename 	`var'_station 	stationVar
		do 		"${do}/ado/encode stations.do"
		rename	(lineCode stationCode) (`var'_line `var'_station)
		drop	lineVar stationVar
	}

	* Fix start time variable
	* -----------------------
	replace started = substr(started, 1, `=strpos(started, ".") -1')
	gen 	started_ = clock(started, "YMDhms")
	drop 	started
	rename 	started_ started
	format  started %tc
	
/*******************************************************************************
	Save raw data
*******************************************************************************/
	
	dropmiss, force	
	
	iecodebook apply using "${doc_rider}/compliance-pilot/codebooks/raw.xlsx", drop
	
	save 			 "${dt_raw}/compliance_pilot_deidentified.dta", replace
	iemetasave using "${dt_raw}/compliance_pilot_deidentified.txt", replace
	
********************************************************************* C'est tout!
