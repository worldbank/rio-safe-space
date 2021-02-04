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

	* Drop lines that only work after 8 PM - not rides data is collected outside of rush hour
	drop if inlist(substr(linha,1,4),"SCZP","JRIP")	
	
	* Drop circular honorio - not present in rides data
	drop if substr(linha,1,3) == "HON"
	
	* Adjust var formats - some missing observations are marked as "-", 
	* which causes Stata to read the variable as a string, not a number
	foreach varAux of varlist boardings exits seatprob {
		replace `varAux' = subinstr(`varAux',"-","",.)	// remove dash character
		replace `varAux' = strtrim(`varAux') 		// remove spaces
		destring (`varAux'), replace 			// now it can be converted into a number
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

	do "${encode}/encode-congestion-stations.do"
	
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
