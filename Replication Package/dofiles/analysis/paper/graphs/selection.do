/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:	${out_graphs}/paper_selection.png
				${out_graphs}/presentation_selection.png
				
	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]

********************************************************************************
       PART 1: Prepare data
********************************************************************************/
		
	use "${dt_final}/rider-audits-constructed.dta", clear
	
	drop if inlist(user_uuid, 	"c3153718-9ae0-4d9e-a706-c12b05865c39", ///		these users report harassment on very large share of their rides
								"f82b3911-6691-4526-b1e6-344e0f72755b", ///		we don't drop them from the main specification because there we're controlling for user fixed effects
								"f8df2eb6-f9ad-45c0-80ab-27ba7a6116af")
	
	* Only randomized car assignment rides
	keep if phase == 3 & missing(flag_nomapping)
	
	* Adjust labels so they fit into the graphs
	lab var  MA_men_present_pink 	`""Share of reserved space" "riders who are men""'
	lab var	 MA_men_present_mix		`""Share of public space" "riders who are men""'
	
/*******************************************************************************
       PART 2: Run regressions
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
			
/*******************************************************************************
       PART 3: Export graphs
********************************************************************************/
	
/*------------------------------------------------------------------------------
	Paper version
------------------------------------------------------------------------------*/

	gr drop _all 
	
	coefplot	mixed ///
			   , ///
				vertical ///
				keep(MA_men_present_mix MA_men_present_pink) ///
				${plot_options} ///
				yline(0, lpattern(dash)) ///
				ciopt(color(gs10 gs10) ///
					  recast(rcap)) ///
				levels(90 95) ///
				ylab(, noticks glcolor(${col_box})) ///
				xlab(, noticks labsize(small)) ///
				xtitle("") ///
				ytitle("Marginal effect on share of rides" "where physical harassment is reported") ///
				title(Assigned to public space, box bexpand bcolor(gs15)) ///
				color(${col_mixedcar}) ///
				name(mixed)
				
	coefplot	women ///
	           , ///
				vertical ///
				keep(MA_men_present_mix MA_men_present_pink) ///
				${plot_options} ///
				yline(0, lpattern(dash)) ///
				ciopt(color(gs10 gs10) ///
					  recast(rcap)) ///
				levels(90 95) ///
				ylab(, noticks labcolor(white) glcolor(${col_box})) ///
				xlab(, noticks labsize(small)) ///
				xtitle("") ///
				ytitle("") ///
				yscale(noline) ///
				title(Assigned to reserved space, box bexpand bcolor(gs15)) ///
				color(${col_womencar}) ///
				name(women)
				
	gr combine 	mixed women, ///
				ycommon ///
				graphregion(color(white))
				
	* Export graph
	gr export "${out_graphs}/paper_selection.png", width(5000) replace
	
	
/*------------------------------------------------------------------------------
	Presentation version
------------------------------------------------------------------------------*/

	gr drop _all 
	
	coefplot	mixed, ///
				vertical ///
				keep(MA_men_present_mix MA_men_present_pink) ///
				${plot_options} ///
				yline(0, lpattern(dash)) ///
				ciopt(color(gs10 gs10) ///
					  recast(rcap)) ///
				levels(90 95) ///
				ylab(, noticks glcolor(${col_box}) labsize(${grlabsize})) ///
				xlab(, noticks) ///
				xtitle("") ///
				ytitle("Marginal effect on share of rides" "where physical harassment is reported", ///
					   size(${grlabsize})) ///
				title(Assigned to public space, box bexpand bcolor(gs15)) ///
				color(${col_mixedcar}) ///
				name(mixed)
				
	coefplot	women, ///
				vertical ///
				keep(MA_men_present_mix MA_men_present_pink) ///
				${plot_options} ///
				yline(0, lpattern(dash)) ///
				ciopt(color(gs10 gs10) ///
					  recast(rcap)) ///
				levels(90 95) ///
				ylab(, noticks labcolor(white) glcolor(${col_box})) ///
				xlab(, noticks) ///
				xtitle("") ///
				ytitle("") ///
				yscale(noline) ///
				title(Assigned to reserved space, box bexpand bcolor(gs15)) ///
				color(${col_womencar}) ///
				name(women)
				
	gr combine 	mixed women, ///
				ycommon ///
				graphregion(color(white))
				
	gr export "${out_graphs}/presentation_selection.png", 		  width(5000) replace
	
	
******************************** The end ***************************************
