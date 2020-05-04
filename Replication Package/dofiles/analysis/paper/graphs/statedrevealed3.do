/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:	${out_graphs}/statedrevealed3.png
				
	WRITEN BY:  Kate Vyborny

********************************************************************************
    PART 1: Prepare data
********************************************************************************/

	* Load full data set
	use "${dt_final}/pooled_rider_audit_constructed.dta", clear
	
	* Keep only baseline and opportunity cost rider
	keep if inlist(phase, 1, 2) 
	
	* Keep only riders that started the opportunity cost rides
	keep if d_anyphase2 == 1 											


/********************************************************************************
       PART 2: Reshape data for graph
********************************************************************************/

	gen _takeup5 = (premium==5) & d_women_car==1
	gen _offers5 = (premium==5) 
	bysort user_uuid: egen takeup5 = total(_takeup5) 
	bysort user_uuid: egen offers5 = total(_offers5) 
	gen meantakeup5 = takeup5 / offers5
	replace meantakeup5 = . if offers5 < 5 

	gen 	takeup5cat = .
	replace takeup5cat  = 1 if meantakeup5<=.1
	replace takeup5cat  = 2 if meantakeup5>.1 & meantakeup5 <= .35
	replace takeup5cat  = 3 if meantakeup5>.35 & meantakeup5 <= .65
	replace takeup5cat  = 4 if meantakeup5>.65 & meantakeup5 <= .9
	replace takeup5cat  = 5 if meantakeup5>.9 & meantakeup5 <.


	duplicates drop user_uuid, force
	
	rename nocomp_20 preference0
	rename takeup5cat preference1

	reshape long preference, i(user_uuid) j(revealed)

	expand 5

	bysort user_uuid: gen counter = _n

	gen category = .

	replace category = 1 if revealed==0 & counter==1 
	replace category = 2 if revealed==1 & counter==1 
	replace category = 4 if revealed==0 & counter==2
	replace category = 5 if revealed==1 & counter==2 
	replace category = 7 if revealed==0 & counter==3  
	replace category = 8 if revealed==1 & counter==3  
	replace category = 10 if revealed==0 & counter==4  
	replace category = 11 if revealed==1 & counter==4  
	replace category = 13 if revealed==0 & counter==5  
	replace category = 14 if revealed==1 & counter==5  

	gen pref_category = 0
		forvalues i = 1 / 5 {
		replace pref_category = 100 if counter==`i' & preference==`i'
		replace pref_category = . if preference==.
	}

	collapse (mean) pref_category (sd) sdpref=pref_category ///
		(count) n = pref_category, by(category revealed) 

	generate hipref = pref_category + invttail(n-1,0.025)*(sdpref / sqrt(n))
	generate lopref = pref_category - invttail(n-1,0.025)*(sdpref / sqrt(n))

	
/********************************************************************************
       PART 3: Make graph 
********************************************************************************/

	twoway 	(bar pref_category category if revealed == 0, color(${col_2})) ///
			(bar pref_category category if revealed == 1, color(${col_1})) ///
			(rcap hipref lopref category, color(${col_aux_light})) ///
			,	///
			${plot_options} ///
			ytitle(Percent of riders) ///
			xtitle(Space chosen) ///
			legend(order(1 "Stated preference" ///
						 3 "95% confidence interval" ///
						 2 "Revealed preference") ///
					region(lcolor(white)))	 ///
			xlabel(1.5 "Always public" ///
				   4.5 "Mostly public" ///
				   7.5 "Half and half" ///
				   10.5 "Mostly reserved" ///
				   13.5 "Always reserved", ///
				   noticks labsize(small)) ///
		${paper_plotops}
		
	graph export "${out_graphs}/statedrevealed3.png", replace 

***************************************************************** End of do-file
