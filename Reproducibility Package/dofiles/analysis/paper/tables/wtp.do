/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*			  Revealed preferences, overall and by ride condition			   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:	${out_tables}/paper_wtp_main.tex
				${out_tables}/paper_wtp_appendix.tex
				${out_tables}/online_wtp_main.tex
				${out_tables}/online_wtp_appendix.tex
				
	WRITEN BY:  Luiza Andrade [lcardoso@worldbank.org]

********************************************************************************
       PART 1: Define sample
********************************************************************************/

	use "${dt_final}/rider-audits-constructed.dta", clear

	* Only baseline and price experiment rider
	keep if inlist(phase, 1, 2)
	
	* Drop user with no mapping observations (missing compliance)
	drop if flag_nomapping == 1	
		
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
		
		**********************
		* Uncontrolled means *
		**********************
		
		* Overall
		reg d_women_car if d_pos_premium == 0 ///
			[pw = weightfe], ///
			cluster(user_id)
			
		local mean_zero = el(r(table), 1,1)
		local mean_zero	= round(`mean_zero', .001)
		local mean_zero "0`mean_zero'"
		local se_zero   = el(r(table), 2,1)
		local se_zero	= round(`se_zero', .001)
		local se_zero 	"(0`se_zero')"
		
		* Few men
		reg d_women_car if d_pos_premium == 0 & d_highcompliance == 1 ///
			[pw = weightfe], ///
			cluster(user_id)
			
		local mean_zero_high = el(r(table), 1,1)
		local mean_zero_high	= round(`mean_zero_high', .001)
		local mean_zero_high "0`mean_zero_high'"
		local se_zero_high   = el(r(table), 2,1)
		local se_zero_high	= round(`se_zero_high', .001)
		local se_zero_high 	"(0`se_zero_high')"
		
		* Many men
		reg d_women_car if d_pos_premium == 0 & d_highcompliance == 0 ///
			[pw = weightfe], ///
			cluster(user_id)
			
		local mean_zero_low = el(r(table), 1,1)
		local mean_zero_low	= round(`mean_zero_low', .001)
		local mean_zero_low "0`mean_zero_low'"
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
		
		************************
		* User FE + congestion *
		************************
		
		xtreg d_women_car d_pos_premium  ///
			d_highcongestion d_highcompliance ///
			[pw = weightfe], ///
			cluster(user_id) fe
		
		eststo main2
	
/*------------------------------------------------------------------------------
	PART 3.2: Bottom panel
------------------------------------------------------------------------------*/	
	
		***************
		* No controls *
		***************
		
		reg d_women_car i.oc_compliance ///
			[pw = weightfe], ///
			cluster(user_id) 
		
		local  		riders		`e(N_clust)'
		
		margins oc_compliance, post
		
		eststo appendix3
		estadd local  		riders		"`riders'"
		estadd local  		user		"No"
		estadd local  		line		"No"
		estadd local  		control		"No"
		
		lincom 2.oc_compliance - 4.oc_compliance
		estadd scalar 		diff_zero	`r(estimate)'
		estadd scalar		ftest_zero	`r(p)'
		
		lincom 1.oc_compliance - 3.oc_compliance
		estadd scalar 		diff_pos	`r(estimate)'
		estadd scalar		ftest_pos	`r(p)'
		
		lincom 2.oc_compliance - 1.oc_compliance
		estadd scalar 		diff_high	`r(estimate)'
		estadd scalar		ftest_high	`r(p)'
		
		lincom 4.oc_compliance - 3.oc_compliance
		estadd scalar		diff_low	`r(estimate)'
		estadd scalar		ftest_low	`r(p)'
		
		***********
		* Line FE *
		***********
		
		areg d_women_car i.oc_compliance ///
			 [pw = weightfe], ///
			 cluster(user_id) ///
			 a(CI_line)
		
		local  		riders		`e(N_clust)'
		
		margins oc_compliance, post
		
		eststo appendix4
		estadd local  		riders		"`riders'"
		estadd local  		user		"No"
		estadd local  		line		"Yes"
		estadd local  		control		"No"
		
		
		lincom 2.oc_compliance - 4.oc_compliance
		estadd scalar 		diff_zero	`r(estimate)'
		estadd scalar		ftest_zero	`r(p)'
		
		lincom 1.oc_compliance - 3.oc_compliance
		estadd scalar 		diff_pos	`r(estimate)'
		estadd scalar		ftest_pos	`r(p)'
		
		lincom 2.oc_compliance - 1.oc_compliance
		estadd scalar 		diff_high	`r(estimate)'
		estadd scalar		ftest_high	`r(p)'
		
		lincom 4.oc_compliance - 3.oc_compliance
		estadd scalar		diff_low	`r(estimate)'
		estadd scalar		ftest_low	`r(p)'
		
		***********
		* User FE *
		***********	
		
		areg d_women_car  i.oc_compliance ///
			 [pw = weightfe], ///
			 cluster(user_id) ///
			 a(user_id)
		
		local  		riders		`e(N_clust)'
		
		margins oc_compliance, post
		
		eststo main3
		estadd local  		riders		"`riders'"
		estadd local  		user		"Yes"
		estadd local  		control		"No"
		
		
		lincom 2.oc_compliance - 4.oc_compliance
		estadd scalar 		diff_zero	`r(estimate)'
		estadd scalar		ftest_zero	`r(p)'
		
		lincom 1.oc_compliance - 3.oc_compliance
		estadd scalar 		diff_pos	`r(estimate)'
		estadd scalar		ftest_pos	`r(p)'
		
		lincom 2.oc_compliance - 1.oc_compliance
		estadd scalar 		diff_high	`r(estimate)'
		estadd scalar		ftest_high	`r(p)'
		
		lincom 4.oc_compliance - 3.oc_compliance
		estadd scalar		diff_low	`r(estimate)'
		estadd scalar		ftest_low	`r(p)'
		
		************************
		* User FE + congestion *
		************************
		
		areg d_women_car i.oc_compliance ///
			d_highcongestion ///
			[pw = weightfe], ///
			cluster(user_id) ///
			a(user_id)
		
		local  		riders		`e(N_clust)'
		
		margins oc_compliance, post
		
		eststo main4
		estadd local  		riders		"`riders'"
		estadd local  		user		"Yes"
		estadd local  		control		"Yes"
			
		lincom 2.oc_compliance - 4.oc_compliance
		estadd scalar 		diff_zero	`r(estimate)'
		estadd scalar		ftest_zero	`r(p)'
		
		lincom 1.oc_compliance - 3.oc_compliance
		estadd scalar 		diff_pos	`r(estimate)'
		estadd scalar		ftest_pos	`r(p)'
		
		lincom 2.oc_compliance - 1.oc_compliance
		estadd scalar 		diff_high	`r(estimate)'
		estadd scalar		ftest_high	`r(p)'
		
		lincom 4.oc_compliance - 3.oc_compliance
		estadd scalar		diff_low	`r(estimate)'
		estadd scalar		ftest_low	`r(p)'
		

/********************************************************************************
	PART 4: Export tables
********************************************************************************/	

		local appendixfe	`""line Line fixed effect""'
		
		foreach est in main appendix {
		
/*------------------------------------------------------------------------------
	Panel A
------------------------------------------------------------------------------*/	

			local 	   	 models `est'1 `est'2
			tableprep 	`models' ///
						, ///
						panel(A) ///
						title(Overall) ///
						depvar(Chose reserved space) ///
						linebreak ///
						prefoot("\multicolumn{3}{c}{\textit{Mean dependent variable}} \\ Zero opportunity cost & \multicolumn{2}{c}{`mean_zero'} \\ & \multicolumn{2}{c}{`se_zero'} \\\\[-1ex]")
			
			esttab 		`models' using "${out_tables}/delete_me.tex" ///
						,  ///
						noobs nomtitles ///
						`r(table_options)' ${star} 
				
/*------------------------------------------------------------------------------
	Panel B
------------------------------------------------------------------------------*/	

			local 	   	 models `est'3 `est'4
			tableprep 	`models' ///
						, ///
						panel(B) ///
						title(Heterogeneous effects by male presence in reserved space) ///
						prefoot("\multicolumn{3}{c}{\textit{Mean dependent variable}} \\ Zero opportunity cost $\times$ Few men in reserved space & \multicolumn{2}{c}{`mean_zero_high'} \\ & \multicolumn{2}{c}{`se_zero_high'} \\ Zero opportunity cost $\times$ Many men in reserved space & \multicolumn{2}{c}{`mean_zero_low'} \\ & \multicolumn{2}{c}{`se_zero_low'} \\\\[-1ex]")

			esttab 		`models' ///
						using "${out_tables}/delete_me.tex" ///
						,  ///
						nomtitles nonumbers ///
						`r(table_options)' ${star}  ///
						scalar	("riders Riders" "control Control for high crowding" "user Rider fixed effect" ``est'fe'  ///
								 "diff_high `r(footer_title)' \multicolumn{`r(ncols)'}{l}{By opportunity cost: zero opportunity cost - positive opportunity cost} \\ \quad Few men in reserved space: $\hat\beta_{M_2} - \hat\beta_{M_1}$" "ftest_high \quad P-value" ///
								 "diff_low  \quad Many men in reserved space: $\hat\beta_{M_4} - \hat\beta_{M_3}$ " "ftest_low  \quad P-value" ///
								 "diff_zero \multicolumn{`r(ncols)'}{l}{By male presence in reserved space: few men - many men in reserved space} \\ \quad Zero opportunity cost: $\hat\beta_{M_2} - \hat\beta_{M_4}$" "ftest_zero \quad P-value" ///
								 "diff_pos \quad Positive oppotunity cost: $\hat\beta_{M_1} - \hat\beta_{M_3}$ " "ftest_pos \quad P-value")
		
			* Fix the automatic escape of subscripts
			filefilter 	"${out_tables}/delete_me.tex" "${out_tables}/`spec'_wtp_`est'.tex", ///
						from("\BSbeta\BS_{M\BS_") to("\BSbeta_{M_") replace

			erase 		"${out_tables}/delete_me.tex"
		}
	}
		
*============================================================= That's all, folks!
