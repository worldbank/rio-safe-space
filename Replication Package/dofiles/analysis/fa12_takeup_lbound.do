
/********************************************************************************
       PART 1: Define sample 
********************************************************************************/

	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear
	
	keep if phase < 3 
	
/********************************************************************************
       PART 2: Prepare data for graph
********************************************************************************/

	
	gen 	stage1 = (stage == 0) 
	bysort 	user_uuid: egen anystage1 = max(stage1)
	drop if inlist(premium, 20, 5, 60) & anystage1 == 0
	
	collapse (max) d_women_car, by(user_id premium_cat weight)																				
																				
	replace d_women_car = d_women_car * 100 

/********************************************************************************
       PART 3: Make graph 
********************************************************************************/

	reg d_women_car ibn.premium_cat ///
			[pw = weight], ///
			nocons ///
			cluster(user_id)

	test 2.premium_cat == 3.premium_cat == 4.premium_cat
	local pval : di %5.3f `r(p)'
	local pval = trim("`pval'")
	
	margins premium_cat
	marginsplot, ///
		recast(bar) ///
		plotopts(color(${col_womencar}) barwidth(0.5)) ///
		ciopts(recast(rcap) color(${col_aux_light})) ///
		xtitle(Opportunity cost (USD)) ///
		ytitle(Percent of riders who ever choose reserved space) ///
		title("") ///
		${paper_plotops} ///
		yscale(range(0(20)80)) ///
		ylabel(0(20)80) ///
		text(60 3 "F-test for coefficient equality" "across positive opportunity cost" "P-value  = `pval'")
		
	* Export graph
	gr export "${out_graphs}/takeup_person_bound.png", width(5000) replace

***************************************************************** End of do-file
