/********************************************************************************
       PART 1: Define sample
********************************************************************************/

	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear

	* Only baseline and price experiment rider
	keep if inlist(phase, 1, 2)
	
	* Drop user with no mapping observations (missing compliance)
	drop if flag_nomapping == 1
	
	
/********************************************************************************
       PART 2: Create new variables
********************************************************************************/

	gen 		zero_highcompliance = 	(d_pos_premium == 0 & d_highcompliance == 1) if !missing(d_pos_premium) & !missing(d_highcompliance)
	lab var		zero_highcompliance		"Few men in reserved space \$\times\$ zero opportunity cost"
	gen 		pos_highcompliance = 	(d_pos_premium == 1 & d_highcompliance == 1) if !missing(d_pos_premium) & !missing(d_highcompliance)
	lab var		pos_highcompliance		"Few men in reserved space \$\times\$ positive opportunity cost"
	gen 		zero_lowcompliance = 	(d_pos_premium == 0 & d_highcompliance == 0) if !missing(d_pos_premium) & !missing(d_highcompliance)
	lab var		zero_lowcompliance		"Many men in reserved space \$\times\$ zero opportunity cost"
	gen 		pos_lowcompliance = 	(d_pos_premium == 1 & d_highcompliance == 0) if !missing(d_pos_premium) & !missing(d_highcompliance)
	lab var		pos_lowcompliance		"Many men in reserved space \$\times\$ positive opportunity cost"

/********************************************************************************
	PART 3: Run regressions
********************************************************************************/	

	foreach spec in paper online {
	
		if "`spec'" == "online" {
			keep if d_exit == 1
		}
		else {
			keep if d_anyphase2 == 1
		}
		
		reg d_women_car if d_pos_premium == 0 ///
			[pw = weightfe], ///
			cluster(user_id)
			
		local mean_zero = el(r(table), 1,1)
		local mean_zero	= round(`mean_zero', .001)
		local mean_zero "0`mean_zero'"
		local se_zero   = el(r(table), 2,1)
		local se_zero	= round(`se_zero', .001)
		local se_zero 	"(0`se_zero')"
		
		reg d_women_car if d_pos_premium == 0 & d_highcompliance == 0 & d_highcongestion == 0 ///
			[pw = weightfe], ///
			cluster(user_id)
			
		local mean_zero_low = el(r(table), 1,1)
		local se_zero_low   = el(r(table), 2,1)
		local se_zero_low	= round(`se_zero_low', .001)
		local se_zero_low 	"(0`se_zero_low')"
		
/*------------------------------------------------------------------------------
	PART 3.1: Top panel
------------------------------------------------------------------------------*/
	
		***************
		* No controls *
		***************
		
		reg d_women_car d_pos_premium ///
			[pw = weightfe], ///
			cluster(user_id)

		eststo appendix1	
		
		***********
		* Line FE *
		***********
		
		areg d_women_car d_pos_premium ///
			[pw = weightfe], ///
			cluster(user_id) ///
			absorb(CI_line)
		
		eststo appendix2		 
		
		***********
		* User FE *
		***********
		
		xtreg d_women_car d_pos_premium ///
			[pw = weightfe], ///
			cluster(user_id) fe
		
		eststo main1
		
		estadd scalar mean_zero `mean_zero'
		estadd local  se_zero 	`se_zero'	
		
		************************
		* User FE + congestion *
		************************
		
		xtreg d_women_car d_pos_premium  ///
			d_highcongestion d_highcompliance ///
			[pw = weightfe], ///
			cluster(user_id) fe
		
		eststo main2
		
		estadd scalar mean_zero_low `mean_zero_low'
		estadd local  se_zero_low 	`se_zero_low'	
	
/*------------------------------------------------------------------------------
	PART 3.2: Bottom panel
------------------------------------------------------------------------------*/	
	
		***************
		* No controls *
		***************
		
		reg d_women_car zero_lowcompliance pos_lowcompliance zero_highcompliance pos_highcompliance ///
				[pw = weightfe], ///
				cluster(user_id) nocons
		
		eststo appendix3
		estadd local  		riders		"`e(N_clust)'"
		estadd local  		user		"No"
		
		lincom zero_highcompliance - zero_lowcompliance
		estadd scalar 		diff_zero	`r(estimate)'
		estadd scalar		ftest_zero	`r(p)'
		
		lincom pos_highcompliance - pos_lowcompliance
		estadd scalar 		diff_pos	`r(estimate)'
		estadd scalar		ftest_pos	`r(p)'
		
		lincom zero_highcompliance - pos_highcompliance
		estadd scalar 		diff_high	`r(estimate)'
		estadd scalar		ftest_high	`r(p)'
		
		lincom zero_lowcompliance - pos_lowcompliance
		estadd scalar		diff_low	`r(estimate)'
		estadd scalar		ftest_low	`r(p)'
		
		***********
		* Line FE *
		***********
		
		reg d_women_car zero_lowcompliance pos_lowcompliance zero_highcompliance pos_highcompliance ///
			I.CI_line ///
			[pw = weightfe], ///
			cluster(user_id) nocons
		
		eststo appendix4
		estadd local  		riders		"`e(N_clust)'"
		estadd local  		user		"Yes"
		
		lincom zero_highcompliance - zero_lowcompliance
		estadd scalar 		diff_zero	`r(estimate)'
		estadd scalar		ftest_zero	`r(p)'
		
		lincom pos_highcompliance - pos_lowcompliance
		estadd scalar 		diff_pos	`r(estimate)'
		estadd scalar		ftest_pos	`r(p)'
		
		lincom zero_highcompliance - pos_highcompliance
		estadd scalar 		diff_high	`r(estimate)'
		estadd scalar		ftest_high	`r(p)'
		
		lincom zero_lowcompliance - pos_lowcompliance
		estadd scalar		diff_low	`r(estimate)'
		estadd scalar		ftest_low	`r(p)'		
		
		***********
		* User FE *
		***********	
		
		reg d_women_car  zero_lowcompliance pos_lowcompliance zero_highcompliance pos_highcompliance ///
			i.user_id ///
			[pw = weightfe], ///
			cluster(user_id) nocons
		
		eststo main3
		estadd local  		riders		"`e(N_clust)'"
		estadd local  		user		"Yes"
		
		lincom zero_highcompliance - zero_lowcompliance
		estadd scalar 		diff_zero	`r(estimate)'
		estadd scalar		ftest_zero	`r(p)'
		
		lincom pos_highcompliance - pos_lowcompliance
		estadd scalar 		diff_pos	`r(estimate)'
		estadd scalar		ftest_pos	`r(p)'
		
		lincom zero_highcompliance - pos_highcompliance
		estadd scalar 		diff_high	`r(estimate)'
		estadd scalar		ftest_high	`r(p)'
	
		lincom zero_lowcompliance - pos_lowcompliance
		estadd scalar		diff_low	`r(estimate)'
		estadd scalar		ftest_low	`r(p)'
		
		************************
		* User FE + congestion *
		************************
		
		reg d_women_car  zero_lowcompliance pos_lowcompliance zero_highcompliance pos_highcompliance ///
				d_highcongestion ///
				i.user_id ///
				[pw = weightfe], ///
				cluster(user_id) nocons
		
		eststo main4
		estadd local  		riders		"`e(N_clust)'"
		estadd local  		user		"Yes"
		
		lincom zero_highcompliance - zero_lowcompliance
		estadd scalar 		diff_zero	`r(estimate)'
		estadd scalar		ftest_zero	`r(p)'
		
		lincom pos_highcompliance - pos_lowcompliance
		estadd scalar 		diff_pos	`r(estimate)'
		estadd scalar		ftest_pos	`r(p)'
		
		lincom zero_highcompliance - pos_highcompliance
		estadd scalar 		diff_high	`r(estimate)'
		estadd scalar		ftest_high	`r(p)'
		
		lincom zero_lowcompliance - pos_lowcompliance
		estadd scalar		diff_low	`r(estimate)'
		estadd scalar		ftest_low	`r(p)'		

/********************************************************************************
	PART 4: Export tables
********************************************************************************/	

		local maindrop		drop(*.user_id)
		local appendixdrop	drop(*.CI_line)
		local mainfe		Rider
		local appendixfe	Line
		
		foreach est in main appendix {
		
			local 	   	 models `est'1 `est'2
	
			tableprep 	`models', ///
						panel(A) ///
						title(Overall) ///
						depvar(Chose reserved space) ///
						linebreak ///
						prefoot("\multicolumn{3}{c}{\textit{Mean dependent variable}} \\ Zero opportunity cost & \multicolumn{2}{c}{`mean_zero'} \\ & \multicolumn{2}{c}{`se_zero'} \\\\[-1ex]")
			
			esttab 		`models' using "${out_github}/`spec'_wtp_`est'.tex",  ///
				noobs nomtitles ///
				`r(table_options)' 
				
			local 	   	 models `est'3 `est'4
	
			tableprep 	`models', panel(B) title(Heterogeneous effects by male presence in reserved space)

			esttab 	`est'3 `est'4 ///
					using "${out_github}/`spec'_wtp_`est'.tex",  ///
				nomtitles nonumbers ///
				`r(table_options)' ///
				``est'drop' ///
				scalar	("riders Riders" "user ``est'fe' fixed effect" ///
						 "diff_high `r(footer_title)' \multicolumn{`r(ncols)'}{l}{By opportunity cost: zero opportunity cost - positive opportunity cost} \\ \quad $\Delta \hat\beta$ when few men in reserved space" "ftest_high \quad P-value" ///
						 "diff_low  \quad $\Delta \hat\beta$ when many men in reserved space" "ftest_low  \quad P-value" ///
						 "diff_zero \multicolumn{`r(ncols)'}{l}{By male presence in reserved space: few men - many men in reserved space} \\ \quad $\Delta \hat\beta$ when zero opportunity cost" "ftest_zero \quad P-value" ///
						 "diff_pos \quad $\Delta \hat\beta$ when positive opportunity cost" "ftest_pos \quad P-value")
		
			copy "${out_github}/`spec'_wtp_`est'.tex" "${out_tables}/`spec'_wtp_`est'.tex", replace
		}
	}
		
*------------------------ End of do-file --------------------------------------*
