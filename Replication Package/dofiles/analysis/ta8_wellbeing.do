/********************************************************************************
       PART 1: Define sample
********************************************************************************/
	
	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear
		
	lab var d_women_car "Assigned to reserved space"
	
	xtset user_id
		
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

			reg `var' [pw = weight] if d_women_car == 0
			local mean 	= el(r(table), 1,1)
			local se 	= el(r(table), 2,1)
			local se 	= round(`se', .001)
			local se 	= "(0`se')"
			
			reg `var' [pw = weight] if d_highcompliance == 0 & d_women_car == 0 & d_highcongestion == 0
			local mean_om 	= el(r(table), 1,1)
			local se_om 	= el(r(table), 2,1)
			local se_om 	= round(`se_om', .001)
			local se_om 	= "(0`se_om')"
			
			ivreg2 `var' d_women_car ///
				[pw = weight], ///
				cluster(user_id) 
				
			est sto `var'1
			estadd scalar mean  	`mean'
			estadd local  se 		`se'
			estadd scalar mean_om  	`mean_om'
			estadd local  se_om 	`se_om'
			
			ivreg2 `var' d_women_car ///
				d_highcongestion d_highcompliance i.user_id ///
				[pw = weight], ///
				cluster(user_id) ///
				partial(i.user_id)
				
			est sto `var'2
			estadd scalar mean  	`mean'
			estadd local  se 		`se'
			estadd scalar mean_om  	`mean_om'
			estadd local  se_om 	`se_om'
			
			ivreg2 `var' pink_highcompliance pink_lowcompliance mixed_highcompliance mixed_lowcompliance ///
				[pw = weight], ///
				nocons ///
				cluster(user_id) 
				
			est sto `var'3
			estadd 	local 	riders		`e(N_clust)'
			estadd 	scalar	obs			`e(N)'
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
			
			ivreg2 `var' pink_highcompliance pink_lowcompliance mixed_highcompliance mixed_lowcompliance ///
				d_highcongestion i.user_id ///
				[pw = weight], ///
				nocons ///
				cluster(user_id) ///
				partial(i.user_id)
				
			est sto `var'4
			estadd 	local 	riders		`e(N_clust)'
			estadd 	scalar	obs			`e(N)'
			estadd	local	user		"Yes"
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
			
			local top_main 			"`top_main' 		`var'2" 
			local top_appendix 		"`top_appendix' 	`var'1" 
			local bottom_main 		"`bottom_main' 		`var'4" 
			local bottom_appendix 	"`bottom_appendix' 	`var'3" 
					
		}
		
		foreach est in main appendix {
		
			local scalarmain	`" "user Rider fixed effect" "'	
			
			tableprep 	`top_`est'', ///
						panel(A) ///
						title(Overall impact of randomized assignment) ///
						depvar(Above median on self-reported scale) ///
						prehead("&  \begin{tabular}{@{}c@{}} Afraid of \\ harassment \end{tabular} & \begin{tabular}{@{}c@{}} Overall \\ wellbeing \end{tabular} & Happy & Sad & Tense & Relaxed & Frustrated & Satisfied & Vs before \\" )
	
			esttab 		`top_`est'' using "${out_github}/`spec'_wellbeing_`est'.tex",  ///
						`r(table_options)' ///
						noobs nomtitles ///
						scalars("mean Uncontrolled mean when assigned to public space" ///
								"se \," ///
								"mean_om Uncontrolled mean in omitted category" ///
								"se_om \,")
				
			tableprep 	`bottom_`est'', ///
						panel(B) ///
						title(Heterogeneous effects by male presence reserved space)
						
	
			esttab 		`bottom_`est'' using "${out_github}/`spec'_wellbeing_`est'.tex",  ///
						`r(table_options)' ///
						nomtitles nonumbers nolines ///
						order(mixed_lowcompliance pink_lowcompliance mixed_highcompliance pink_highcompliance) ///
						scalar("riders Riders" `scalar`est'' ///
							   "diff_high `r(footer_title)' \multicolumn{`r(ncols)'}{l}{By assigned space: assigned reserved space - assigned public space} \\ \quad $\Delta \hat\beta$ when few men in reserved space" "ftest_high \quad P-value" ///
							   "diff_low \quad $\Delta \hat\beta$ when many men in reserved space" "ftest_low  \quad P-value" ///
							   "diff_pink  \multicolumn{`r(ncols)'}{l}{By male presence in reserved space: few men - many men in reserved space} \\ \quad $\Delta \hat\beta$ when assigned reserved space" "ftest_pink \quad P-value" ///
							   "diff_mixed \quad $\Delta \hat\beta$ when assigned public space" "ftest_mixed \quad P-value")
				
			copy "${out_github}/`spec'_wellbeing_`est'.tex" "${out_tables}/`spec'_wellbeing_`est'.tex", replace

		}
	}
