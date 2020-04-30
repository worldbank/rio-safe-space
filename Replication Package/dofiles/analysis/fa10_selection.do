/*******************************************************************************
       PART 1: Set sample
********************************************************************************/
		
	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear
	
	drop if inlist(user_uuid, 	"c3153718-9ae0-4d9e-a706-c12b05865c39", ///		these users report harassment on very large share of their rides
								"f82b3911-6691-4526-b1e6-344e0f72755b", ///		we don't drop them from the main specification because there we're controlling for user fixed effects
								"f8df2eb6-f9ad-45c0-80ab-27ba7a6116af")

			
	* Only randomized car assignment rides
	keep if phase == 3 & missing(flag_nomapping)
	
	
/********************************************************************************
       PART 2: Adjust variables format
********************************************************************************/
	
	areg 	d_physical_har MA_men_present_mix MA_men_present_pink d_highcongestion ///
			[pw = weightfe] ///
			if d_women_car == 1, ///
			cluster(user_id) ///
			absorb(CI_line)
			
	est sto women
	
	areg 	d_physical_har MA_men_present_mix MA_men_present_pink d_highcongestion ///
			[pw = weightfe] ///
			if d_women_car == 0, ///
			cluster(user_id) ///
			absorb(CI_line)
			
	est sto mixed
	
			
	lab var  MA_men_present_pink 	`""Share of men in" "reserved space""'
	lab var	 MA_men_present_mix		`""Share of men in" "public space""'
	
	gr drop _all 
	
	coefplot	mixed, ///
				keep(MA_men_present_mix MA_men_present_pink) ///
				vertical ///
				yline(0, lpattern(dash)) ///
				levels(90 95) ///
				ylab(, noticks glcolor(${col_box})) ///
				graphregion(color(white)) ///
				xlab(, noticks) ///
				ciopt(color(gs10 gs10) recast(rcap)) ///
				xtitle("") ///
				ytitle("Marginal effect on share of rides" "where physical harassment is reported") ///
				title(Assigned to public space, box bexpand bcolor(gs15)) ///
				color(${col_mixedcar}) ///
				name(mixed)
				
	coefplot	women, ///
				keep(MA_men_present_mix MA_men_present_pink) ///
				vertical ///
				yline(0, lpattern(dash)) ///
				levels(90 95) ///
				ylab(, noticks labcolor(white) glcolor(${col_box})) ///
				graphregion(color(white)) ///
				xlab(, noticks) ///
				ciopt(color(gs10 gs10) recast(rcap)) ///
				xtitle("") ///
				ytitle("") ///
				yscale(noline) ///
				title(Assigned to reserved space, box bexpand bcolor(gs15)) ///
				color(${col_womencar}) ///
				name(women)
				
	gr combine 	mixed women, ///
				ycommon ///
				graphregion(color(white))
				
	gr export "${out_graphs}/Paper/selection.png", 		  width(5000) replace
	
	
******************************** The end ***************************************
