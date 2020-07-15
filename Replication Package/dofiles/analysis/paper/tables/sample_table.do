/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*						 Sample size description							   *
********************************************************************************

	OUTLINE:	PART 1:   Calculate rider audit numbers
				PART 1.1: Demographic survey
				PART 1.2: Rider reports
				PART 1.3: Exit survey
				PART 2:   Platform survey
				PART 2.1: Approached
				PART 2.2: Accepted
				PART 2.3: Finished
				PART 3:   IAT survey
				PART 3.1: Approached
				PART 3.2: Accepted
				PART 3.3: Finished
				PART 4:   Export table
	
	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
				${dt_final}/platform_survey_constructed.dta
	CREATES:	${out_tables}/sample_table.tex
				
	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]

********************************************************************************
	PART 1: Calculate rider audit numbers
*******************************************************************************/

	use "${dt_final}/pooled_rider_audit_constructed.dta", clear
	
/*------------------------------------------------------------------------------
	PART 1.1: Demographic survey
------------------------------------------------------------------------------*/

	preserve
	
		* Rider level data sets
		duplicates drop user_uuid, force
		
		* Total number of riders
		local total_rider = _N

		* Riders who took demo survey
		qui count if !flag_nodemovars
		
		local  n_demo 	= r(N)							// Number
		scalar n_demo 	= `n_demo'
		scalar pct_demo = (`n_demo'/`total_rider')*100 // Percentage of riders
	
	restore
	
/*------------------------------------------------------------------------------
	PART 1.2: Rider reports
------------------------------------------------------------------------------*/

	* All rides
	local 	total_rides = _N	
	
	/* Phases are: (1) baseline rides (2) OC rides (3) car assignment rides */
	
	recode phase (1 = 2) // We have dropped users who only took baseline rides, and are bundling baseline and OC rides together for description of phases
	
	forvalues phase = 2/3 {
	
		preserve
			
			* Total number of rides in this phase
			count if phase == `phase'
	
			local  n_phase`phase' = r(N)
			scalar n_phase`phase' = `n_phase`phase''
							
			* Number of riders in this phase
			collapse (count) stage, by(user_uuid phase)
			
			count if phase == `phase'
			
			local 	n_r_phase`phase' 	= r(N)
			scalar 	n_r_phase`phase' 	= `n_r_phase`phase''						// Number
			scalar 	pct_r_phase`phase' 	= (`n_r_phase`phase''/`total_rider') * 100  // Percentage of riders
			
			* Average number of rides per rider
			sum 	stage if phase == `phase'
			scalar 	mean_phase`phase' = r(mean)
			
						
		restore
	}
	
/*------------------------------------------------------------------------------
	PART 1.3: Exit survey
------------------------------------------------------------------------------*/

	preserve
	
		duplicates drop user_uuid, force
		drop if d_exit != 1
		
		local  	n_exit = _N
		scalar 	n_exit = `n_exit'					// Number
		scalar  pct_exit = (_N/`total_rider')*100	// Percentage of riders
		
	restore
	
/*******************************************************************************
	PART 2: Platform survey
*******************************************************************************/

	use "${dt_final}/platform_survey_constructed.dta", clear

/*------------------------------------------------------------------------------
	PART 2.1: Approached
------------------------------------------------------------------------------*/
	
	* Men
	qui count if d_woman == 0
	
	local 	n_ap_men = r(N)
	scalar	n_ap_men = `n_ap_men'
	
	* Women
	qui count if d_woman == 1
	
	local 	n_ap_women = r(N)
	scalar	n_ap_women = `n_ap_women'
	
/*------------------------------------------------------------------------------
	PART 2.2: Accepted
------------------------------------------------------------------------------*/
	
	* Men
	qui count if d_accepted == 1 & d_woman == 0
	
	local 	n_ac_men = r(N)
	scalar 	n_ac_men = `n_ac_men'
	scalar 	pct_ac_men = (`n_ac_men'/`n_ap_men')*100
	
	* Women
	qui count if d_accepted == 1 & d_woman == 1
	
	local 	n_ac_women = r(N)
	scalar 	n_ac_women = `n_ac_women'
	scalar 	pct_ac_women = (`n_ac_women'/`n_ap_women')*100
	
/*------------------------------------------------------------------------------
	PART 2.3: Finished
------------------------------------------------------------------------------*/

	* Men
	qui count if d_finished == 1 & d_woman == 0
	
	local 	n_fi_men = r(N)
	scalar 	n_fi_men = `n_fi_men'
	scalar 	pct_fi_men = (`n_fi_men'/`n_ac_men')*100

	* Women
	qui count if d_finished == 1 & d_woman == 1
	
	local 	n_fi_women = r(N)
	scalar 	n_fi_women = `n_fi_women'
	scalar 	pct_fi_women = (`n_fi_women'/`n_ac_women')*100


/*******************************************************************************
	PART 3: IAT survey
*******************************************************************************/

/*------------------------------------------------------------------------------
	PART 3.1: Approached
------------------------------------------------------------------------------*/

	* Men
	qui count if d_iat_invited == 1 & d_woman == 0
	
	local 	n_ii_men = r(N)
	scalar 	n_ii_men = `n_ii_men'
	scalar 	pct_ii_men = (`n_ii_men'/`n_ac_men')*100

	* Women
	qui count if d_iat_invited == 1 & d_woman == 1
	
	local 	n_ii_women = r(N)
	scalar 	n_ii_women = `n_ii_women'
	scalar 	pct_ii_women = (`n_ii_women'/`n_ac_women')*100
	
/*------------------------------------------------------------------------------
	PART 3.2: Accepted
------------------------------------------------------------------------------*/

	* Men
	qui count if d_iat == 1 & d_woman == 0
	
	local 	n_ia_men = r(N)
	scalar 	n_ia_men = `n_ia_men'
	scalar 	pct_ia_men = (`n_ia_men'/`n_ii_men')*100
	
	* Women
	qui count if d_iat == 1 & d_woman == 1
	
	local 	n_ia_women = r(N)
	scalar 	n_ia_women = `n_ia_women'
	scalar 	pct_ia_women = (`n_ia_women'/`n_ii_women')*100

/*------------------------------------------------------------------------------
	PART 3.3: Finished
------------------------------------------------------------------------------*/

	* Men
	qui count if d_iat_finished == 1 & d_woman == 0
	
	local 	n_if_men = r(N)
	scalar 	n_if_men = `n_if_men'
	scalar 	pct_if_men = (`n_if_men'/`n_ia_men')*100
	
	* Women
	qui count if d_iat_finished == 1 & d_woman == 1
	
	local 	n_if_women = r(N)
	scalar 	n_if_women = `n_if_women'
	scalar 	pct_if_women = (`n_if_women'/`n_ia_women')*100
	
/*******************************************************************************
	PART 4: Export table
*******************************************************************************/

	capture file close descTable
		file open 	descTable using "${out_tables}/sample_table.tex", write replace
		file write 	descTable ///
					"\begin{tabular}{lccC{2.5cm}C{3.2cm}}"  																												 		  _n ///
					"\\[-1.8ex]\hline \hline \\[-1.8ex]" 																													 		  _n ///
					"\multicolumn{5}{c}{\textit{Panel A: Rider reports}}                     																 		 	\\\\[-1.8ex]" _n ///
					"					   					& Number of riders 		  & \% of riders 			 & Total number of rides & Average number of rides per rider	\\\hline \\[-1.8ex]" _n ///
					"Demographic survey answered			& " %8.2gc (n_demo) "	  &  " %8.1f (pct_demo) "    &            			 &   			 	     		\\\\[-1.8ex]" _n ///
					"\multicolumn{5}{l}{Rides phase started}                                       													 							  \\" _n ///
					"1. Revealed preference					& " %8.2gc (n_r_phase2) " & " %8.1f (pct_r_phase2) " & " %8.2gc (n_phase2) " & " %8.0f (mean_phase2) "  			  \\" _n ///
					"2. Random assignment to reserved space	& " %8.2gc (n_r_phase3) " & " %8.1f (pct_r_phase3) " & " %8.2gc (n_phase3) " & " %8.0f (mean_phase3) "		\\\\[-1.8ex]" _n ///
					"Exit survey  answered					& " %8.2gc (n_exit) "	  & " %8.1f (pct_exit) "     &            			 &   	 								  \\" _n ///
					"\\[-1.8ex]\hline \hline \\[-1.8ex]" 																															  _n ///
					"\multicolumn{5}{c}{\textit{Panel B: Platform survey and IAT}}                  																	\\\\[-1.8ex]" _n ///
					"					   					& Women		  			  & Response rate (\%)	  	 & Men   		  		 & Response rate (\%)	 \\\hline \\[-1.8ex]" _n ///
					"\multicolumn{5}{l}{Platform survey}                                   											 				 							  \\" _n ///
					"\quad Approached         				& " %8.2gc (n_ap_women) " &   						 & " %8.2gc (n_ap_men) " &   						 			  \\" _n ///
					"\quad Accepted            				& " %8.2gc (n_ac_women) " & " %8.1f (pct_ac_women) "\$^{1}\$ & " %8.2gc (n_ac_men) " & " %8.1f (pct_ac_men) "  		  \\" _n ///
					"\quad Finished		          			& " %8.2gc (n_fi_women) " & " %8.1f (pct_fi_women) "\$^{2}\$ & " %8.2gc (n_fi_men) " & " %8.1f (pct_fi_men) "\\\\[-1.8ex]" _n ///
					"\multicolumn{5}{l}{IAT}                                            																						  \\" _n ///
					"\quad Approached          				& " %8.2gc (n_ii_women) " & " %8.1f (pct_ii_women) " & " %8.2gc (n_ii_men) " & " %8.1f (pct_ii_men) "  				  \\" _n ///
					"\quad Accepted            				& " %8.2gc (n_ia_women) " & " %8.1f (pct_ia_women) "\$^{1}\$ & " %8.2gc (n_ia_men) " & " %8.1f (pct_ia_men) "  		  \\" _n ///
					"\quad Finished     	 				& " %8.2gc (n_if_women) " & " %8.1f (pct_if_women) "\$^{2}\$ & " %8.2gc (n_if_men) " & " %8.1f (pct_if_men) "  		  \\" _n ///
					"\hline \hline \\[-1.8ex]" 																																  		  _n ///
					"\end{tabular}"	
		file close 	descTable

*--------------------------------- The end ------------------------------------*
