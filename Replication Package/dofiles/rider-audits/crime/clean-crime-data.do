/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*	 				 Append baseline and pilot rides				 		   *
********************************************************************************

	* REQUIRES:  	${dt_raw}/crime/PopulacaoEvolucaoMensalCisp.csv // From instituto de segurança pública do Rio de Janeiro
					${dt_raw}/crime/BaseDPEvolucaoMensalCisp.csv	// From instituto de segurança pública do Rio de Janeiro
					${encryptcrime}/dps_stations.xlsx				// Created by mering shapefiles from instituto de segurança pública do Rio de Janeiro and station gps data
					${encryptcrime}/stations_code.dta
	* CREATES:		${dt_int}/crime_rates_bystation
	
	* NOTES:		Central station has two GPS locations
	
	* WRITEN BY:   	Luiza Andrade

********************************************************************************
*						   PART 1:  Get population							   *
********************************************************************************/
	
	import delimited "${dt_raw}/crime/PopulacaoEvolucaoMensalCisp.csv", ///
		delimiter(";") encoding(utf8) clear 
	
	* Fix population variables (in Brazil "," separates decimals)
	gen 		pop = subinstr(pop_circ, ",", ".", .)
	destring 	pop, replace
	
	drop pop_circ
	
	* Rename police station variable to match other data set
	rename circ cisp
	
	* Save tempfile
	tempfile pop
	save `pop'
	
********************************************************************************
*					   PART 2:  Absolute crime values						   *
********************************************************************************

	import delimited "${dt_raw}/crime/BaseDPEvolucaoMensalCisp.csv", ///
		encoding(utf8) clear 
	
	* Create indicators we're interested in
	egen 	allcrime = rowtotal(hom_doloso-registro_ocorrencias) 					// All crimes
	egen 	theft = rowtotal(total_furtos total_roubos)							// Crimes against property
	egen 	violent = rowtotal(hom_doloso lesao_corp_morte latrocinio ///   	   Violent crimes
					 		   hom_por_interv_policial tentat_hom ///
							   lesao_corp_dolosa)
	gen 	rape = estupro														// Rape
	
********************************************************************************
*					   PART 3:  Crimes per 100 000 people					   *
********************************************************************************
	
	* Merge to population
	merge 1:1 cisp mes vano using `pop', nogen
	
	* Calculate rate
	foreach crime in allcrime violent rape theft {
		gen rate_`crime' = (`crime' * 100000)/pop
	}
	
	* Average per year (from month)
	collapse (mean) rate*, by(cisp vano)
	
	* Only 2015 (double check)
	keep if vano == 2015
	
	* Save tempfile
	tempfile crime_data
	save `crime_data'
	
********************************************************************************
*					      PART 4: Cross DPs and stations					   *
********************************************************************************
	
	* Correspondence of DPs and stations (calculated using shapefiles)
	import excel "${encryptcrime}/dps_stations.xlsx", sheet("Sheet1") firstrow clear
	
	* Clean names from Shapefile
	rename 		DP cisp
	replace 	   cisp = subinstr(cisp, "S", "", .)
	replace 	   cisp = subinstr(cisp, "I", "", .)
	replace 	   cisp = subinstr(cisp, " DP", "", .)
	destring 	   cisp, replace
	
	* Merge to crime stats
	merge m:1 cisp using `crime_data', assert(2 3) nogen keep(3)
	
	* Central do Brasil has two GPS locations, so getting the average of both police stations
	collapse (mean) rate_allcrime rate_violent rate_rape rate_theft, by(station)
	
	merge 1:m station using "${encryptcrime}/stations_code.dta", assert(1 3) keep(3) nogen // stations that did not merge are not in our sample
	
	drop 	   station
	order 	CI_station
	isid 	CI_station
	
	compress
	
	save 				"${dt_int}/crime_rates_bystation.dta", replace	
	iemetasave using 	"${dt_int}/crime_rates_bystation.txt", replace
	
************************************************************************ The end
