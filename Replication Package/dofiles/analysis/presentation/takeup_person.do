/********************************************************************************
	PART 1: Define sample
********************************************************************************/

	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear

	xtset user_id 
	
	* Only baseline and price experiment rider
	keep if inlist(phase, 1, 2)
    		
	* Remove 60 and -60 rides: there was a problem with them during the survey
	keep if !missing(premium_cat)
	
	* Main sample:
	keep if d_anyphase3 == 1
	
	* Make take up var 0-100 instead of 0-1
	replace d_women_car = d_women_car * 100

/********************************************************************************
	PART 2: Ride level, no fixed effects
********************************************************************************/

	* Collapse at rider level
	collapse (max) d_women_car weight, ///
	  by (premium_cat user_uuid) 
		
	* Run regression
	reg d_women_car ibn.premium_cat ///
		[pw = weight], ///
		nocons ///
		cluster(user_uuid)

	test 2.premium_cat == 3.premium_cat == 4.premium_cat
	local pval : di %5.3f `r(p)'
	local pval = trim("`pval'")
		
	margins premium_cat
	marginsplot, ///
		recast(bar) ///
		plotopts(color(${col_aux_light}) barwidth(0.5)) ///
		ciopts(recast(rcap) color(${col_1})) ///
		xtitle(Opportunity cost (USD)) ///
		ytitle(%) ///
		title("") ///
		${plot_options} ///
		ylab(, noticks labsize(4) glcolor(gs15)) ///
		yscale(range(0(20)80)) ///
		title(Percent of riders who take up reserved space at least once) ///
		ylabel(0(20)80) ///
		text(60 3 "F-test for coefficient equality" "across positive opportunity costs" "P-value  = `pval'")
		
				
	* Export graph
	 gr export "${out_graphs}/Presentation/takeup_person.png", width(5000) replace
	 
******************************** The end ***************************************
