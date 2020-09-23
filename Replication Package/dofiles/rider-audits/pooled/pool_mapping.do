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
	
	iecodebook append `baseline' `pilot' using "${doc_rider}/pooled/codebooks/mapping.xlsx", ///
			   surveys(baseline pilot) clear
	
	gen 	time_station_bin = station_bin * 1000 + time_bin 
	drop if station_bin == .	// drop stations that are not in the rides sample


/*******************************************************************************
	Collapse data set into time-station bin level
********************************************************************************/

	collapse  	(mean) 	 MA_men_present*  /// 
				(median) pct_standing*, ///
				by		(station_bin time_bin time_station_bin)
				
/********************************************************************************
	Save data set
********************************************************************************/
	
	iecodebook apply using	"${doc_rider}/pooled/codebooks/pooled_mapping.xlsx", drop
	
	order time_station_bin time_bin station_bin
	
	compress
	
	label data "Platform observations | ID var = 'time_station_bin'"
	
	iecodebook export 	using "${doc_rider}/platform-observations-dictionary.xlsx", replace
	
	save 				"${dt_final}/platform-observations.dta"	, replace
	iemetasave using  	"${dt_final}/platform-observations.txt", replace
	
****************************** End of do-file **********************************
