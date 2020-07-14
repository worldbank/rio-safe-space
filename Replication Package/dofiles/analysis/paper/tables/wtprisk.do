/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 				Revealed preferences by rider risk perception				   *
********************************************************************************

	OUTLINE:	PART 1:   Define sample
				PART 2:   Run regressions
				PART 2.1: Top panel
				PART 2.2: Bottom panel
				PART 3:   Export tables
				PART 3.1: Top panel
				PART 3.2: Bottom panel
				
	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:	${out_tables}/paper_wtprisk.tex
				${out_tables}/online_wtprisk.tex
				
	WRITEN BY:  Luiza Andrade [lcardoso@worldbank.org]

********************************************************************************
	PART 1: Define sample
********************************************************************************/
	
	use "${dt_final}/pooled_rider_audit_constructed.dta", clear
	
	* Only baseline and price experiment rider
	keep if inlist(phase, 1, 2)
	
	foreach spec in online paper {
	
	if "`spec'" == "online" {
		
		keep if d_exit == 1 

	}
	
/********************************************************************************
	PART 2: Run regressions
********************************************************************************/	

	* Loop over the three different types of risk
	foreach risk in comments grope robbed {
	
		gen d_risk_high = d_`risk'_high
		lab var d_risk_high "High risk perceiver"
		
/*------------------------------------------------------------------------------
	PART 2.1: Top panel
------------------------------------------------------------------------------*/
	
		reg 	d_women_car [pw = weight] if d_risk_high == 0 & phase == 1
		local 	mean_`risk'_low  = el(r(table), 1,1)
		local	mean_`risk'_low  = round(`mean_`risk'_low', .001)
		local	mean_`risk'_low  = "0`mean_`risk'_low'"
		local 	se_`risk'_low    = el(r(table), 2,1)
		local 	se_`risk'_low	 = round(`se_`risk'_low', .001)
		local 	se_`risk'_low	 "(0`se_`risk'_low')"
				
		* Model 1: no controls
		reg d_women_car d_risk_high ///
			[pw = weight] ///
			if phase == 1, ///
			cluster(user_id) 
		
		eststo `risk't1
		estadd local 	riders		`e(N_clust)'
		estadd local 	line 		"No"
		
		* Model 2: line FE
		areg d_women_car d_risk_high  ///
			 [pw = weight] ///
			if phase == 1, ///
			cluster(user_id) ///
			 absorb(CI_line)
		
		eststo `risk't2
		estadd local 	riders		`e(N_clust)'
		estadd local 	line 		"Yes"
		
		* Model 3: line FE + congestion
		areg d_women_car d_risk_high ///
			 d_highcongestion d_highcompliance ///
			 [pw = weight] ///
			if phase == 1, ///
			cluster(user_id) ///
			 absorb(CI_line)
		
		eststo `risk't3
		estadd local 	riders		`e(N_clust)'
		estadd local 	line 		"Yes"
		
/*------------------------------------------------------------------------------
	PART 2.2: Bottom panel
------------------------------------------------------------------------------*/
		
			* Define table label for each of them
			if "`risk'" == "comments" {
				local risktypet "Verbal"
				local risktypeb "harassment"
			}
			if "`risk'" == "grope" {
				local risktypet "Physical"
				local risktypeb "harassment"
			}
			if "`risk'" == "robbed"	{
				local risktypet "\multirow{2}{*}{Robbery}"
				local risktypeb ""
			}
		
			* Interact with opportunity cost to create hetergeneity variables
			gen zero_high 		= (d_pos_premium == 0 & d_`risk'_high == 1) if !missing(d_pos_premium) & !missing(d_`risk'_high)
			gen pos_high 		= (d_pos_premium == 1 & d_`risk'_high == 1) if !missing(d_pos_premium) & !missing(d_`risk'_high)
			gen zero_low 		= (d_pos_premium == 0 & d_`risk'_high == 0) if !missing(d_pos_premium) & !missing(d_`risk'_high)
			gen pos_low 		= (d_pos_premium == 1 & d_`risk'_high == 0) if !missing(d_pos_premium) & !missing(d_`risk'_high)
			
			* Model 1: no controls
			reg d_women_car  zero_low pos_low zero_high pos_high ///
				[pw = weight], ///
				cluster(user_id) ///
				nocons

			eststo `risk'1
			estadd local riders		`e(N_clust)'
			estadd local line 		"No"
			estadd local risktypet	"`risktypet'"
			estadd local risktypeb	"`risktypeb'"
			
			lincom zero_high - zero_low
			estadd scalar 		diff_zero	`r(estimate)'
			estadd scalar		ftest_zero	`r(p)'
			
			lincom pos_high - pos_low
			estadd scalar 		diff_pos	`r(estimate)'
			estadd scalar		ftest_pos	`r(p)'
			
			lincom zero_high - pos_high
			estadd scalar 		diff_high	`r(estimate)'
			estadd scalar		ftest_high	`r(p)'
			
			lincom zero_low - pos_low
			estadd scalar		diff_low	`r(estimate)'
			estadd scalar		ftest_low	`r(p)'
			
			* Model 2: line FE
			reg d_women_car  zero_low pos_low zero_high pos_high ///
				i.CI_line ///
				[pw = weight], ///
				cluster(user_id) ///
				nocons
			
			eststo `risk'2
			estadd local riders		`e(N_clust)'
			estadd local line 		"Yes" 
			estadd local risktypet	"`risktypet'"
			estadd local risktypeb	"`risktypeb'"
			
			lincom zero_high - zero_low
			estadd scalar 		diff_zero	`r(estimate)'
			estadd scalar		ftest_zero	`r(p)'
			
			lincom pos_high - pos_low
			estadd scalar 		diff_pos	`r(estimate)'
			estadd scalar		ftest_pos	`r(p)'
			
			lincom zero_high - pos_high
			estadd scalar 		diff_high	`r(estimate)'
			estadd scalar		ftest_high	`r(p)'
			
			lincom zero_low - pos_low
			estadd scalar		diff_low	`r(estimate)'
			estadd scalar		ftest_low	`r(p)'
			
			* Model 3: line FE + congestion
			reg d_women_car  zero_low pos_low zero_high pos_high ///
				d_highcongestion i.CI_line ///
				[pw = weight], ///
				cluster(user_id) ///
				nocons
			
			eststo `risk'3
			estadd local riders		`e(N_clust)'
			estadd local line 		"Yes" 
			estadd local risktypet	"`risktypet'"
			estadd local risktypeb	"`risktypeb'"
			
			lincom zero_high - zero_low
			estadd scalar 		diff_zero	`r(estimate)'
			estadd scalar		ftest_zero	`r(p)'
			
			lincom pos_high - pos_low
			estadd scalar 		diff_pos	`r(estimate)'
			estadd scalar		ftest_pos	`r(p)'
			
			lincom zero_high - pos_high
			estadd scalar 		diff_high	`r(estimate)'
			estadd scalar		ftest_high	`r(p)'
			
			lincom zero_low - pos_low
			estadd scalar		diff_low	`r(estimate)'
			estadd scalar		ftest_low	`r(p)'

			* Drop heterogeneity vars so we can create them again for the next risk type
			if "`risk'" != "robbed" drop zero_low pos_low zero_high pos_high d_risk_high
				
		}
	
/********************************************************************************
	PART 3: Export tables
********************************************************************************/	

		* Label variables for this table only
		lab var pos_low   "$\hat\beta_{M_1}$: Positive opportunity cost \$\times\$ Low risk perceiver"
		lab var zero_low  "$\hat\beta_{M_2}$: Zero opportunity cost \$\times\$ Low risk perceiver"
		lab var pos_high  "$\hat\beta_{M_3}$: Positive opportunity cost \$\times\$ High risk perceiver"
		lab var zero_high "$\hat\beta_{M_4}$: Zero opportunity cost \$\times\$ High risk perceiver"
		
		
/*------------------------------------------------------------------------------
	PART 3.1: Top panel
------------------------------------------------------------------------------*/
	
		local 	   	 models gropet1 gropet2 gropet3 commentst1 commentst2 commentst3 robbedt1 robbedt2 robbedt3
		tableprep 	`models' ///
					, ///
					panel(A) ///
					title(By risk type, zero opportunity cost) ///
					depvar(Chose reserved space) ///
					prefoot("\multicolumn{10}{c}{\textit{Mean dependent variable}} \\ Low risk perceiver & \multicolumn{3}{c}{`mean_grope_low'}  & \multicolumn{3}{c}{`mean_comments_low'} & \multicolumn{3}{c}{`mean_robbed_low'} \\ & \multicolumn{3}{c}{`se_grope_low'}  & \multicolumn{3}{c}{`se_comments_low'} & \multicolumn{3}{c}{`se_robbed_low'} \\\\[-1ex]")
		
		esttab 		`models' using "${out_tables}/delete_me.tex" ///
					,  ///
					noobs nomtitles ///
					`r(table_options)' ${star} ///
					scalars	("riders Riders" ///
							 "line Line fixed effects")
						
/*------------------------------------------------------------------------------
	PART 3.2: Bottom panel
------------------------------------------------------------------------------*/

		local 	   	 models grope1 grope2 grope3 comments1 comments2 comments3 robbed1 robbed2 robbed3
		tableprep 	`models' ///
					, ///
					panel(B) ///
					title(By risk type and opportunity cost) ///
						
		esttab 		`models' using "${out_tables}/delete_me.tex" ///
					,  ///
					keep(zero_low pos_low zero_high pos_high d_highcongestion) ///
					order(pos_low zero_low pos_high zero_high) ///
					nomtitles nonumbers ///
					`r(table_options)' ${star} ///
					scalars	("riders Riders" ///
							 "line Line fixed effects" ///
							 "risktypet \multirow{2}{*}{Type of perceived risk}" ///
							 "risktypeb \," ///
							 "diff_high \hline \\[-1ex] \multicolumn{10}{c}{\textit{Post-estimate tests for heterogeneous effects}} \\\\[-1ex] \multicolumn{10}{l}{By opportunity cost: zero opportunity cost - positive opportunity cost} \\ \quad High risk perceivers: $\hat\beta_{M_4} - \hat\beta_{M_3}$" "ftest_high \quad P-value" ///
							 "diff_low \quad Low risk perceivers: $\hat\beta_{M_2} - \hat\beta_{M_1}$" "ftest_low  \quad P-value" ///
							 "diff_zero  \multicolumn{10}{l}{By risk perception: high risk - low risk perceivers} \\ \quad Zero opportunity cost: $\hat\beta_{M_4} - \hat\beta_{M_2}$" "ftest_zero \quad P-value" ///
							 "diff_pos \quad Positive opportunity cost: $\hat\beta_{M_3} - \hat\beta_{M_1}$" "ftest_pos \quad P-value")
		
		filefilter 	"${out_tables}/delete_me.tex" "${out_tables}/${star}`spec'_wtprisk.tex", ///
						from("\BSbeta\BS_{M\BS_") to("\BSbeta_{M_") replace
		
		erase 		"${out_tables}/delete_me.tex"
		
		drop d_risk_high zero_high pos_high zero_low pos_low
	}

*------------------------ End of do-file --------------------------------------*
