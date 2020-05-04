/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 							Social norms survey								   *
********************************************************************************

	OUTLINE:	PART 1: Load data
				PART 2: Create table
				PART 3: Adapt table format

	REQUIRES:	${dt_final}/platform_survey_constructed.dta
	CREATES:	${out_tables}/genderdescriptives.tex

	WRITEN BY:  Kate Vyborny and Luiza Andrade

********************************************************************************
       PART 1: Load data
********************************************************************************/

	use "${dt_final}/platform_survey_constructed.dta", clear
	
	* Rescale variable to match other variables in this table
	replace reputationself = reputationself/100
	
/*******************************************************************************
       PART 2: Create table 
********************************************************************************/

	iebaltab 	reputationself womanchanges womanchangespinkless ///
				gropemixedoften ///
				d_riskplaces ///
				interveneraremixed intervenerarepink ///
				faultany [pw = weight_platform] ///
				, ///
				grpvar(d_man) ///
				vce(robust) ///
				browse ///
				replace ///
				rowvarlabels ///
				tblnonote  
				
	* First adjustments 		
	drop v2 v4
	rename v3 v2
	rename v5 v3
	rename v6 v4
	
	gen 	order = _n
	replace order = 3.5 in 1
	sort 	order
	drop 	order
	
	replace v1 = "" 	in 2
	replace v4 = "(3)" 	in 3
	
	foreach var in v3 v2 {
		replace `var' = subinstr(`var', "[", "(", .)
		replace `var' = subinstr(`var', "]", ")", .)
	}

	* Export table
	dataout, save("${out_tables}/delete_me1") tex nohead mid(3) replace
	
/*******************************************************************************
       PART 3: Adapt table format
********************************************************************************/

	* Other changes to formatting 
	
	filefilter "${out_tables}/delete_me1.tex" ///
			   "${out_tables}/delete_me2.tex", ///
               from("\BSdocumentclass[]{article}") to("") replace

	filefilter "${out_tables}/delete_me2.tex" ///
			   "${out_tables}/delete_me1.tex", ///
               from("\BSsetlength{\BSpdfpagewidth}{8.5in} \BSsetlength{\BSpdfpageheight}{11in}") to("") replace
  
	filefilter "${out_tables}/delete_me1.tex" ///
			   "${out_tables}/delete_me2.tex", ///
               from("\BSbegin{document}") to("") replace			 

	filefilter "${out_tables}/delete_me2.tex" ///
			   "${out_tables}/delete_me1.tex", ///
               from("\BSend{document}") to("") replace
			   
	filefilter "${out_tables}/delete_me1.tex" ///
			   "${out_tables}/delete_me2.tex", ///
               from("\BSbegin{tabular}{lccc} \BShline") to("\BSbegin{tabular}{lccc} \BShline\BShline \BS\BS[-1.8ex]") replace
			   
	filefilter "${out_tables}/delete_me2.tex" ///
			   "${out_tables}/delete_me1.tex", ///
               from("(1)-(2) \BS\BS \BShline") to("(1)-(2) \BS\BS \BShline \BS\BS[-1.8ex]")	replace		   
	
	filefilter "${out_tables}/delete_me1.tex" ///
			   "${out_tables}/delete_me2.tex", ///
               from("\BSend{tabular}") to("\BShline \BSend{tabular}") replace
			   
	filefilter "${out_tables}/delete_me2.tex" ///
			   "${out_tables}/delete_me1.tex", ///
               from("0\BS\BS") to("\BS\BS") replace
			   
	filefilter "${out_tables}/delete_me1.tex" ///
			   "${out_tables}/delete_me2.tex", ///
               from("0 ") to(" ") replace
	
	filefilter "${out_tables}/delete_me2.tex" ///
			   "${out_tables}/delete_me1.tex", ///
               from("& 0.472 & 0.472 &  \BS\BS") to("& 0.472 & 0.472 & -0.000 \BS\BS") replace
	
	filefilter "${out_tables}/delete_me1.tex" ///
			   "${out_tables}/delete_me2.tex", ///
               from("& (1) & (2) & (3) \BS\BS \BShline") to("& (1) & (2) & (3) \BS\BS \BShline\BS\BS[-1.8ex]") replace
			   
	filefilter "${out_tables}/delete_me2.tex" ///
			   "${out_tables}/delete_me1.tex", ///
               from(" & 0.44 & 0.51 & -0.070") to("$^{1}$ & 0.440 & 0.510 & -0.070") replace
			   
	filefilter "${out_tables}/delete_me1.tex" ///
			   "${out_tables}/delete_me2.tex", ///
               from("their min &") to("their minds &") replace
			
	copy "${out_tables}/delete_me2.tex" 		"${out_tables}/genderdescriptives.tex", replace
	
	erase	"${out_tables}/delete_me1.tex"
	erase	"${out_tables}/delete_me2.tex"
			   
*--------------------------------- The end ------------------------------------*		
