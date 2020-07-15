/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:	${out_graphs}/eventstudy.png
				${out_graphs}/eventstudy_hist.png
				
	WRITEN BY:  Luiza Andrade

********************************************************************************
    PART 1: Load data
********************************************************************************/

	use "${dt_final}/pooled_rider_audit_constructed.dta", clear
	
/********************************************************************************
    PART 2: Top panel -- event study graph
********************************************************************************/

/*------------------------------------------------------------------------------
	PART 2.1: Calculate post-event average
------------------------------------------------------------------------------*/

	reg d_women_car d_post
	
	mat results = r(table)

	local postcons = results[1,1]
	local postll = results[5,1]
	local postul = results[6,1]
	
/*------------------------------------------------------------------------------
	PART 2.2: Calculate effect for each ride
------------------------------------------------------------------------------*/

	reg d_women_car ib99.event_ride												// base is the last ride with no premium

	* Load the results as the data set so they're easier to handle
	mat pointest = r(table)
	mat pointest = pointest'

	preserve 
	
		clear
		svmat pointest, names(col)
		gen ride = _n + 2	// there are no rides 1 and 2 
		drop in 219			// this is the constant

/*------------------------------------------------------------------------------

------------------------------------------------------------------------------*/

		tw  (scatteri 0 0 0 99, recast(connected) msymbol(none) lcolor(${col_1})) ///
			(scatteri `postcons' 100 `postcons' 221, recast(connected) msymbol(none) lcolor(${col_2})) ///
			(scatteri `postul' 100 `postul' 221, recast(connected) lpattern(dash) msymbol(none) lcolor(${col_2})) ///
			(scatteri `postll' 100 `postll' 221, recast(connected) lpattern(dash) msymbol(none) lcolor(${col_2})) ///
			(rspike ul ll ride, msize(tiny) color(${col_aux_bold})) ///
			(scatter b ride, msize(tiny) color(${col_aux_bold})) ///
			, ///
			graphregion(color(white)) ///
			legend(off) ///
			xlabel(none) ///
			ylabel(, noticks labsize(small)) ///
			xmlabel(0 "-100" 50 "-50" 100 "0" 150 "50" 200 "100", labsize(small) noticks) ///
			xtitle(Ride sequence (0 = introduction of opportunity cost)) ///
			ytitle(Take up of reserved space)  ///
			text(1.2 50 "Zero opportunity cost rides", size(small)) ///
			text(1.2 150 "Opportunity cost rides", size(small)) ///
			ysize(2) xsize(4)
		
		gr export "${out_graphs}/eventstudy.png", replace width(5000)

	restore
			
/********************************************************************************
    PART 3: Bottom panel -- histogram
********************************************************************************/
		
	hist event_ride ///
		 , ///
		 frequency ///
		 color(${col_aux_bold}) ///
		 width(1) ///
		 graphregion(color(white)) ///
		 bgcolor(white) ///
		 ylab(, noticks labsize(small) glcolor(${col_box})) ///
		 ytitle (Number of rider-wave combinations) ///
		 xtitle(Ride sequence (0 = introduction of opportunity cost)) ///
		 xlabel(none) ///
		 xmlabel(0 "-100" 50 "-50" 100 "0" 150 "50" 200 "100", noticks labsize(small)) ///
		 ysize(2) xsize(4)
		
/********************************************************************************
    PART 4: Combine graphs and save
********************************************************************************/

	gr export "${out_graphs}/eventstudy_hist.png", replace width(5000)
		
***************************************************************** End of do-file
