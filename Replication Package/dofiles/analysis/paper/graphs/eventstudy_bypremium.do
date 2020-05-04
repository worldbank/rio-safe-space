/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:	${out_graphs}/eventstudy_bypremium.png
				
	WRITEN BY:  Luiza Andrade 
	
********************************************************************************
    PART 1: Prepare data
********************************************************************************/

	use "${dt_final}/pooled_rider_audit_constructed.dta", clear

	keep if phase != 3	// keep only willingness to pay rides

/*------------------------------------------------------------------------------
* We want to align the premia and use only the last 10 rides for each level,
* because that's the number of rides that should have been taken. Only a few
* riders took more than 10 rides
------------------------------------------------------------------------------*/

	* Order rides within premium level
	bys user_id phase premium: egen premium_ride = rank(ride)
	
	* Now we will identify the first ride at each premium level within the
	* whole ride sequencing, 
	gen first_premium_ride = ride if premium == 20 & premium_ride == 1
	bys user_id: egen firstpremiumride = max(first_premium_ride)
	gen premiumride = ride - firstpremiumride if premium == 0
	
	gen first_five_ride = ride if premium == 5 & premium_ride == 1
	bys user_id: egen firstfiveride = max(first_five_ride)
	replace premiumride = ride - firstfiveride if premium == 20
	
	gen first_ten_ride = ride if premium == 10 & premium_ride == 1
	bys user_id: egen firsttenride = max(first_ten_ride)
	replace premiumride = ride - firsttenride if premium == 5
	
	bys user_id: egen lastride = max(ride) if premium == 10
	
	sort user_id ride
	replace premiumride = ride - lastride if premium == 10
	
	drop if premiumride < -10 | premiumride > 0
	drop premium_ride
	bys user_id phase premium: egen premium_ride = rank(ride)
	
	replace premium_ride = premium_ride + 10 if premium == 20
	replace premium_ride = premium_ride + 20 if premium == 5
	replace premium_ride = premium_ride + 30 if premium == 10
	drop if premium_ride == 41

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
		(scatteri `cons20' 10 `cons20' 20, recast(connected) msymbol(none) lcolor(${col_1})) ///
		(scatteri `ul20' 10 `ul20' 20, recast(connected) lpattern(dash) msymbol(none) lcolor(${col_1})) ///
		(scatteri `ll20' 10 `ll20' 20, recast(connected) lpattern(dash) msymbol(none) lcolor(${col_1})) ///
		(scatteri `cons10' 30 `cons10' 40, recast(connected) msymbol(none) lcolor(${col_aux_light})) ///
		(scatteri `ul10' 30 `ul10' 40, recast(connected) lpattern(dash) msymbol(none) lcolor(${col_aux_light})) ///
		(scatteri `ll10' 30 `ll10' 40, recast(connected) lpattern(dash) msymbol(none) lcolor(${col_aux_light})) ///
		(scatteri `cons5' 20 `cons5' 30, recast(connected) msymbol(none) lcolor(${col_2})) ///
		(scatteri `ul5' 20 `ul5' 30, recast(connected) lpattern(dash) msymbol(none) lcolor(${col_2})) ///
		(scatteri `ll5' 20 `ll5' 30, recast(connected) lpattern(dash) msymbol(none) lcolor(${col_2})) ///
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
