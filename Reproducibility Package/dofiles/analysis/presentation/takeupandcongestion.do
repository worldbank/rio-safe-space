/*******************************************************************************
	Prepare data
*******************************************************************************/

	* Load data
	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear

	* Subset sample
	keep if phase == 1 & d_anyphase2 == 1
	
	* Adjust variable format: from 0-1 to 0-100%
	foreach var in d_women_car MA_men_present_pink {
		replace `var' = `var' * 100
	}
	
/*******************************************************************************
	Create graph
*******************************************************************************/

	* Create it
	twoway 	(lpoly d_women_car load_factor, 		color(${col_mixedcar})) ///
			(lpoly MA_men_present_pink load_factor, color(${col_womencar})), ///
			xline(.5, lcolor(${col_aux_bold}) lpattern(dot)) ///
			text(48 .62 "High crowding") ///
			xtitle("Load factor" "(share of maximum allowable capacity)") ///
			ytitle("%") ///
			ylab(, noticks labsize(4) glcolor(gs15)) ///
			legend(order(1 "Percent of rides in reserved space" ///
						 2 "Percent of men in reserved space") ///
					cols(1) ///	 
					region(lcolor(white))) ///
			${plot_options}

	* Save it
	gr export "${out_graphs}/Presentation/takeupandcongestion.png", width(5000) replace
	
******************************** The end ***************************************
