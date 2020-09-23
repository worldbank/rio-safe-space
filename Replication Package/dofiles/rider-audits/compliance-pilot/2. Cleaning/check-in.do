/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 				 Clean compliance pilot check-in survey task			 	   *
********************************************************************************

	REQUIRES:	${dt_raw}/compliance_pilot_deidentified.dta
				${doc_rider}/compliance-pilot/codebooks/check_in.xlsx
	CREATES:	${dt_int}/compliance_pilot_ci.dta
	
	WRITEN BY:  Luiza Andrade [lcardoso@worldbank.org]
	
********************************************************************************
	Load data and select variables
********************************************************************************/

	use 	"${dt_raw}/compliance_pilot_deidentified.dta", clear
	keep 	if task == "Checkin"												// Select check-in data
	
	* Keep only demo task vars
	* ------------------------
	keep 	user_line user_station* user_uuid session user_feeling work_or_looking ///
			campaign_id compliance* fifty_seventy_* ninety_hundred_* ///
			seventy_ninety_* ten_thirty_* thirty_fifty_* zero_ten_* group ///
			coming_looking_work checkin_habit started


/*******************************************************************************
	 Generate premium values 		   			   
*******************************************************************************/
	
	gen 	premium = .
	replace premium = 0 	if inlist(campaign_id,"cdc.v1.BR.RIO.sv2.phase1.new", ///
												  "cdc.v1.BR.RIO.sv2.phase1.return")	
	replace premium = -60	if campaign_id == "cdc.v1.BR.RIO.sv2.phase2.new.block1.groupA"
	replace premium = 60	if campaign_id == "cdc.v1.BR.RIO.sv2.phase2.new.block1.groupB"
	replace premium = 0 	if campaign_id == "cdc.v1.BR.RIO.sv2.phase2.new.block2"
	replace premium = 10 	if campaign_id == "cdc.v1.BR.RIO.sv2.phase2.new.block3"
	replace premium = 10	if campaign_id == "cdc.v1.BR.RIO.sv2.phase2.new.block4"
	replace premium = 10	if campaign_id == "cdc.v1.BR.RIO.sv2.phase2.new.block5"
	replace premium = 10	if campaign_id == "cdc.v1.BR.RIO.sv2.extra10ctrides.new"	
	replace premium = 60 	if campaign_id == "cdc.v1.BR.RIO.sv2.phase2.return.block1"
	replace premium = 10 	if campaign_id == "cdc.v1.BR.RIO.sv2.phase2.return.block2"
	replace premium = 10	if campaign_id == "cdc.v1.BR.RIO.sv2.phase2.return.block3"
	replace premium = 10	if campaign_id == "cdc.v1.BR.RIO.sv2.extra10ctrides.return"
	drop	campaign_id

/*******************************************************************************
	Encode variables		  			   
*******************************************************************************/
			
	encode checkin_habit, gen(CI_frequency)
	
	* Dummy for looking for work
	* --------------------------
	replace work_or_looking = coming_looking_work if missing(work_or_looking)
	replace work_or_looking = proper(work_or_looking)
	gen 	CI_commute		= regex(work_or_looking, "Sim") if !missing(work_or_looking)
	
	
	* Compliance variables
	* --------------------
	foreach carType in mixed pink {
	
		* Replace category by median of the bin (first version of questinnaire)
		gen 	CI_men_present_`carType' = .
		replace CI_men_present_`carType' = 0.05 if compliance_`carType'car == "zero_ten"
		replace CI_men_present_`carType' = 0.20 if compliance_`carType'car == "ten_thirty"
		replace CI_men_present_`carType' = 0.40 if compliance_`carType'car == "thirty_fifty"
		replace CI_men_present_`carType' = 0.60 if compliance_`carType'car == "fifty_seventy"
		replace CI_men_present_`carType' = 0.80 if compliance_`carType'car == "seventy_ninety"
		replace CI_men_present_`carType' = 0.95 if compliance_`carType'car == "ninety_hundred"
		drop 	compliance_`carType'car

		* Smaller bins (second version of questionnaire)
		foreach varAux of varlist 	fifty_seventy_`carType' ninety_hundred_`carType' ///
									seventy_ninety_`carType' ten_thirty_`carType' ///
									thirty_fifty_`carType' zero_ten_`carType' {
			replace 	`varAux' = substr(`varAux',-3,2) if `varAux' != "0%"
			replace 	`varAux' = "0" if `varAux' == "0%"
			destring 	`varAux', replace
			replace		CI_men_present_`carType' = `varAux'/100 if `varAux' != .
		}
	}

		
********************************************************************************
*								PART 10: Clean up and save
********************************************************************************

	compress
	dropmiss, force
	
	iecodebook apply using "${doc_rider}/compliance-pilot/codebooks/check_in.xlsx", drop
	
	order 	user_uuid session CI_line CI_station CI_frequency CI_feel_level premium
	
	save 			 "${dt_int}/compliance_pilot_ci.dta", replace
	iemetasave using "${dt_int}/compliance_pilot_ci.txt", replace

********************************************************************* C'est fini!
