/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*				Back-of-envelope estimates of cost of harassment			   *
********************************************************************************

	OUTLINE	:	PART 1:   Take up and willingness to pay
				PART 1.1: Load data and keep the same sample as in the carimpactharassment.do
				PART 1.2: Calculate take up
				PART 1.3: Willingness to pay
				PART 2:   Percentage reduction in harassment
				PART 2.1: Load data and keep the same sample as in carimpactharassment.do
				PART 2.2: Overall: includes low and high compliance
				PART 2.3: By compliance
				PART 3:   Other necessary inputs
				PART 3.1: Average number of rides in a working year
				PART 3.2: Minimum wage and gender wage gap
				PART 4:   Calculate cost of harassment
				PART 5:   Rescale scalars to percentage points for table 
				PART 6:   Construct table 
				
	REQUIRES:	${dt_final}/pooled_rider_audit_constructed_full.dta
	CREATES:	${out_tables}/back_envelope_costs_full.tex
				
	WRITEN BY:  Kate Vyborny and Luiza Andrade

********************************************************************************
	PART 1: Take up and willingness to pay
********************************************************************************/

/*------------------------------------------------------------------------------
	PART 1.1: Load data and keep the same sample as in the carimpactharassment.do
------------------------------------------------------------------------------*/

	use "${dt_final}/pooled_rider_audit_constructed.dta", clear

	keep		if missing(flag_nomapping)

	* Analysis sample - for consistency with other tables 
	keep 		if d_anyphase3 == 1 
	keep 		if premium > 0 & premium < 60 

/*------------------------------------------------------------------------------
	PART 1.2: Calculate take up
------------------------------------------------------------------------------*/

	* ---------------------------------
	* Overall take-up when positive OC
	* ---------------------------------
	preserve
	
		keep		if phase == 2 & d_pos_premium > 0
		collapse 	d_women_car , by(user_uuid) 
		sum			d_women_car 

		scalar		takeup_total = r(mean) 

	restore 

	* --------------------
	* Take-up by quintile 
	* --------------------
	* Estimate
	xtreg 		d_women_car i.MA_compliance_diff_quint ///
				if phase == 2 & premium > 0 ///
				[pw = weightfe] ///
				, ///
				cluster(user_uuid) ///
				fe 			

	* Store values for Q1 and Q5
	margins MA_compliance_diff_quint
	mat margins = r(table)
	
	scalar takeup_q1	= round(margins[1,1], .001)
	scalar takeup_q5 	= round(margins[1,5], .001)
	scalar takeup_lower = takeup_q5 - takeup_q1

/*------------------------------------------------------------------------------
	PART 1.3 : Willingness to pay
--------------------------------------------------------------------------------
 To get mean WTP, multiply the numbers from section above by 20 cents. We cannot 
 reject that responses to all premia are equal, so participants who show 
 positive WTP on a given ride are assumed to have at least 20 cents WTP for 
 those rides 
------------------------------------------------------------------------------*/

	foreach column in total q1 q5 {

		scalar meanwtp_`column' = 0.2 * takeup_`column'

	}	

/* Lower bound estimates will be calculated following the formula below:
   (Takeup Q1 - Takeup Q5)/(DD difference in harassment protection Q1-Q5)
   Here we calculate the numerator 											*/

	scalar	meanwtp_lower = meanwtp_q5 - meanwtp_q1							// Lower bound - percentage of WTP due to harassment 
																			// 20 cents per ride * difference in takeup rates in lowest to highest quintile presence of men 

/********************************************************************************
	PART 2: Percentage reduction in harassment
********************************************************************************/

/*------------------------------------------------------------------------------
	PART 2.1: Load data and keep the same sample as in carimpactharassment.do
------------------------------------------------------------------------------*/

	use "${dt_final}/pooled_rider_audit_constructed.dta", clear

	* Only observations we have data on male presence in the spaces
	keep if missing(flag_nomapping)
	
	* Only randomized car assignment rides
	keep if phase == 3 

/*------------------------------------------------------------------------------
	PART 2.2: Overall: includes low and high compliance
------------------------------------------------------------------------------*/				

	* Calculate reduction in harassment (This is the same as line 59 on carimpactharassment.do)
	xtreg 	d_physical_har d_women_car ///
			[pw = weightfe], ///
			cluster(user_id) ///
			fe

	scalar diff_total = _b[d_women_car]

	* Calculate average harassment in public space (Same as line 39 in carimpactharassment.do)
	reg   	d_physical_har /// 
			[pw = weightfe] ///
			if d_women_car == 0

	scalar 	controlmean_total = _b[_cons] 
	scalar 	controlmean_diff  = _b[_cons] 	// different name just so we can use inside a loop

	* Reduction as percentage of average harassment in public space 
	scalar percentdiff_total = diff_total / controlmean_total


/*------------------------------------------------------------------------------
	PART 2.3: By compliance
------------------------------------------------------------------------------*/				

	* --------------------------------------------------------
	* Calculate impact on harassment across quintiles		
	* --------------------------------------------------------
	reghdfe d_physical_har i.pink_compliance_diff_quint ///
			[pw = weightfe] ///
			if phase == 3, ///
			absorb(MA_compliance_diff_quint user_id)

	* Store values protective effect Q1 and Q5
	foreach quint in 1 5 { 
		scalar		diff_q`quint' = _b[`quint'.pink_compliance_diff_quint] 

		sum			d_physical_har if phase == 3 & MA_compliance_diff_quint == `quint' & d_women_car == 0 
		scalar		controlmean_q`quint' = r(mean) 

		scalar		percentdiff_q`quint' = diff_q`quint' / controlmean_q`quint'
	}

	* Lower bound estimates are based on the difference in protective effect between Q1 and Q5
	scalar	diff_lower = diff_q5 - diff_q1 
	scalar 	percentdiff_lower = percentdiff_q5 - percentdiff_q1	
	scalar 	controlmean_lower = controlmean_q1								// Compare protective effect relative to harassment in public space Q1 
																			// Alternatively could compare relative to overall mean 
																			
/*******************************************************************************
	PART 3: Other necessary inputs
********************************************************************************/

/*------------------------------------------------------------------------------
	PART 3.1: Average number of rides in a working year
------------------------------------------------------------------------------*/

	use "${dt_final}/pooled_rider_audit_constructed.dta", clear

	keep user_id ride_frequency

	duplicates drop

	sum 	ride_frequency														// Old number was 6.5, which is the result we get from the data set at ride level, not rider
	local 	rides_year = r(mean) * 52											// From week to year

/*------------------------------------------------------------------------------
	PART 3.2: Minimum wage and gender wage gap
------------------------------------------------------------------------------*/

	local 	min_wage	3455													// 3455 is annual minimum wage in USD Source: https://riotimesonline.com/brazil-news/rio-business/brazils-government-raises-2017-
	local 	gender_gap 	= 3455 * (1 - .795)										// Female earnings 79.5% of male earnings - Source: IBGE 2019.  


/********************************************************************************
	PART 4: Calculate cost of harassment in different units
********************************************************************************/	

	foreach column in total q1 q5 lower {

		* Cost per ride
		scalar costperride_`column' 	 = meanwtp_`column' / (-1 * percentdiff_`column')

		* Cost per incident
		scalar costperincident_`column'  = meanwtp_`column' / ((controlmean_`column') * (-1 * percentdiff_`column'))

		* Per year
		scalar costperyear_`column' 	 = `rides_year' * costperride_`column'

		* As percentage of minimum wage
		scalar costperminwage_`column' 	 = costperyear_`column'/`min_wage'						

		* As percentage of gender wage gap
		scalar costpergendergap_`column' = costperyear_`column'/`gender_gap'						

	}	


/********************************************************************************
	PART 5: Rescale scalars to percentage points for table 
********************************************************************************/

	foreach scalar in percentdiff takeup diff controlmean costperminwage costperminwage_noresc costpergendergap {
		foreach setting in lowcomp highcomp q1 q5 total diff upper lower { 
			capture scalar `scalar'_`setting' = `scalar'_`setting' * 100 
		}										
	}


/********************************************************************************
	PART 6: Construct table 
********************************************************************************/

/*------------------------------------------------------------------------------
	PART 6.1: Paper version with lower bound 
------------------------------------------------------------------------------*/

	* relabel or add to footnotes: "men in reserved space" is "men in reserved space - men in public space"

	capture file close 	fulltable
			file open 	fulltable using "${out_tables}/back_envelope_costs_full.tex", write replace
			file write 	fulltable ///
				"\begin{tabular}{lcccc}"  																																																			 		   		 _n ///
				"	\hline\hline  \\[-1.8ex] " 																																																			   	   		 _n ///
				"	& \multirow{2}{*}{Overall} & \multicolumn{2}{c}{Men in reserved space} & Lower bound cost \\" 																																			   		 _n ///
				"	&  & Many men (Q1) & Few men (Q5)  & Q1 - Q5 \\"																																														   		 _n ///
				"	& (1) & (2) & (3) & (4)  \\" 																																																			   		 _n ///
				"	\hline   \\[-1.8ex]" 																																																						     _n ///
				"	a) Take up of reserved space on rides with positive opportunity cost ride  & 	 " %8.2f (takeup_total) 		 "\% &    " %8.2f (takeup_q1)  	   "\% &    " %8.2f (takeup_q5)  	   		"\% &    " %8.2f (takeup_lower)  	 	   " \%  \\" _n ///
				"	b) Average willingness to pay for reserved space 						   & \\$" %8.3f (meanwtp_total)		 	 "   & \\$" %8.3f (meanwtp_q1) 	   "   & \\$" %8.3f (meanwtp_q5) 	   		"   & \\$" %8.3f (meanwtp_lower)	  	   "     \\" _n ///
				"	c) Average occurrence of physical harassment in public space (\% of rides) &    " %8.2f (controlmean_total) 	 "\% &    " %8.2f (controlmean_q1) "\% &    " %8.2f (controlmean_q5) 		"\% &    " %8.2f (controlmean_lower) 	   " \%  \\" _n ///
				"	d) Change in physical harassment caused by riding reserved space (p.p.)    &    " %8.3f (diff_total)			 "   &    " %8.3f (diff_q1)		   "   &    " %8.3f (diff_q5)		   		"   &    " %8.3f (diff_lower)		 	   "     \\" _n ///
				"	e) Percent change in physical harassment caused by riding reserved space   &    " %8.1f (percentdiff_total) 	 "\% &    " %8.1f (percentdiff_q1) "\% &    " %8.1f (percentdiff_q5) 		"\% &    " %8.1f (percentdiff_lower) 	   " \%  \\" _n ///
				"	\multicolumn{5}{l}{f) Cost of harassment} \\" 																																															   		 _n ///
				"	f.1) Per ride 															   & \\$" %8.3f (costperride_total)	 	 "   &    "  					   "   & \\$" %8.3f (costperride_q5) 	    "   & \\$" %8.3f (costperride_lower)	   "     \\" _n ///
				"	f.2) Per incident 														   & \\$" %8.3f (costperincident_total)  "   &    "   					   "   & \\$" %8.3f (costperincident_q5)    "   & \\$" %8.3f (costperincident_lower)  "     \\" _n ///
				"	f.3) Per year 															   & \\$" %8.2f (costperyear_total)	 	 "   &    "  					   "   & \\$" %8.3f (costperyear_q5) 	    "   & \\$" %8.3f (costperyear_lower)	   "     \\" _n ///
				"	f.4) Percent of minimum wage 											   &    " %8.2f (costperminwage_total)   "\% &    "   					   "   & 	  " %8.2f (costperminwage_q5)   "\% &    " %8.2f (costperminwage_lower)   " \%  \\" _n ///				
				"	f.5) Percent of gender wage gap 										   &    " %8.2f (costpergendergap_total) "\% &    "  					   "   & 	  " %8.2f (costpergendergap_q5) "\% &    " %8.2f (costpergendergap_lower) " \%  \\" _n ///				
				"	\hline \hline"																																																									 _n ///
				"\end{tabular}"
			file close     fulltable

*********************************** The end ************************************
