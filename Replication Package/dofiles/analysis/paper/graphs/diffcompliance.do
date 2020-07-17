/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_mapping.dta
	CREATES:	${out_graphs}/diffcompliance.png
				
	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]

********************************************************************************
	Prepare data
*******************************************************************************/

	* Load data: Constructed rider audit data set
	use "${dt_final}/platform-observations.dta", clear
	
	* Adjust variables format: from 0-1 to 0-100%
	foreach car in mix pink {
		replace MA_men_present_`car' = MA_men_present_`car' * 100
	}
	
	* Calculate difference between mixed and women's cars
	gen MA_compliance_diff = MA_men_present_mix - MA_men_present_pink

/*******************************************************************************
	Create graph
*******************************************************************************/
	
	* Calculate mean to add to plot
	sum MA_compliance_diff
	local mean : di %9.1f `= r(mean)'
	local mean = trim("`mean'")
	
	* Dislocate text box
	local text = r(mean) + 5
	
	* Create plot
	kdensity MA_compliance_diff ///
		, ///
		${plot_options} ///
		lcolor	(${col_1}) ///
		note	("") ///
		title	("") ///
		xline	(0, lcolor(${col_aux_light})) ///
		xline	(`mean', ///
				lcolor(${col_highlight}) ///
				lpattern(dot)) ///
		text	(.038 `text' "Average:" "`mean' p.p.", ///
				 orient(horizontal) ///
				 justification(center) ///
				 fcolor(white) ///
				 margin(small)) ///
		xtitle("Difference in percent of male riders between" "public space and reserved space (p.p.)")
	
	* Save it
	graph export "${out_graphs}/diffcompliance.png", replace width(5000)

****************************** End of do-file **********************************
