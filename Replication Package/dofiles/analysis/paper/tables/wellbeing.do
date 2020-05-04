/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*   Impact of randomized assignment of car on fear and subjective well-being   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:	${out_tables}/paper_wellbeing_main.tex
				${out_tables}/paper_wellbeing_appendix.tex
				${out_tables}/online_wellbeing_main.tex
				${out_tables}/online_wellbeing_appendix.tex
				
	WRITEN BY:  Luiza Andrade [lcardoso@worldbank.org]

********************************************************************************
       PART 1: Define sample
********************************************************************************/
	
	use "${dt_final}/pooled_rider_audit_constructed.dta", clear
		
	* Adapt label for this table
	lab var d_women_car "Assigned to reserved space"
	
	* Only randomized car assignment rides
	keep if phase == 3 & missing(flag_nomapping)

	foreach spec in paper online {
	
	local top_main 			"" 
	local top_appendix 		"" 
	local bottom_main 		"" 
	local bottom_appendix 	"" 
	
	if "`spec'" == "online" {	
		keep if d_exit == 1 

	}
	else {
		keep if d_anyphase3 ==1
	}
	
/********************************************************************************
       PART 2: Run regressions
********************************************************************************/
		
		foreach var in concern_high feel_level_high happy_high sad_high tense_high relaxed_high frustrated_high satisfied_high feel_compare_high {

/*------------------------------------------------------------------------------
	Panel A
------------------------------------------------------------------------------*/

			* Uncontrolled mean
			reg `var' [pw = weight] if d_women_car == 0
			local mean 	= el(r(table), 1,1)
			local se 	= el(r(table), 2,1)
			local se 	= round(`se', .001)
			local se 	= "(0`se')"
			
			* No controls
			ivreg2 `var' d_women_car ///
				[pw = weight], ///
				cluster(user_id) 
				
			est sto `var'1
			estadd scalar mean  	`mean'
			estadd local  se 		`se'
			
			* With controls
			ivreg2 `var' d_women_car ///
				d_highcongestion d_highcompliance i.user_id ///
				[pw = weight], ///
				cluster(user_id) ///
				partial(i.user_id)
				
			est sto `var'2
			estadd scalar mean  	`mean'
			estadd local  se 		`se'
	
/*------------------------------------------------------------------------------
	Panel B
------------------------------------------------------------------------------*/

			* Uncontrolled mean under high compliance
			reg `var' [pw = weight] if d_women_car == 0 & d_highcompliance == 1
			
			local mean_high = el(r(table), 1,1)
			local se_high 	= el(r(table), 2,1)
			local se_high 	= round(`se_high', .001)
			local se_high 	= "(0`se_high')"
			
			* Uncontrolled mean under low compliance
			reg `var' [pw = weight] if d_women_car == 0 & d_highcompliance == 0
			
			local mean_low 	= el(r(table), 1,1)
			local se_low 	= el(r(table), 2,1)
			local se_low 	= round(`se_low', .001)
			local se_low 	= "(0`se_low')"
			
			* No controls
			ivreg2 `var' ${interactionvars} ///
				[pw = weight], ///
				nocons ///
				cluster(user_id) 
				
			est sto `var'3
			estadd local 	riders		`e(N_clust)'
			estadd local	obs			`e(N)'
			estadd scalar	mean_low	`mean_low'
			estadd local	se_low		`se_low'
			estadd scalar	mean_high	`mean_high'
			estadd local	se_high		`se_high'
			estadd scalar 	diff_pink	= _b[pink_highcompliance] 	- _b[pink_lowcompliance]
			estadd scalar 	diff_mixed	= _b[mixed_highcompliance] 	- _b[mixed_lowcompliance]
			estadd scalar 	diff_high	= _b[pink_highcompliance] 	- _b[mixed_highcompliance]
			estadd scalar 	diff_low	= _b[pink_lowcompliance] 	- _b[mixed_lowcompliance]
			
			test pink_highcompliance = pink_lowcompliance
			estadd scalar	ftest_pink		`r(p)'
					
			test mixed_highcompliance = mixed_lowcompliance
			estadd scalar	ftest_mixed		`r(p)'
					
			test pink_highcompliance = mixed_highcompliance
			estadd scalar	ftest_high		`r(p)'
				
			test pink_lowcompliance = mixed_lowcompliance
			estadd scalar	ftest_low		`r(p)'
			
			* With controls
			ivreg2 `var' ${interactionvars} ///
				d_highcongestion i.user_id ///
				[pw = weight], ///
				nocons ///
				cluster(user_id) ///
				partial(i.user_id)
				
			est sto `var'4
			estadd local 	riders		`e(N_clust)'
			estadd local	obs			`e(N)'
			estadd local	user		"Yes"
			estadd scalar	mean_low	`mean_low'
			estadd local	se_low		`se_low'
			estadd scalar	mean_high	`mean_high'
			estadd local	se_high		`se_high'
			estadd scalar 	diff_pink	= _b[pink_highcompliance] 	- _b[pink_lowcompliance]
			estadd scalar 	diff_mixed	= _b[mixed_highcompliance] 	- _b[mixed_lowcompliance]
			estadd scalar 	diff_high	= _b[pink_highcompliance] 	- _b[mixed_highcompliance]
			estadd scalar 	diff_low	= _b[pink_lowcompliance] 	- _b[mixed_lowcompliance]
			
			test pink_highcompliance = pink_lowcompliance
			estadd scalar	ftest_pink		`r(p)'
					
			test mixed_highcompliance = mixed_lowcompliance
			estadd scalar	ftest_mixed		`r(p)'
					
			test pink_highcompliance = mixed_highcompliance
			estadd scalar	ftest_high		`r(p)'
				
			test pink_lowcompliance = mixed_lowcompliance
			estadd scalar	ftest_low		`r(p)'
			
			* Get the right specification into the right table (main/appendix)
			local top_main 			"`top_main' 		`var'2" 
			local top_appendix 		"`top_appendix' 	`var'1" 
			local bottom_main 		"`bottom_main' 		`var'4" 
			local bottom_appendix 	"`bottom_appendix' 	`var'3" 
					
		}

/********************************************************************************
       PART 3: Export tables
********************************************************************************/

		foreach est in main appendix {
		
			local scalarmain	`" "user Rider fixed effect" "'	
			
			tableprep 	`top_`est'', ///
						panel(A) ///
						title(Overall impact of randomized assignment) ///
						depvar(Above median on self-reported scale) ///
						prehead("&  \begin{tabular}{@{}c@{}} Afraid of \\ harassment \end{tabular} & \begin{tabular}{@{}c@{}} Overall \\ wellbeing \end{tabular} & Happy & Sad & Tense & Relaxed & Frustrated & Satisfied & Vs before \\" )
	
			esttab 		`top_`est'' using "${out_tables}/delete_me.tex",  ///
						`r(table_options)' ///
						noobs nomtitles ///
						scalars("mean \multicolumn{10}{c}{\textit{Mean dependent variable}} \\ Assigned to public space" ///
								"se \,")
				
			tableprep 	`bottom_`est'', ///
						panel(B) ///
						title(Heterogeneous effects by male presence reserved space)
						
	
			esttab 		`bottom_`est'' using "${out_tables}/delete_me.tex",  ///
						`r(table_options)' ///
						nomtitles nonumbers noobs nolines ///
						scalar("mean_high \multicolumn{10}{c}{\textit{Mean dependent variable}} \\ Assigned to public space $\times$ Few men in reserved space" ///
							   "se_high \," ///
							   "mean_low Assigned to public space $\times$ Many men in reserved space" ///
							   "se_low \," ///
							   "obs Observations" ///
							   "riders Riders" `scalar`est'' ///
							   "diff_high `r(footer_title)' \multicolumn{`r(ncols)'}{l}{By assigned space: assigned reserved space - assigned public space} \\ \quad Few men in reserved space: $\hat\beta_{M_1}$ - $\hat\beta_{M_2}$" "ftest_high \quad P-value" ///
							   "diff_low \quad Many men in reserved space: $\hat\beta_{M_3}$ - $\hat\beta_{M_4}$" "ftest_low  \quad P-value" ///
							   "diff_pink  \multicolumn{`r(ncols)'}{l}{By male presence in reserved space: few men - many men in reserved space} \\ \quad Assigned reserved space: $\hat\beta_{M_4}$ - $\hat\beta_{M_2}$" "ftest_pink \quad P-value" ///
							   "diff_mixed \quad Assigned public space: $\hat\beta_{M_3}$ - $\hat\beta_{M_1}$" "ftest_mixed \quad P-value")
				
			
			* Fix the automatic escape of subscripts
			filefilter 	"${out_tables}/delete_me.tex" "${out_tables}/`spec'_wellbeing_`est'.tex", ///
						from("\BSbeta\BS_{M\BS_") to("\BSbeta_{M_") replace
				
			erase 		"${out_tables}/delete_me.tex"
			
		}
	}

*======================================================================= The end.	
