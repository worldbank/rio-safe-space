/*******************************************************************************
	Prepare data
*******************************************************************************/

	* Load data: rider audits
	use "${dt_rider_fin}/pooled_mapping.dta", clear
	
	* Adjust variables format: from 0-1 to 0-100%
	foreach car in mix pink {
		replace MA_men_present_`car' = MA_men_present_`car' * 100
	}

	
/*******************************************************************************
	Create graphs
*******************************************************************************/

	twoway 	(kdensity MA_men_present_pink, lcolor(${col_womencar}) lwidth(medthick)) ///
			(kdensity MA_men_present_mix,  lcolor(${col_mixedcar}) lwidth(medthick)), ///
			legend(order(1 "${lab_womencar}" ///
						 2 "${lab_mixedcar}") ///
				   region(lcolor(white))) ///
			ytitle(Density) ///
			xtitle("Percent of riders who are male") ///
			${paper_plotops}
			
	* Save graph
	graph export "$out_graphs\mappingcompliancebycar.png", replace width(5000)
			
****************************** End of do-file **********************************
