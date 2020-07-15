/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:	${out_graphs}/Paper/takeupandcongestion.png
				
	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]

********************************************************************************
	Prepare data
*******************************************************************************/

	* Load data
	use "${dt_final}/pooled_rider_audit_constructed.dta", clear

	* Subset sample
	keep if phase == 1 & d_anyphase2 == 1
	
	* Adjust variable format: from 0-1 to 0-100%
	foreach var in d_women_car MA_men_present_pink load_factor {
		replace `var' = `var' * 100
	}
	
	* Create cumulate distribution of load factor (only used for this graph)
	cumul 	load_factor, gen(cum)
	replace cum = cum * 100
	sort 	cum
	
/*******************************************************************************
	Create graph
*******************************************************************************/

	* Create it
	twoway 	(bar cum load_factor, 					color(${col_aux_light})) 	///
			(lpoly d_women_car load_factor, 		color(${col_1}) bwidth(10)) ///
			(lpoly MA_men_present_pink load_factor, color(${col_2}) bwidth(10)) ///
		, ///
			xline(50, lcolor(cranberry) lpattern(dot)) ///
			text(100 62 "High crowding") ///
			xtitle("Load factor" "(share of maximum allowable capacity)") ///
			xlabel(0 "0" 20 "0.2" 40 "0.4" 60 "0.6" 80 "0.8" 100 "1") ///
			ytitle("%") ///
			legend(order(1 "Cumulative distribution of rides" ///
						 2 "Percent of rides in reserved space" ///
						 3 "Percent of reserved space passengers who are men") ///
					cols(1) ///	 
					region(lcolor(white))) ///
			${paper_plotops}

	* Save it
	gr export "${out_graphs}/takeupandcongestion.png", width(5000) replace

**************************** End of do-file ************************************
