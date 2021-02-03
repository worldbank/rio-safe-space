/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:	${out_graphs}/takeup_person_bound.png
				
	WRITEN BY:  Kate Vyborny and Luiza Andrade

********************************************************************************
       PART 1: Prepare data
********************************************************************************/

	use "${dt_final}/rider-audits-constructed.dta", clear
	
	* We're only looking at opportunity cost rides
	keep if phase < 3 
	
	* There was some more code here to drop observations, but no observation
	* were being dropped so I (Luiza) removed it
	
	collapse (max) d_women_car, by(user_id premium_cat weight)																				

	* Display variable as percentage
	replace d_women_car = d_women_car * 100 

/********************************************************************************
       PART 2: Run regression
********************************************************************************/

	* Average take up by 
	reg d_women_car ibn.premium_cat ///
			[pw = weight], ///
			nocons ///
			cluster(user_id)

	* Test if take is statistically different across
	test 2.premium_cat == 3.premium_cat == 4.premium_cat
	local pval : di %5.3f `r(p)'
	local pval = trim("`pval'")
	
/********************************************************************************
       PART 3: Plot results
********************************************************************************/

	margins premium_cat
	marginsplot, ///
		recast(bar) ///
		plotopts(color(${col_womencar}) barwidth(0.5)) ///
		ciopts(recast(rcap) color(${col_aux_light})) ///
		xtitle(Opportunity cost (USD)) ///
		ytitle(Percent of riders who ever choose reserved space) ///
		title("") ///
		${plot_options} ///
		yscale(range(0(20)80)) ///
		ylabel(0(20)80) ///
		text(60 3 "F-test for coefficient equality" "across positive opportunity cost" "P-value  = `pval'")
		
	* Export graph
	gr export "${out_graphs}/takeup_person_bound.png", width(5000) replace

*============================================================= That's all, folks!
