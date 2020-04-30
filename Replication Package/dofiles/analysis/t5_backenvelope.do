
	
/********************************************************************************
	Take up and willingness to pay
********************************************************************************/

/*------------------------------------------------------------------------------
	Load data and keep the same sample as in the carimpactharassment.do
------------------------------------------------------------------------------*/
	
	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear
	
	* Analysis sample - for consistency with other tables 
	keep if d_anyphase3 == 1
	keep if premium > 0 & premium < 60 
	
	collapse d_women_car , by(user_id d_highcompliance) 
	
	* Overall take up
	sum 	d_women_car 
	scalar 	takeup_total 	= r(mean)

	* Take-up when few men in reserved space
	sum 	d_women_car 	if d_highcompliance == 1 
	scalar 	takeup_highcomp = r(mean)
	
	* Take-up when many men in reserved space
	sum 	d_women_car 	if d_highcompliance==0 
	scalar 	takeup_lowcomp 	= r(mean)
		
/*------------------------------------------------------------------------------
	Willingness to pay
--------------------------------------------------------------------------------
 To get mean WTP, multiply the numbers from section above by 20 cents. We cannot 
 reject that responses to all premia are equal, so participants who show 
 positive WTP on a given ride are assumed to have at least 20 cents WTP for 
 those rides 
------------------------------------------------------------------------------*/

	foreach column in total highcomp lowcomp {
	
		scalar meanwtp_`column' = 0.2 * takeup_`column'
	
	}	
	
/********************************************************************************
	Percentage reduction in harassment
********************************************************************************/

/*------------------------------------------------------------------------------
	Load data and keep the same sample as in carimpactharassment.do
------------------------------------------------------------------------------*/

	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear
			
	* Only randomized car assignment rides
	keep if phase == 3 & missing(flag_nomapping)
				
/*------------------------------------------------------------------------------
	Overall: includes low and high compliance
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
	By compliance
------------------------------------------------------------------------------*/				

	* --------------------------------------------------------
	* Calculate reduction in harassment 			
	* --------------------------------------------------------
	
	* This is the same as line 164 on carimpactharassment.do
	reg d_physical_har 	${interactionvars}	i.user_id  ///
		[pw = weightfe], ///
		nocons ///
		cluster(user_id)
	
	* Get difference under each compliance level
	scalar 	diff_high	= _b[pink_highcompliance] 	- _b[mixed_highcompliance]
	scalar 	diff_low	= _b[pink_lowcompliance] 	- _b[mixed_lowcompliance]
	
	* --------------------------------------------------------
	* Average in public space, using regressions for weighting
	* --------------------------------------------------------
	
	*  Low compliance: this is the same regression as line 233 in carimpactharassment.do
	reg d_physical_har ///
		[pw = weightfe] ///
		if d_women_car == 0 & d_highcompliance == 0
	
	scalar controlmean_lowcomp = _b[_cons]
	
	*  High compliance: this is the same regression as line 221 in carimpactharassment.do
	reg d_physical_har ///
		[pw = weightfe] ///
		if d_women_car == 0 & d_highcompliance == 1

	scalar controlmean_highcomp = _b[_cons]
	
	* ----------------------------------------------------------
	* Reduction in harassment as percent of public space average
	* ----------------------------------------------------------
	
	scalar percentdiff_lowcomp 	= diff_low / controlmean_lowcomp
	scalar percentdiff_highcomp = diff_high / controlmean_highcomp
			
/********************************************************************************
	Other necessary inputs
********************************************************************************/

/*------------------------------------------------------------------------------
	Difference in main outcomes between compliance levels
------------------------------------------------------------------------------*/
	
	scalar takeup_diff 		= takeup_highcomp - takeup_lowcomp
	scalar meanwtp_diff 	= meanwtp_highcomp - meanwtp_lowcomp
	scalar percentdiff_diff = percentdiff_highcomp - percentdiff_lowcomp 

/*------------------------------------------------------------------------------
	Average number of rides in a working year
------------------------------------------------------------------------------*/

	use "${dt_rider_fin}\pooled_rider_audit_constructed.dta", clear
	
	keep user_id ride_frequency
	
	duplicates drop
	
	sum 	ride_frequency														// Old number was 6.5, which is the result we get from the data set at ride level, not rider
	local 	rides_year = r(mean) * 52											// From week to year

/*------------------------------------------------------------------------------
	Minimum wage
------------------------------------------------------------------------------*/

	local 	min_wage	3455													// 3455 is annual minimum wage in USD Source: https://riotimesonline.com/brazil-news/rio-business/brazils-government-raises-2017-
	
	
/********************************************************************************
	Calculate cost of harassment
********************************************************************************/

	foreach column in total highcomp lowcomp diff {
		
		* Cost per ride
		scalar costperride_`column' = meanwtp_`column' / (-1 * percentdiff_`column')
		
		* Cost per incident
		scalar costperincident_`column' = meanwtp_`column' / ((controlmean_`column') * (-1 * percentdiff_`column'))

		* Per year
		scalar costperyear_`column' 	= `rides_year' * costperride_`column'
		
		* As percentage of minimum wage
		scalar costperminwage_`column' 	= costperyear_`column'/`min_wage'						
		
		* Per year - not rescaling for % decrease in harassment (e.g. stigma is part of the cost)
		scalar costperyear_noresc_`column' 	= `rides_year' * meanwtp_`column'		
		
		* As % of minimum wage - not rescaling for % decrease in harassment (e.g. stigma is part of the cost)
		scalar costperminwage_noresc_`column' 	= costperyear_`column' / `min_wage' 
		
	}	
	
/********************************************************************************
	Construct table 
********************************************************************************/
	
/*------------------------------------------------------------------------------
	Rescale scalars to percentage points for table 
------------------------------------------------------------------------------*/
	
	foreach scalar in 	percentdiff_lowcomp percentdiff_highcomp percentdiff_total percentdiff_diff ///
						takeup_lowcomp takeup_highcomp takeup_total takeup_diff ///
						diff_low diff_high diff_total ///
						controlmean_total controlmean_lowcomp controlmean_highcomp controlmean_diff ///
						costperminwage_total costperminwage_highcomp costperminwage_lowcomp costperminwage_diff {
		
			scalar `scalar' = `scalar' * 100 
	}										
	
	
	scalar x = .																// Table spacer 
		
/********************************************************************************
	Construct table 
********************************************************************************/

/*------------------------------------------------------------------------------
	Short version
------------------------------------------------------------------------------*/	

	capture file close 	shorttable
			file open 	shorttable using "${out_github}/back_envelope_costs_short.tex", write replace
			file write 	shorttable ///
				"\begin{tabular}{lccc}"  																																		   _n ///
				"	\hline\hline  \\[-1.8ex] " 																																	   _n ///
				"							& \multirow{2}{*}{Overall} 				  & \multicolumn{2}{c}{Men in reserved space}  								 			   \\" _n ///
				"							&  										  & Few men  								   & Many men  								   \\" _n ///
				"							& (1) 									  & (2) 									   & (3) 									   \\" _n ///
				"	\hline   \\[-1.8ex]" 																																	       _n ///
				"	Per ride 				& \\$" %8.2f (costperride_total)	 "    & \\$" %8.2f (costperride_highcomp) 	  "    & \\$" %8.2f (costperride_lowcomp) 	  "    \\" _n ///
				"	Rescaling for % harassment & 									& 												& 										   \\" _n ///				
				"	Per incident 			& \\$" %8.2f (costperincident_total) "    & \\$" %8.2f (costperincident_highcomp) "    & \\$" %8.2f (costperincident_lowcomp) "    \\" _n ///
				"	Per year 				& \\$" %8.2f (costperyear_total)	 "    & \\$" %8.3f (costperyear_highcomp) 	  "    & \\$" %8.2f (costperyear_lowcomp) 	  "    \\" _n ///
				"	Percent of minimum wage &    " %8.2f (costperminwage_total)  " \% &    " %8.2f (costperminwage_highcomp)  " \% &    " %8.2f (costperminwage_lowcomp)  " \% \\" _n ///
				"	Not rescaling for % harassment & 									& 												& 										   \\" _n ///				
				"	Per year 				& \\$" %8.2f (costperyear_noresc_total)	 "    & \\$" %8.3f (costperyear_noresc_highcomp) 	  "    & \\$" %8.2f (costperyear_noresc_lowcomp) 	  "    \\" _n ///
				"	Percent of minimum wage &    " %8.2f (costperminwage_noresc_total)  " \% &    " %8.2f (costperminwage_noresc_highcomp)  " \% &    " %8.2f (costperminwage_noresc_lowcomp)  " \% \\" _n ///				
				"	\hline \hline"																																		 		   _n ///
				"\end{tabular}"
			file close     shorttable

	copy "${out_github}/back_envelope_costs_short.tex" "${out_tables}/back_envelope_costs_short.tex", replace
	
/*------------------------------------------------------------------------------
	Paper version
------------------------------------------------------------------------------*/
	
	capture file close 	fulltable
			file open 	fulltable using "${out_github}/back_envelope_costs_full.tex", write replace
			file write 	fulltable ///
				"\begin{tabular}{lcccc}"  																																																						    		   _n ///
				"	\hline\hline  \\[-1.8ex] " 																																																								   _n ///
				"	& \multirow{2}{*}{Overall} & \multicolumn{2}{c}{Men in reserved space} & \multirow{2}{*}{Difference} \\" 																																				   _n ///
				"	&  & Few men  & Many men  &  \\"																																																						   _n ///
				"	& (1) & (2) & (3) & (4) \\" 																																																							   _n ///
				"	\hline   \\[-1.8ex]" 																																																									   _n ///
				"	a) Take up of reserved space on rides with positive opportunity cost ride  & 	 " %8.2f (takeup_total) 		 " \% &    " %8.2f (takeup_highcomp)  		 " \% &    " %8.2f (takeup_lowcomp)  		 " \% &    " %8.2f (takeup_diff)		  " \% \\" _n ///
				"	b) Average willingness to pay for reserved space 						   & \\$" %8.3f (meanwtp_total)		 	 "    & \\$" %8.3f (meanwtp_highcomp) 		 "    & \\$" %8.3f (meanwtp_lowcomp) 		 "    & \\$" %8.3f (meanwtp_diff)		  "    \\" _n ///
				"	c) Average occurrence of physical harassment in public space (\% of rides) &    " %8.2f (controlmean_total) 	 " \% &    " %8.2f (controlmean_highcomp)    " \% &    " %8.2f (controlmean_lowcomp) 	 " \% &   						  		 	   \\" _n ///
				"	d) Change in physical harassment when riding reserved space (p.p.) 		   &    " %8.3f (diff_total)			 "    &    " %8.3f (diff_high)				 "    &    " %8.3f (diff_low)				 "    &  						      		   \\" _n ///
				"	e) Percent change in physical harassment when riding reserved space 	   &    " %8.1f (percentdiff_total) 	 " \% &    " %8.1f (percentdiff_highcomp)    " \% &    " %8.1f (percentdiff_lowcomp)  	 " \% &    " %8.1f (percentdiff_diff)	  " \% \\" _n ///
				"	\multicolumn{5}{l}{f) Cost of harassment} \\" 																																																		 	   _n ///
				"	f.1) Per ride 															   & \\$" %8.3f (costperride_total)	 	"    & \\$" %8.3f (costperride_highcomp) 	 "    & \\$" %8.3f (costperride_lowcomp) 	 "    & \\$" %8.3f (costperride_diff)	  "    \\" _n ///
				"	f.2) Per incident 														   & \\$" %8.3f (costperincident_total) "    & \\$" %8.3f (costperincident_highcomp) "    & \\$" %8.3f (costperincident_lowcomp) "    & \\$" %8.3f (costperincident_diff) "    \\" _n ///
				"	f.3) Per year 															   & \\$" %8.2f (costperyear_total)	 	"    & \\$" %8.3f (costperyear_highcomp) 	 "    & \\$" %8.2f (costperyear_lowcomp) 	 "    & \\$" %8.3f (costperyear_diff)	  "    \\" _n ///
				"	f.4) Percent of minimum wage 											   &    " %8.2f (costperminwage_total)  " \% &    " %8.2f (costperminwage_highcomp)  " \% &    " %8.2f (costperminwage_lowcomp)  " \% &    " %8.2f (costperminwage_diff)  " \% \\" _n ///				
				"	\hline \hline"																																																									 		   _n ///
				"\end{tabular}"
			file close     fulltable

	copy "${out_github}/back_envelope_costs_full.tex" "${out_tables}/back_envelope_costs_full.tex", replace		
		
/*------------------------------------------------------------------------------
	Paper version - diff column
------------------------------------------------------------------------------*/

	capture file close 	table3col
			file open 	table3col using "${out_github}/back_envelope_costs_3col.tex", write replace
			file write 	table3col ///
				"\begin{tabular}{lccc}"  																																															  _n ///
				"	\hline\hline  \\[-1.8ex] " 																																														  _n ///
				"	& \multirow{2}{*}{Overall} & \multicolumn{2}{c}{Men in reserved space} \\" 																																		  _n ///
				"	&  & Few men  & Many men \\"																																													  _n ///
				"	& (1) & (2) & (3) \\" 																																															  _n ///
				"	\hline   \\[-1.8ex]" 																																															  _n ///
				"	a) Take up of reserved space on rides with positive opportunity cost ride  & 	 " %8.2f (takeup_total) 		 " \% &    " %8.2f (takeup_highcomp)  		 " \% &    " %8.2f (takeup_lowcomp)  		 " \% \\" _n ///
				"	b) Average willingness to pay for reserved space 						   & \\$" %8.3f (meanwtp_total)		 	 "    & \\$" %8.3f (meanwtp_highcomp) 		 "    & \\$" %8.3f (meanwtp_lowcomp) 		 "    \\" _n ///
				"	c) Average occurrence of physical harassment in public space (\% of rides) &    " %8.2f (controlmean_total) 	 " \% &    " %8.2f (controlmean_highcomp)    " \% &    " %8.2f (controlmean_lowcomp) 	 " \% \\" _n ///
				"	d) Change in physical harassment when riding reserved space (p.p.) 		   &    " %8.3f (diff_total)			 "    &    " %8.3f (diff_high)				 "    &    " %8.3f (diff_low)				 "    \\" _n ///
				"	e) Percent change in physical harassment when riding reserved space 	   &    " %8.1f (percentdiff_total) 	 " \% &    " %8.1f (percentdiff_highcomp)    " \% &    " %8.1f (percentdiff_lowcomp)  	 " \% \\" _n ///
				"	\multicolumn{5}{l}{f) Cost of harassment} \\" 																																									  _n ///
				"	f.1) Per ride 															   & \\$" %8.3f (costperride_total)	 	"    & \\$" %8.3f (costperride_highcomp) 	 "    & \\$" %8.3f (costperride_lowcomp) 	 "    \\" _n ///
				"	f.2) Per incident 														   & \\$" %8.3f (costperincident_total) "    & \\$" %8.3f (costperincident_highcomp) "    & \\$" %8.3f (costperincident_lowcomp) "    \\" _n ///
				"	f.3) Per year 															   & \\$" %8.2f (costperyear_total)	 	"    & \\$" %8.3f (costperyear_highcomp) 	 "    & \\$" %8.2f (costperyear_lowcomp) 	 "    \\" _n ///
				"	f.4) Percent of minimum wage 											   &    " %8.2f (costperminwage_total)  " \% &    " %8.2f (costperminwage_highcomp)  " \% &    " %8.2f (costperminwage_lowcomp)  " \% \\" _n ///
				"	\hline \hline"																																																	  _n ///
				"\end{tabular}"
			file close     table3col

	copy "${out_github}/back_envelope_costs_3col.tex" "${out_tables}/back_envelope_costs_3col.tex", replace		

*********************************** The end ************************************
