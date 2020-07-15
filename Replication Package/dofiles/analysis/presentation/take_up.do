
	
	use "${dt_rider_fin}\pooled_rider_audit_constructed.dta", clear

	foreach var in usual_car_cont d_women_car {
	
		replace `var' = `var' * 100

	}
	
	collapse 	(mean) 	usual_car_cont d_women_car if phase == 1 [pw = weight], ///
				by		(user_id)

	twoway 	(kdensity usual_car_cont,  bwidth(15) color(gs12)) ///
			(kdensity d_women_car, color(purple)) ///
			, ///
			graphregion(color(white)) ///
			xtitle(Women's car rides (%)) ///
			ytitle(Density) ///
			ylab(, glcolor(gs15)) ///
			legend(order(1 "Stated" 2 "Observed") region(lcolor(white)))

	gr export "${out_graphs}/take_up.png", width(5000) replace
