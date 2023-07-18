/*******************************************************************************
	Prepare data
*******************************************************************************/
	
	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear
	
	xtset user_id
		
	keep if phase == 3 & missing(flag_nomapping)
	lab var d_women_car " "
	
/*******************************************************************************
	Create and save plot
*******************************************************************************/
	
	
	foreach harVar in d_harassment d_physical_har {
		
		gr drop _all
		replace `harVar' = `harVar' * 100

		xtreg 	`harVar' d_women_car d_highcongestion d_highcompliance ///
				[pw = weightfe] ///
				, ///
				cluster(user_id) ///
				fe
				
		coefplot, 	keep(d_women_car) ///
					vertical ///
					yline(0, lpattern(dash)) ///
					levels(90 95) ///
					ylab(, noticks glcolor(${col_box}) labsize(${grlabsize})) ///
					graphregion(color(white)) ///
					xlab(, noticks) ///
					ciopt(color(gs10 gs10) recast(rcap)) ///
					ytitle("Marginal effect of riding reserved space on" "percent of rides with harassment reported", size(${grlabsize})) ///
					title(Overall, box bexpand bcolor(gs15) size(${grlabsize})) ///
					color(navy) ///
					name(all)
		
		xtreg 	`harVar' d_women_car d_highcongestion ///
				if d_highcompliance == 1 ///
				[pw = weightfe] ///
				, ///
				cluster(user_id) ///
				fe
				
		coefplot, 	keep(d_women_car) ///
					vertical ///
					yline(0, lpattern(dash)) levels(90 95) ///
					ylab(, noticks labcolor(white) glcolor(${col_box}) labsize(${grlabsize})) ///
					xlab(, noticks) ///
					yscale(noline) ///
					graphregion(color(white)) ///
					ciopt(color(gs10 gs10) recast(rcap)) ///
					ytitle("", size(${grlabsize})) ///
					title(Few men, box bexpand bcolor(gs15) size(${grlabsize})) ///
					color(${col_mixedcar}) ///
					name(high) 
		
		xtreg 	`harVar' d_women_car d_highcongestion ///
				if d_highcompliance == 0 ///
				[pw = weightfe] ///
				, ///
				cluster(user_id) ///
				fe
				
		coefplot, 	keep(d_women_car) ///
					vertical ///
					yline(0, lpattern(dash)) levels(90 95) ///
					ylab(, noticks labcolor(white) glcolor(${col_box}) labsize(${grlabsize})) ///
					xlab(, noticks) ///
					yscale(noline) ///
					graphregion(color(white)) ///
					ciopt(color(gs10 gs10) recast(rcap)) ///
					ytitle("", size(${grlabsize})) ///
					title(Many men, box bexpand bcolor(gs15) size(${grlabsize})) ///
					color(${col_womencar}) ///
					name(low)
					
		gr combine all low high, graphregion(color(white)) cols(3) ycommon
		
		* Export graph
		gr export "${out_graphs}/Presentation/coef_`harVar'.png", width(5000) replace
		
	}
	
	
	 
******************************** The end ***************************************
