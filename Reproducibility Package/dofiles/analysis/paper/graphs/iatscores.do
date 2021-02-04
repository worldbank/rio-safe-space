/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************

	REQUIRES:	${dt_final}/platform_survey_constructed.dta
	CREATES:	${out_graphs}/IAT_safety.png
				${out_graphs}/IAT_advances.png
				${out_graphs}/IAT_men.png
				${out_graphs}/IAT_women.png
				
	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]
		
*******************************************************************************
								 Prepare data
*******************************************************************************/

	* Load platform survey data
	use "${dt_final}/platform_survey_constructed.dta", clear
	
	* Keep the same sample as used in the regressions
	keep if !missing(scorereputation) & !missing(scoresecurity) 

	* We cannot apply sampling weights to density plots

	local scale ylabel(0(.5)1)
		
/******************************************************************************* 
						Women only: safety vs advances
*******************************************************************************/

	twoway 	(kdensity scorereputation	if d_woman == 1, color(${col_1})) ///
			(kdensity scoresecurity 	if d_woman == 1, color(${col_2})), ///
			xtitle("D-Score") ///
			ytitle("Density") ///
			xline(0, lcolor(${col_aux_bold})) ///
			legend(order(2 "Safety IAT" 1 "Advances IAT") size(4) region(lcolor(white))) ///
			${plot_options} `scale'
			
	gr export	"${out_graphs}/IAT_women.png", width(5000) replace
	
/******************************************************************************* 
						Men only: safety vs advances
*******************************************************************************/

	twoway 	(kdensity scorereputation 	if d_woman == 0, lpattern(dash) color(${col_1})) ///
			(kdensity scoresecurity 	if d_woman == 0, lpattern(dash) color(${col_2})), ///
			xtitle("D-Score") ///
			ytitle("Density") ///
			xline(0, lcolor(${col_aux_bold})) ///
			legend(order(2 "Safety IAT" 1 "Advances IAT") size(4) region(lcolor(white))) ///
			${plot_options} `scale'
			
	gr export	"${out_graphs}/IAT_men.png", width(5000) replace
	
/******************************************************************************* 
						Advances: men vs women
*******************************************************************************/

	twoway 	(kdensity scorereputation if d_woman == 1, color(${col_1})) ///
			(kdensity scorereputation if d_woman == 0, lpattern(dash) color(${col_1})), ///
			xline(0, lcolor(${col_aux_bold})) ///
			xtitle("D-Score") ///
			ytitle("Density") ///
			legend(order(2 "Male" 1 "Female") region(lcolor(white))) ///
			xtitle("D-Score") ///
			${plot_options}  `scale'
			
	gr export	"${out_graphs}/IAT_advances.png", width(5000) replace

/******************************************************************************* 
						Safety: men vs women
*******************************************************************************/


	twoway 	(kdensity scoresecurity if d_woman == 1,  color(${col_2})) ///
			(kdensity scoresecurity if d_woman == 0, lpattern(dash) color(${col_2})), ///
			xline(0, lcolor(${col_aux_bold})) ///
			legend(order(2 "Male" 1 "Female") region(lcolor(white))) ///
			xtitle("D-Score") ///
			ytitle("Density") ///
			${plot_options} `scale'
			
	gr export	"${out_graphs}/IAT_safety.png", width(5000) replace
	
**************************** End of do-file ************************************
