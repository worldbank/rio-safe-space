/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:	${out_graphs}/eventstudy_bypremium.png
				
	WRITEN BY:  Luiza Andrade 
	
********************************************************************************
    PART 1: Prepare data
********************************************************************************/

	use "${dt_final}/rider-audits-constructed.dta", clear

	keep if phase != 3 				// keep only willingness to pay rides
	keep if !missing(premium_ride)	// this variable was defined only for the observations relevant for this graph
	
/********************************************************************************
    PART 2: Top panel -- event study graph
********************************************************************************/

	foreach premium in 20 5 10 {

		reg d_women_car i.premium if (premium_ride == 10 | premium == `premium')
	
		mat results = r(table)
		local cons`premium' = results[1,2]
		local ll`premium' = results[5,2]
		local ul`premium' = results[6,2]
		mat drop results
		
		di "cons`premium' = `cons`premium''"
	}


	reg d_women_car ib10.premium_ride
	
	est sto event
	mat pointest = r(table)
	mat pointest = pointest'
	
	clear
	svmat pointest, names(col)
	drop in 41
	gen ride = _n 
	
/********************************************************************************
    PART 3: Actual graph
********************************************************************************/
	
	tw	(scatteri 0 0 0 10, recast(connected) msymbol(none) lcolor(black)) ///
		(scatteri `cons20' 10 `cons20' 20, recast(connected) msymbol(none) lcolor(${col_mixedcar})) ///
		(scatteri `ul20' 10 `ul20' 20, recast(connected) lpattern(dash) msymbol(none) lcolor(${col_mixedcar})) ///
		(scatteri `ll20' 10 `ll20' 20, recast(connected) lpattern(dash) msymbol(none) lcolor(${col_mixedcar})) ///
		(scatteri `cons10' 30 `cons10' 40, recast(connected) msymbol(none) lcolor(${col_aux_light})) ///
		(scatteri `ul10' 30 `ul10' 40, recast(connected) lpattern(dash) msymbol(none) lcolor(${col_aux_light})) ///
		(scatteri `ll10' 30 `ll10' 40, recast(connected) lpattern(dash) msymbol(none) lcolor(${col_aux_light})) ///
		(scatteri `cons5' 20 `cons5' 30, recast(connected) msymbol(none) lcolor(${col_womencar})) ///
		(scatteri `ul5' 20 `ul5' 30, recast(connected) lpattern(dash) msymbol(none) lcolor(${col_womencar})) ///
		(scatteri `ll5' 20 `ll5' 30, recast(connected) lpattern(dash) msymbol(none) lcolor(${col_womencar})) ///
		(rspike ul ll ride, msize(tiny) color(${col_aux_bold})) ///
		(scatter b ride, msize(tiny) color(${col_aux_bold})) ///
		, ///
		${plot_options} ///
		legend(off) ///
		xlabel(none) ///
		xmlabel(5 "0 cent opportunity cost" 15 "20 cents opportunity cost" 25 "5 cents opportunity cost" 35 "10 cents opportunity cost", labsize(small) noticks) ///
		xtitle(Ride sequence) ///
		ytitle(Take up of reserved space) ///
		ysize(2) xsize(4)
	
	
	gr export "${out_graphs}/eventstudy_bypremium.png", replace width(5000)
	
*---------------------------------- The end -----------------------------------*
