/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*				 Transform congestion data to station level			 	 	   *
********************************************************************************

	REQUIRES:	"${encrypt}/congestion_raw.dta"
	CREATES:	"${dt_final}/congestion_station_level.dta"
				"${dt_int}/congestion_station_level_wide.dta"
	WRITEN BY:  Luiza Andrade [lcardoso@worldbank.org]
	
	NOTES:		Access to encrypted, identified data is required to run this file
	
********************************************************************************
*							PART 0:  Open raw data							   *
********************************************************************************/
	
	use "${encrypt}/congestion_raw.dta", clear
	

********************************************************************************
*								PART 1:  Clean-up							   *
********************************************************************************

	* Drop lines that only work after 8 PM
	drop if inlist(substr(linha,1,4),"SCZP","JRIP")	
	
	* Drop circular honorio - not present in rides data
	drop if substr(linha,1,3) == "HON"
	
	* Adjust var formats
	foreach varAux of varlist boardings exits seatprob {
		replace `varAux' = subinstr(`varAux',"-","",.)
		replace `varAux' = strtrim(`varAux')
		destring (`varAux'), replace
	}
	
	* Drop null station/line combinations
	drop if exits == . & boardings == .
	
	
	
********************************************************************************
*			PART 2:  Create variables to match with premise data			   *
********************************************************************************	
	
	* Train direction
	* ---------------
	gen 	CI_direction = (substr(linha,-1,1) == "I")
	replace CI_direction = . if CI_direction == 0 & substr(linha,-1,1) != "P"

	* Line code
	* ---------
	gen CI_line = .
	foreach lineName in DEO SCZ JRI BRX SAR GRM PBI CGE NIU NLS QMO {

		if "`lineName'" == "DEO" 						local lineCode = 1
		if inlist("`lineName'","SCZ","CGE") 			local lineCode = 2
		if inlist("`lineName'","JRI","NIU","NLS","QMO") local lineCode = 3
		if "`lineName'" == "BRX" 						local lineCode = 4
		if inlist("`lineName'","SAR","GRM") 			local lineCode = 5
		if "`lineName'" == "PBI" 						local lineCode = 6
		
		replace CI_line = `lineCode' if substr(linha,1,3) == "`lineName'"
		
	}
	
	* Station code
	* ------------
	gen CI_station = .
	
	qui levels labeli, local(stations)
	foreach stationName of local stations {
		if "`stationName'" == "BRX" 	local stationCode  419     
		if "`stationName'" == "CRA" 	local stationCode  418  
		if "`stationName'" == "AGO" 	local stationCode  417     
		if "`stationName'" == "VRO" 	local stationCode  416     
		if "`stationName'" == "PVN" 	local stationCode  415     
		if "`stationName'" == "COB" 	local stationCode  414     
		if "`stationName'" == "BFO" 	local stationCode  413     
		if "`stationName'" == "HON" 	local stationCode  412     
		if "`stationName'" == "RMA" 	local stationCode  411     
		if "`stationName'" == "MMA" 	local stationCode  410     
		if "`stationName'" == "CAV" 	local stationCode  409     
		if "`stationName'" == "TOM" 	local stationCode  408     
		if "`stationName'" == "PLA" 	local stationCode  407     
		if "`stationName'" == "DEL" 	local stationCode  406     
		if "`stationName'" == "JAR" 	local stationCode  405     
		if "`stationName'" == "DEO" 	local stationCode  119 208 307   
		if "`stationName'" == "MHS" 	local stationCode  118     
		if "`stationName'" == "BRO" 	local stationCode  117     
		if "`stationName'" == "OCZ" 	local stationCode  116     
		if "`stationName'" == "MAD" 	local stationCode  115 207 306   
		if "`stationName'" == "CAS" 	local stationCode  114     
		if "`stationName'" == "QTO" 	local stationCode  113     
		if "`stationName'" == "PIE" 	local stationCode  112     
		if "`stationName'" == "EDO" 	local stationCode  111 305 206   
		if "`stationName'" == "MER" 	local stationCode  110     
		if "`stationName'" == "SFE" 	local stationCode  205 304   
		if "`stationName'" == "ENO" 	local stationCode  109     
		if "`stationName'" == "SPO" 	local stationCode  108     
		if "`stationName'" == "RIA" 	local stationCode  107     
		if "`stationName'" == "SFX" 	local stationCode  106 204
		if "`stationName'" == "MAR" 	local stationCode  104 403 203  303 503
		if "`stationName'" == "SCO" 	local stationCode  103 402 202  302 502
		if "`stationName'" == "PBA" 	local stationCode  102     
		if "`stationName'" == "CBL" 	local stationCode  101 401 201  301 501
		if "`stationName'" == "JRI" 	local stationCode  320 619
		if "`stationName'" == "EPA" 	local stationCode  319     
		if "`stationName'" == "QMO" 	local stationCode  318     
		if "`stationName'" == "AUS" 	local stationCode  317     
		if "`stationName'" == "CSS" 	local stationCode  316     
		if "`stationName'" == "NIU" 	local stationCode  315     
		if "`stationName'" == "JUS" 	local stationCode  314     
		if "`stationName'" == "MES" 	local stationCode  313     
		if "`stationName'" == "EPS" 	local stationCode  312     
		if "`stationName'" == "NLS" 	local stationCode  311     
		if "`stationName'" == "OLI" 	local stationCode  310     
		if "`stationName'" == "ACT" 	local stationCode  309     
		if "`stationName'" == "RIC" 	local stationCode  308     
		if "`stationName'" == "SCZ" 	local stationCode  224     
		if "`stationName'" == "TNS" 	local stationCode  223     
		if "`stationName'" == "PAC"	 	local stationCode  222     
		if "`stationName'" == "COS" 	local stationCode  221     
		if "`stationName'" == "IBA" 	local stationCode  220     
		if "`stationName'" == "BME" 	local stationCode  219     
		if "`stationName'" == "CGE" 	local stationCode  218     
		if "`stationName'" == "AVS" 	local stationCode  217     
		if "`stationName'" == "STO" 	local stationCode  216     
		if "`stationName'" == "SEN" 	local stationCode  215     
		if "`stationName'" == "BGU" 	local stationCode  214     
		if "`stationName'" == "GSA" 	local stationCode  213     
		if "`stationName'" == "PML" 	local stationCode  212     
		if "`stationName'" == "REA" 	local stationCode  211     
		if "`stationName'" == "MGA" 	local stationCode  210     
		if "`stationName'" == "VMR" 	local stationCode  209     
		if "`stationName'" == "SAR" 	local stationCode  520     
		if "`stationName'" == "JPR" 	local stationCode  519     
		if "`stationName'" == "CEL" 	local stationCode  518     
		if "`stationName'" == "GRM" 	local stationCode  517     
		if "`stationName'" == "COO" 	local stationCode  516     
		if "`stationName'" == "DCX" 	local stationCode  515     
		if "`stationName'" == "VGL" 	local stationCode  514     
		if "`stationName'" == "LUC" 	local stationCode  513     
		if "`stationName'" == "COR" 	local stationCode  512     
		if "`stationName'" == "BPA" 	local stationCode  511     
		if "`stationName'" == "PCR" 	local stationCode  510     
		if "`stationName'" == "PEN" 	local stationCode  509     
		if "`stationName'" == "OLA" 	local stationCode  508     
		if "`stationName'" == "RMS" 	local stationCode  507     
		if "`stationName'" == "BSS" 	local stationCode  506     
		if "`stationName'" == "MGS" 	local stationCode  505     
		if "`stationName'" == "TRI" 	local stationCode  504 404    
		if "`stationName'" == "PBI" 	local stationCode  621     
		if "`stationName'" == "LAJ" 	local stationCode  620           
		
		foreach station in `stationCode' {
			replace CI_station = `station' if labeli == "`stationName'" & ///
														(CI_line == floor(`station'/100) | ///
														CI_line/10 == floor(`station'/100))
		}			
	}

	drop if CI_line > 5
	
********************************************************************************
*							PART 3:  Check variables
********************************************************************************

	foreach varAux of varlist month_merge year CI_direction CI_line CI_station {
		qui 	count if `varAux' == .
		assert	`r(N)' == 0
	}
	
********************************************************************************
*						PART 4:  Collapse overlaping lines					   *
********************************************************************************
	
	collapse 	(mean) boardings exits lengthkm loadfact seatprob speedkmhr timemin volume, ///
				by	   (CI_line CI_station CI_direction hora month_merge year)
	
	replace loadfact = round(loadfact, .01)	// rounding was causing the number of unique values to change
				
********************************************************************************
*							PART 5:  Label variables						   *
********************************************************************************

	rename loadfact		CI_loadfact
		
	lab var	boardings	"No of people entering car"
	lab var	exits		"No of people exiting car"
	lab var	lengthkm	"Distance traveled"
	lab var	CI_loadfact	"Load factor at check-in station"
	lab var seatprob	"Probability of seating"
	lab var	speedkmhr	"Speed (km/h)"
	lab var timemin		"Time of travel (minutes)"
	lab var volume		"No of people in the car"


********************************************************************************
*							  PART 6:  Save data							   *
********************************************************************************

	compress 
	
	save 				"${dt_final}/congestion_station_level.dta", replace
	iemetasave 	using 	"${dt_final}/congestion_station_level.txt", replace
	
********************************************************************************
*						 	 PART 7:  Reshape data							   *
********************************************************************************

	* Reshapes data set to wide so we can merge it and calculate congestion
	* and time of travel througout the whole ride
	
	* Keep variables we're using
	keep 	hora month_merge year CI_direction CI_station ///
			lengthkm timemin
	
	* Rename so the wide name is clearer
	foreach varAux of varlist lengthkm timemin {
		rename `varAux' `varAux'_
	}
	
	* Reshape
	reshape wide 	lengthkm_ timemin_, ///
					i(hora month_merge year CI_direction) ///
					j(CI_station)

	* Save wide version
	save 				"${dt_int}/congestion_station_level_wide.dta", replace
	iemetasave 	using 	"${dt_int}/congestion_station_level_wide.txt", replace
	
********************************************************************************
