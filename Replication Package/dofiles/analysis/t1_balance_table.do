/*******************************************************************************
*								Rio Pink Car								   *
*		  			    PLATFORM SURVEY DESCRIPTIVES					  	   *
*   							   2018										   *
********************************************************************************

	** PURPOSE:  	Create descriptive graphs for platform survey variables
	
	** OUTLINE:		PART 1: Demographic variables
						PART 1.1: Merge premise and platform survey data
						PART 1.2: Create graphs
						
					PART 2: Exit survey variables
						PART 2.1: Merge premise and platform survey data
						PART 2.2: Create graphs
					
	** REQUIRES:	$dropbox\Data - Pooled\Data\Pooled rides.dta
					$clean\clean_platform.dta
					$dropbox\Data - Pooled\Data\Pooled exit.dta
																			
	** CREATES:	  	
	
	** IDS VAR: 	survey id
	
	** NOTES:		
				  
	** WRITEN BY:   Luiza Andrade [lcardosodeandrad@worldbank.org]

	** Last time modified: July 2018
	
********************************************************************************
*						PART 1: Demographic variables
*******************************************************************************/

* ------------------------------------------------------------------------------
* 				PART 1.1: Merge premise and platform survey data
* ------------------------------------------------------------------------------
	
	* Platform survey
	* ---------------
	use "${dt_platform_fin}/platform_survey_constructed.dta", clear
	gen balance_group = 2 if d_woman == 1
	replace balance_group = 3 if d_woman == 0
	
	tempfile platform
	save `platform'
	
	
	use "${dt_rider_fin}\pooled_rider_audit_constructed.dta", clear

	keep	user_id 	${balancevars1} ${balancevars2}	
	rename 	user_id 	id
	
	gen balance_group 	= 1
	gen weight_platform = 1
	
	duplicates drop
	
	append using `platform'
	
	lab def group 	3 "Platform survey: male" ///
					2 "Platform survey: female" ///
					1 "Riders", replace
	lab val balance_group 	group
	
	preserve
		* Rides: demographic vars
		* -----------------------
		* Keep only one observation per individual


			* Variables present in all surveys
			iebaltab 	${balancevars1}	///
						[pw = weight_platform]  ///
						, ///
						grpvar(balance_group) ///
						rowvarlabels control(2) tblnonote vce(robust) ///
						browse
							
			drop v2 v4 v6
			rename v1 variable
			rename v3 women
			rename v5 rider
			rename v7 men
			rename v8 rider_women
			rename v9 men_women

		* Save tempfile
		tempfile	top
		save		`top'
		

	restore
	
	keep if inlist(balance_group, 1, 2)
	
	iebaltab 	${balancevars2} ///
				[pw = weight_platform]  ///
				, ///
				grpvar(balance_group) ///
				rowvarlabels control(2) tblnonote vce(robust) ///
				browse
					
	drop v2 v4
	rename v1 variable
	rename v3 women
	rename v5 rider
	rename v6 rider_women
	
	drop if _n < 4
	
	tempfile bottom
	save `bottom'
	
	
	use `top', clear
	append using `bottom'
	
	replace men = "-" if missing(men)
	replace men_women = "-" if missing(men_women) & !missing(rider_women)
	
	rename variable v1 
	rename women v3 
	rename men v4
	rename rider v2 
	rename men_women v6
	rename rider_women v5
	
	order v1 v2 v3 v4 v5 v6
	
	
	replace v2 = "(1)" 		 in 1
	replace v3 = "(2)" 		 in 1
	replace v5 = "(4)" 		 in 1
	replace v6 = "(5)" 		 in 1
	replace v5 = "(2) - (1)" in 3
	replace v6 = "(2) - (3)" in 3
	replace v1 = "" 		 in 3
	
	gen order = _n
	replace order = 3.5 in 1
	sort order
	drop order
	
	dataout, save("${out_github}/delete_me1") tex nohead mid(3) replace

	filefilter "${out_github}/delete_me1.tex" "${out_github}/delete_me2.tex", ///
               from("[") to("(") replace		   
	
	filefilter "${out_github}/delete_me2.tex" "${out_github}/delete_me1.tex", ///
               from("]") to(")") replace
	
	filefilter "${out_github}/delete_me1.tex" "${out_github}/delete_me2.tex", ///
               from("\BSbegin{tabular}{lccccc} \BShline") to("\BSbegin{tabular}{lccccc} \BShline\BShline \BS\BS[-1.8ex]") replace
			   
	filefilter "${out_github}/delete_me2.tex" "${out_github}/delete_me1.tex", ///
               from("&  &  \BS\BS \BShline") to("&  &  \BS\BS \BS\BS[-1.8ex] \BShline\BShline") replace
			   
	filefilter "${out_github}/delete_me1.tex" "${out_github}/delete_me2.tex", ///
               from("\BSdocumentclass(){article}") to("") replace
			   
	filefilter "${out_github}/delete_me2.tex" "${out_github}/delete_me1.tex", ///
               from("\BSsetlength{\BSpdfpagewidth}{8.5in} \BSsetlength{\BSpdfpageheight}{11in}") to("") replace
	
	filefilter "${out_github}/delete_me1.tex" "${out_github}/delete_me2.tex", ///
               from("\BSbegin{document}") to("") replace
			   
	filefilter "${out_github}/delete_me2.tex" "${out_github}/delete_me1.tex", ///
               from("\BSend{document}") to("") replace
			   
	filefilter "${out_github}/delete_me1.tex" "${out_github}/delete_me2.tex", ///
               from("(5) \BS\BS \BShline") to("(5) \BS\BS \BShline \BS\BS[-1ex] \BSmulticolumn{6}{c}{\BStextit{Panel A: Demographic variables}} \BS\BS[-1ex] \BS\BS") replace
	
	filefilter "${out_github}/delete_me2.tex" "${out_github}/delete_me1.tex", ///
               from("Physical, reserved space") to("\BS\BS[-1ex] \BSmulticolumn{6}{c}{\BStextit{Panel B: Self-reported risk of harassment (number of occurrences in a year)}} \BS\BS \BS\BS[-1ex] Physical, reserved space") replace
	
	filefilter "${out_github}/delete_me1.tex" "${out_github}/delete_me2.tex", ///
               from("Status quo") to("\BS\BS[-1ex] \BSmulticolumn{6}{c}{\BStextit{Panel C: Self-reported share of reserved space rides under hypothetical scenarios}} \BS\BS \BS\BS[-1ex] Status quo") replace
	
	filefilter "${out_github}/delete_me2.tex" "${out_github}/delete_me1.tex", ///
               from("(5) \BS\BS \BShline") to("(5) \BS\BS \BShline \BS\BS[-1.8ex]") replace
	
	filefilter "${out_github}/delete_me1.tex" "${out_github}/balance_table.tex", ///
               from("00 ") to("") replace
	
	
	
	
	erase	"${out_github}/delete_me1.tex"
	erase	"${out_github}/delete_me2.tex"
	
	copy "${out_github}/balance_table.tex" "${out_tables}/balance_table.tex", replace
			   
	
	
