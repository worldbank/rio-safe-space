/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************

	REQUIRES: 	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:  	${out_graphs}/wtp_harass.png
				
	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]
					  	
********************************************************************************
	PART 1: Prepare data
********************************************************************************/

	* Load data
	use 		"${dt_final}/pooled_rider_audit_constructed.dta", clear

	* Main sample:
	keep 		if d_anyphase3 == 1
	
	* Turn dummy variables into 0-100
	replace d_women_car 	= d_women_car	 * 100
	replace d_physical_har 	= d_physical_har * 100
	
/*******************************************************************************
	PART 2: Estimate take up by quintile
********************************************************************************/

	* Estimate WTP over quintiles
	areg 	 d_women_car i.MA_compliance_diff_quint ///
			[pw = weightfe] ///
			if phase == 2 & premium > 0, ///
			cluster(user_id) ///
			absorb(user_id)

	* Predicted values
	margins MA_compliance_diff_quint
	
	* We'll store the results in a matrix so it's easier to join them to
	* other results
	matrix 	wtp = r(table)
	
	preserve

		clear
		svmat 	wtp
		
		* Store coef names
		gen		coef = "b"  in 1
		replace coef = "ll" in 5
		replace coef = "ul" in 6
		drop if missing(coef)
		
		* Make long by quintile
		reshape long wtp, i(coef) j(mendiff)

		tempfile compliance
		save `compliance'
		
	restore
			
/********************************************************************************
	PART 3: Impact on harassment across quintiles
********************************************************************************/

	* Change base level (public space) code just so we don't need to edit the matrix
	recode pink_compliance_diff_quint (0=6)
	
	* Estimate impact on harassment across quintiles	
	reghdfe	d_physical_har ib6.pink_compliance_diff_quint  ///
			[pw = weightfe] ///
			if phase == 3, ///
			cluster(user_id) ///
			absorb(MA_compliance_diff_quint user_id)

	matrix  harass = r(table)
		
	clear
	svmat 	harass
	matrix 	wtp = r(table)
	
	gen		coef = "b"  in 1
	replace coef = "ll" in 5
	replace coef = "ul" in 6

	drop if missing(coef)
		
	reshape long harass, i(coef) j(mendiff)

/********************************************************************************
	PART 4: Merge two variables
********************************************************************************/

	merge 1:1 mendiff coef using `compliance', assert(1 3) keep(3) nogen // dropping constant and base level from harassment result
	
	reshape wide harass wtp, i(mendiff) j(coef) str
	

/*******************************************************************************
	PART 5: Create graph
********************************************************************************/

	twoway		(bar  wtpb 				mendiff, color(${col_2})) ///
				(rcap wtpll wtpul 		mendiff, color(${col_aux_light})) ///
				(bar  harassb 			mendiff, color(${col_1})) ///
				(rcap harassll harassul mendiff, color(${col_aux_light})) ///
				, ///
					xtitle("Quintiles of difference in share of riders who are male" "(public - reserved space)") ///
					ytitle("") ///
					${plot_options} ///
					legend(order(1 "Take up of reserved space under positive opportunity cost (%)" ///
								 3 "Effect of reserved space on harassment (p.p)" ///
								 2 "95% confidence interval") ///
						   cols(1) ///
						   size(${grlabsize}) ///
						   region(lcolor(white)))

	graph 		export "${out_graphs}/wtp_harass.png", replace width(5000)	

*************************************************************************** Done!
