	
/********************************************************************************
       PART 1: Load data & reshape 
********************************************************************************/
	
	use "${dt_platform_fin}/platform_survey_constructed.dta", clear

	keep if !missing(reputation_self)
	
	foreach group in self men women {
	
		gen reputation`group' = (reputation_`group' < 3) * 100 if !missing(reputation_`group')
		lab val reputation`group' reputation
		drop reputation_`group'
		
	}
		
	reshape long reputation, i(id) j(group) string
	
	keep if inlist(group, "self", "men", "women")

	collapse (mean) reputation [pw = weight_platform] if !missing(reputation), by(group d_woman)
	
	drop if d_woman == 0 & group != "self"
	
	gen 	over = 1 if d_woman == 1 & group == "self"
	replace over = 2 if d_woman == 1 & group == "women"
	replace over = 3 if d_woman == 1 & group == "men"
	replace over = 4 if d_woman == 0 & group == "self"
	
	lab def over 1 "Women’s own belief" ///
				 2 "Women’s belief about other women" ///
				 3 "Women’s belief about men" ///
				 4 "Men’s own belief"
				 
	lab val over over
	
/********************************************************************************
       PART 2: Make graphs & export
********************************************************************************/
	
	gr 	hbar reputation, over(over) ///
		graphregion(color(white)) bgcolor(white) ///
		ylab(,glcolor(${col_box}) noticks) ///
		ytitle(Percent of respondents) ///
		bar(1, color(${col_2})) 
		
		
	graph export "${out_graphs}/beliefs.png", replace width(5000)

***************************************************************** End of do-file
