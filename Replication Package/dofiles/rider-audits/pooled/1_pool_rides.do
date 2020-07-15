/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*	 				 Append baseline and pilot rides				 		   *
********************************************************************************

	* REQUIRES:  	${dt_int}/compliance_pilot_merged
					${dt_int}/baseline_merged
					${doc_rider}/pooled/codebooks/pooled_rides.xlsx
	
	* CRATES:		${dt_int}/pooled_rider_audit_rides.dta

	* WRITEN BY:   Luiza Andrade

********************************************************************************
	Append data sets
********************************************************************************/

	use 		 "${dt_int}/compliance_pilot_merged", clear
	replace		 stage = 1 if missing(stage)
	rename 		 CI_joblooking CI_work
	
	append using "${dt_int}/baseline_merged"
	replace		 stage = 0 if missing(stage)
	
/*******************************************************************************
	Clean up and save
********************************************************************************/

	gen 	d_return_rider = 1 - user_new
	
	compress
	
	iecodebook apply using "${doc_rider}/pooled/codebooks/pooled_rides.xlsx"
	
	save 				"${dt_int}/pooled_rider_audit_rides.dta", replace 
	iemetasave using 	"${dt_int}/pooled_rider_audit_rides.txt", replace
	
*************************** End of do file *************************************
