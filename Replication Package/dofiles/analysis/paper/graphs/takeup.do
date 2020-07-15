/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************
																			
	REQUIRES: 	${dt_final}/pooled_rider_audit_constructed.dta		
	CREATES:  	${out_graphs}/takeup_fe.png							
				${out_graphs}/takeup_person.png	
				
	OUTLINE:	PART 1: Define sample
				PART 2: Ride level figure
				PART 3: Rider level figure
					  
	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]

	
********************************************************************************
	PART 1: Define sample
********************************************************************************/

	use "${dt_final}/pooled_rider_audit_constructed.dta", clear
	
	* Only baseline and price experiment rider
	keep if inlist(phase, 1, 2)
    		
	* Remove 60 and -60 rides: there was a problem with them during the survey
	keep if !missing(premium_cat)
	
	* Main sample
	keep if d_anyphase3 == 1
	
	* Make take up var 0-100 instead of 0-1
	replace d_women_car = d_women_car * 100

/********************************************************************************
	PART 2: Ride level figure
********************************************************************************/

	* Run regression
	xtreg d_women_car ibn.premium_cat ///
		[pw = weightfe], ///
		cluster(user_uuid) ///
		fe
		
	* Test if take up if the same across positive opportunity cost levels, then
	* create and format local to add to the graph as text
	test 2.premium_cat == 3.premium_cat == 4.premium_cat
	local pval : di %5.3f `r(p)'
	local pval = trim("`pval'")
		
	* Calculate the predicted value for each category
	margins premium_cat
	
	* Create plot
	marginsplot, ///
		recast(bar) ///
		plotopts(color(${col_womencar}) barwidth(0.5)) ///
		ciopts(recast(rcap) color(${col_aux_light})) ///
		xtitle(Opportunity cost (USD)) ///
		ytitle(Percent of rides) ///
		title("") ///
		yscale(range(0(10)30)) ///
		ylabel(0(5)30) ///
		${plot_options} ///
		text(20 3 "F-test for coefficient equality" "across positive opportunity costs" "P-value  = `pval'")
				
	* Export graph
	 gr export "${out_graphs}/takeup_fe.png", width(5000) replace


/*******************************************************************************
	PART 3: Rider level figure
********************************************************************************/

	* Collapse at rider level
	collapse (max) d_women_car weight, ///
	  by (premium_cat user_uuid) 
		
	* Run regression
	reg d_women_car ibn.premium_cat ///
		[pw = weight], ///
		nocons ///
		cluster(user_uuid)

	* Test if take up if the same across positive opportunity cost levels, then
	* create and format local to add to the graph as text
	test 2.premium_cat == 3.premium_cat == 4.premium_cat
	local pval : di %5.3f `r(p)'
	local pval = trim("`pval'")
	
	* Calculate the predicted value for each category
	margins premium_cat
	marginsplot, ///
		recast(bar) ///
		plotopts(color(${col_womencar}) barwidth(0.5)) ///
		ciopts(recast(rcap) color(${col_aux_light})) ///
		xtitle(Opportunity cost (USD)) ///
		ytitle(Percent of riders) ///
		title("") ///
		${plot_options} ///
		yscale(range(0(20)80)) ///
		ylabel(0(20)80) ///
		text(60 3 "F-test for coefficient equality" "across positive opportunity costs" "P-value  = `pval'")
		
	* Export graph
	gr export "${out_graphs}/takeup_person.png", width(5000) replace
	
	
*---------------------------------- The end -----------------------------------*
