/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*		    Append baseline and pilot platoform observations surveys		   *
********************************************************************************

	REQUIRES: ${dt_rider_int}/baseline_mapping.dta
			  ${dt_rider_int}/compliance_pilot_mapping.dta
	CREATES:  ${dt_rider_fin}/pooled_mapping.dta
	
	WRITTEN BY: Luiza Andrade
	
********************************************************************************
	Merge data sets
********************************************************************************/

	use 	 "${dt_int}/baseline_mapping.dta", clear
	tempfile baseline
	save    `baseline'
	
	use 	"${dt_int}/compliance_pilot_mapping.dta", clear
	tempfile pilot
	save 	`pilot'
	
	iecodebook append `baseline' `pilot' using "${doc_rider}/pooled/codebooks/mapping.xlsx", surveys(baseline pilot) clear
	
	drop if station_bin == .	// drop stations that are not in the rides sample

/*******************************************************************************
	Turn crowd rate into a continuous variable
********************************************************************************/

	foreach car in mix pink {
		gen 	pct_standing_`car' 	= `car'_car_congestion
		recode	pct_standing_`car'	(1 = 0) (2 = 25) (3 = 50) (4 = 90)
		lab var pct_standing_`car'	"Percent of passengers who are standing"
		
		gen 	MA_men_present_`car' = .
		replace MA_men_present_`car' = .5 	if `car'_car_compliance == 1
		replace MA_men_present_`car' = .2 	if `car'_car_compliance == 2
		replace MA_men_present_`car' = .4 	if `car'_car_compliance == 3 
		replace MA_men_present_`car' = .6 	if `car'_car_compliance == 4
		replace MA_men_present_`car' = .8 	if `car'_car_compliance == 5
		replace MA_men_present_`car' = .05 	if `car'_car_compliance == 6
		
	}

/*******************************************************************************
	Collapse data set into time-station bin level
********************************************************************************/

	collapse  	(mean) 	 MA_men_present*  /// 
				(median) pct_standing*, ///
				by		(station_bin time_bin)
				
/********************************************************************************
	Save data set
********************************************************************************/
	
	iecodebook apply using	"${doc_rider}/pooled/codebooks/pooled_mapping.xlsx", drop
	
	order time_bin station_bin
	
	compress
	
	save 				"${dt_final}/pooled_mapping.dta"	, replace
	iemetasave using  	"${dt_final}/pooled_mapping.txt", replace
	
****************************** End of do-file **********************************
