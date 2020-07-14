/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*							 Sample description								   *
********************************************************************************

	OUTLINE:	PART 1:   Prepare data
				PART 1.1: Merges data sets
				PART 1.2: Table-specific labels
				PART 2:   Calculate balance
				PART 2.1: Variables present in all surveys
				PART 2.2: Variables asked only to women
				PART 2.3: Merge all variables and format table
				PART 3:   Export table
				
	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
				${dt_final}/platform_survey_constructed.dta
																			
	CREATES:	${out_tables}/balance_table.tex	

	WRITEN BY:   Luiza Andrade [lcardoso@worldbank.org]
	
********************************************************************************
	PART 1: Prepare data
*******************************************************************************/

* ------------------------------------------------------------------------------
* 	PART 1.1: Merges data sets
* ------------------------------------------------------------------------------
	
	if "${star}" == "nostar" local star starsnoadd
	
	* ------
	* Riders
	* ------
	use "${dt_final}/pooled_rider_audit_constructed.dta", clear

	* Rename variables to match platform survey
	keep	user_id 	${balancevars1} ${balancevars2}	stage
	rename 	user_id 	id

	* This data set is at ride level. Make it rider-stage level: if a user is 
	* present in the two recruitment waves, she gets double the weight
	duplicates drop
	isid id stage
	
	* Add identifying variable to distinguish this data from the platform survey
	gen balance_group 	= 1
	gen weight_platform = 1

	tempfile riders
	save `riders'
	
	* --------
	* Platform
	* --------

	use "${dt_final}/platform_survey_constructed.dta", clear
	gen 	balance_group = 2 if d_woman == 1
	replace balance_group = 3 if d_woman == 0
	
	append using `riders'

* ------------------------------------------------------------------------------
* 	PART 1.2: Table-specific labels
* ------------------------------------------------------------------------------

	lab var usual_car_cont		"Status quo"
	lab var comments_mixed_cont "Verbal, public space"
	lab var comments_pink_cont 	"Verbal, reserved space"
	lab var grope_mixed_cont 	"Physical, public space"
	lab var grope_pink_cont 	"Physical, reserved space"	
	lab var nocomp_30_cont 		"Current scenario, 30 cents opportunity cost"
	lab var nocomp_65_cont 		"Current scenario, 65 cents opportunity cost"
	lab var fullcomp_30_cont 	"No men on reserved space, 30 cents opportunity cost"
	lab var fullcomp_65_cont	"No men on reserved space, 65 cents opportunity cost"
	
	lab def group 	3 "Platform survey: male" ///
					2 "Platform survey: female" ///
					1 "Riders", replace
	lab val balance_group 	group
	
/*******************************************************************************
	PART 2: Calculate balance
*******************************************************************************/

* ------------------------------------------------------------------------------
* 	PART 2.1: Variables present in all surveys
* ------------------------------------------------------------------------------

	preserve

		* Balance table
		iebaltab 	${balancevars1}	///
					[pw = weight_platform]  ///
					, ///
					grpvar(balance_group) ///
					control(2) ///
					vce(robust) ///
					rowvarlabels tblnonote ///
					browse `star'
					
		
	/* We're dropping the number of observations from the table, which takes 
	   some manual format corrections. 
	   There are variations in the number of obs because of missing variables, 
	   and displaying all of them makes the table too polluted. We will describe
	   the sample sizes in the notes instead.									*/
		drop 	v2 v4 v6
		rename 	v1 variable
		rename 	v3 women
		rename 	v5 rider
		rename 	v7 men
		rename 	v8 rider_women
		rename 	v9 men_women

		* Save tempfile
		tempfile	top
		save		`top'
	

	restore
	
* ------------------------------------------------------------------------------
* 	PART 2.2: Variables asked only to women
* ------------------------------------------------------------------------------

	* Keep only women respondents
	keep if inlist(balance_group, 1, 2)
	
	* Run balance
	iebaltab 	${balancevars2} ///
				[pw = weight_platform]  ///
				, ///
				grpvar(balance_group) ///
				rowvarlabels control(2) tblnonote vce(robust) ///
				browse `star'
			
	* Drop number of obs and make manual corrections
	drop 	v2 v4
	rename  v1 variable
	rename  v3 women
	rename  v5 rider
	rename  v6 rider_women
	
	* Drop header, since we're appending to the fist table
	drop if _n < 4
	
	tempfile bottom
	save `bottom'
	
* ------------------------------------------------------------------------------
* 	PART 2.3: Merge all variables and format table
* ------------------------------------------------------------------------------

	use `top', clear
	append using `bottom'
	
	replace men = 		"-" if missing(men)
	replace men_women = "-" if missing(men_women) & !missing(rider_women)
	
	* Order columns
	rename variable 	v1 
	rename women 		v3 
	rename men 			v4
	rename rider 		v2 
	rename men_women 	v6
	rename rider_women 	v5
	
	order v1 v2 v3 v4 v5 v6
	
	* Label columns
	replace v2 = "(1)" 		 in 1
	replace v3 = "(2)" 		 in 1
	replace v5 = "(4)" 		 in 1
	replace v6 = "(5)" 		 in 1
	replace v5 = "(2) - (1)" in 3
	replace v6 = "(2) - (3)" in 3
	replace v1 = "" 		 in 3
	
	* Order observations
	gen 	order = _n
	replace order = 3.5 in 1
	sort 	order
	drop 	order
	
	* Fix std error display
	foreach var in v2 v3 v4 {
		replace `var' = subinstr(`var', "[", "(", .)
		replace `var' = subinstr(`var', "]", ")", .)
	}
	
/*******************************************************************************
	PART 3: Export table
*******************************************************************************/

	dataout, save("${out_tables}/delete_me1") tex nohead mid(3) replace
	
	* There are still some manual corrections to be made to the tex file so the
	* table has the same format as the other ones
	
	filefilter "${out_tables}/delete_me1.tex" "${out_tables}/delete_me2.tex", ///
               from("\BSbegin{tabular}{lccccc} \BShline") to("\BSbegin{tabular}{lccccc} \BShline\BShline \BS\BS[-1.8ex]") replace
			   
	filefilter "${out_tables}/delete_me2.tex" "${out_tables}/delete_me1.tex", ///
               from("&  &  \BS\BS \BShline") to("&  &  \BS\BS \BS\BS[-1.8ex] \BShline\BShline") replace
			   
	filefilter "${out_tables}/delete_me1.tex" "${out_tables}/delete_me2.tex", ///
               from("\BSdocumentclass[]{article}") to("") replace
			   
	filefilter "${out_tables}/delete_me2.tex" "${out_tables}/delete_me1.tex", ///
               from("\BSsetlength{\BSpdfpagewidth}{8.5in} \BSsetlength{\BSpdfpageheight}{11in}") to("") replace
	
	filefilter "${out_tables}/delete_me1.tex" "${out_tables}/delete_me2.tex", ///
               from("\BSbegin{document}") to("") replace
			   
	filefilter "${out_tables}/delete_me2.tex" "${out_tables}/delete_me1.tex", ///
               from("\BSend{document}") to("") replace
			   
	filefilter "${out_tables}/delete_me1.tex" "${out_tables}/delete_me2.tex", ///
               from("(5) \BS\BS \BShline") to("(5) \BS\BS \BShline \BS\BS[-1ex] \BSmulticolumn{6}{c}{\BStextit{Panel A: Demographic variables}} \BS\BS[-1ex] \BS\BS") replace
	
	filefilter "${out_tables}/delete_me2.tex" "${out_tables}/delete_me1.tex", ///
               from("Physical, reserved space") to("\BS\BS[-1ex] \BSmulticolumn{6}{c}{\BStextit{Panel B: Self-reported risk of harassment (number of occurrences in a year)}} \BS\BS \BS\BS[-1ex] Physical, reserved space") replace
	
	filefilter "${out_tables}/delete_me1.tex" "${out_tables}/delete_me2.tex", ///
               from("Status quo") to("\BS\BS[-1ex] \BSmulticolumn{6}{c}{\BStextit{Panel C: Self-reported share of reserved space rides under hypothetical scenarios}} \BS\BS \BS\BS[-1ex] Status quo") replace
	
	filefilter "${out_tables}/delete_me2.tex" "${out_tables}/delete_me1.tex", ///
               from("(5) \BS\BS \BShline") to("(5) \BS\BS \BShline \BS\BS[-1.8ex]") replace
	
	filefilter "${out_tables}/delete_me1.tex" "${out_tables}/${star}balance_table.tex", ///
               from("00 ") to("") replace
	
	erase	"${out_tables}/delete_me1.tex"
	erase	"${out_tables}/delete_me2.tex"
			   
******************************************************************** Show's over
	
