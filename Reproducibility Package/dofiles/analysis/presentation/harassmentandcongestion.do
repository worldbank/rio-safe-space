* Load data
	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear

	* Subset sample
	keep if phase == 3 & d_women_car == 0
	
	* Adjust variable format: from 0-1 to 0-100%
	foreach var in d_harassment {
		replace `var' = `var' * 100
	}
	

	* Create it
	twoway 	(lpolyci d_harassment load_factor, acolor(${col_aux_light}) clcolor(${col_aux_bold})), ///
			xline(.50, lcolor(${col_aux_bold}) lpattern(dot)) ///
			text(35 .62 "High crowding") ///
			xtitle("Load factor" "(share of maximum allowable capacity)") ///
			ytitle("%") /// 
			ylab(, noticks labsize(4) glcolor(gs15)) ///
			legend(order(2 "Percent of rides with harassment reported" ///
						 1 "95% confidence interval") ///
				   cols(1) ///
				   region(lcolor(white))) ///
			${plot_options}

	* Save it
	gr export "${out_graphs}/Presentation/harassmentandcongestion.png", width(5000) replace
