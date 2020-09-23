/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:	${out_graphs}/statedrevealed3.png
				
	WRITEN BY:  Kate Vyborny and Luiza Andrade

********************************************************************************
    PART 1: Prepare data
********************************************************************************/

	* Load full data set
	use "${dt_final}/rider-audits-constructed.dta", clear
	
	* Keep only baseline and opportunity cost rider
	keep if inlist(phase, 1, 2) 
	
	* Keep only riders that started the opportunity cost rides
	keep if d_anyphase2 == 1
	
	* Keep only 5 cents premium rides
	keep if premium == 5
	
	* And only riders who we have stated preferences for
	keep if !missing(nocomp_20)	// .20 BRL = .05 USD
	
	* And enough observations with premium
	egen id = group(user_uuid stage)
	bys id: drop if _N < 5									


/********************************************************************************
       PART 2: Calculate revealed preferences
********************************************************************************/

	* We're showing (1) the stated preference on the exit survey and (2) the
	* take up of reserved space. (1) is reported at the individual level, and
	* (2) is reported for each ride. We will calculate the share of rides that
	* each rider took in the reserved space. So we first bring this to rider
	* level:
	collapse 	(mean)	stated	= nocomp_20		///
				(sum) 	takeup 	= d_women_car	///
				(count) offers 	= d_women_car, 	///
				by (id)
	* Then we calculate the pct of rides taken in the reserved space
	gen 	meantakeup = takeup / offers
	
	* This is a continuous variable. Make it categorical be comparable to
	* the stated preference
	gen revealed1 = (meantakeup <=. 1)						// Always public space
	gen revealed2 = (meantakeup >.1  & meantakeup <= .35)	// Mostly public space
	gen revealed3 = (meantakeup >.35 & meantakeup <= .65)	// 50/50
	gen revealed4 = (meantakeup >.65 & meantakeup <= .9)	// Mostly reserved space
	gen revealed5 = (meantakeup >.9  & meantakeup <.)		// Always reserved space
	
	tab stated, gen(stated)
	
/********************************************************************************
       PART 3: Calculate averages by type of preference
********************************************************************************/

	foreach pref_type in stated revealed {
		forvalues pref = 1/5 {
			
			* Regress each preference on 1
			reg `pref_type'`pref'
			
			* We will save the regression results into a matrix so they are easier to
			* handle into a graph format
			if `pref' == 1 & "`pref_type'" == "stated" {
				mat results = r(table)
			}
			else {
				mat results = [results , r(table) ]
			}
		}
	}

	* Load results as data set
	mat results = results'
	clear
	svmat results, names(col)
	
	* Identify type of preference
	gen 	revealed 	= (_n > 5)
	gen 	preference 	=  _n if _n <= 5
	replace preference 	=  _n - 5 if _n > 5
	
	* From share to percent
	foreach var in b ul ll {
		replace `var' = `var' * 100 if !missing(`var')
		replace `var' = 0			if  missing(`var')
		replace `var' = round(`var', .1)
	}
	
	
	* Order observations so the bars are shown side by side
	sort preference revealed	
	gen order = _n	
	foreach cutoff in 2 5 8 11 {
		replace order = order + 1 if order > `cutoff' 
	}


/********************************************************************************
       PART 4: Make graph 
********************************************************************************/

	twoway 	(bar b order if revealed == 0, color(${col_2})) ///
			(bar b order if revealed == 1, color(${col_1})) ///
			(rcap ll ul order, lcolor(${col_aux_light})) ///
			,	///
			${plot_options} ///
			ytitle(Percent of riders) ///
			xtitle(Space chosen) ///
			legend(order(1 "Stated preference" ///
						 2 "Revealed preference" ///
						 3 "95% CI") ///
					region(lcolor(white)) ///
					symxsize(10) ///
					cols(3))	 ///
			xlabel(1.5  "Always public" ///
				   4.5  "Mostly public" ///
				   7.5  "Half and half" ///
				   10.5 "Mostly reserved" ///
				   13.5 "Always reserved", ///
				   noticks labsize(small)) ///
		${paper_plotops}
		
	graph export "${out_graphs}/statedrevealed3.png", replace 

***************************************************************** End of do-file
