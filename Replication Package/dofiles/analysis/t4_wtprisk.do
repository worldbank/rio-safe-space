/********************************************************************************
	PART 1: Define sample
********************************************************************************/
	
	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear
	
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
		local 	mean_low = el(r(table), 1,1)
		local 	se_low   = el(r(table), 2,1)
		local 	se_low	 = round(`se_low', .001)
		local 	se_low	 "(0`se_low')"
		
		reg d_women_car ///
			[pw = weightfe] ///
			if d_risk_high == 0 & d_highcompliance == 0 & d_highcongestion == 0 & phase == 1, ///
			cluster(user_id)
			
		local mean_full = el(r(table), 1,1)
		local se_full   = el(r(table), 2,1)
		local se_full	= round(`se_full', .001)
		local se_full	"(0`se_full')"
		
		* Model 1: no controls
		reg d_women_car d_risk_high ///
			[pw = weight] ///
			if phase == 1, ///
			cluster(user_id) 
		
		eststo `risk't1
		estadd local 	riders		`e(N_clust)'
		estadd local 	line 		"No"
		estadd scalar	mean_low	`mean_low'
		estadd local	se_low		`se_low'

		* Model 2: line FE
		areg d_women_car d_risk_high  ///
			 [pw = weight] ///
			if phase == 1, ///
			cluster(user_id) ///
			 absorb(CI_line)
		
		eststo `risk't2
		estadd local 	riders		`e(N_clust)'
		estadd local 	line 		"Yes"
		estadd scalar	mean_low	`mean_low'
		estadd local	se_low		`se_low'
		
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
		estadd scalar	mean_full	`mean_full'
		estadd local	se_full		`se_full'
			
	/*------------------------------------------------------------------------------
		PART 2.2: Bottom panel
	------------------------------------------------------------------------------*/
		
			* Define table label for each of them
			if "`risk'" == "comments"	local risktype "\begin{tabular}[t]{@{}c@{}} Verbal harassment \end{tabular}"
			if "`risk'" == "grope"		local risktype "\begin{tabular}[t]{@{}c@{}} Physical harassment \end{tabular}"
			if "`risk'" == "robbed"		local risktype "Robbery"
		
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
			estadd local 	riders		`e(N_clust)'
			estadd local 	line 		"No"
			estadd local 	risktype	"`risktype'"
			
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
			estadd local riders			`e(N_clust)'
			estadd local line 			"Yes" 
			estadd local risktype		"`risktype'"
			
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
			estadd local riders			`e(N_clust)'
			estadd local line 			"Yes" 
			estadd local risktype		"`risktype'"
			
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
		lab var zero_high "High risk perceiver \$\times\$ zero opportunity cost"
		lab var pos_high  "High risk perceiver \$\times\$ positive opportunity cost"
		lab var zero_low  "Low risk perceiver \$\times\$ zero opportunity cost"
		lab var pos_low   "Low risk perceiver \$\times\$ positive opportunity cost"
	
		
/*------------------------------------------------------------------------------
	PART 3.1: Top panel
------------------------------------------------------------------------------*/

		esttab 	gropet1 gropet2 gropet3 commentst1 commentst2 commentst3 robbedt1 robbedt2 robbedt3 ///
				using "${out_github}/delete_me.tex", ///
			label f tex se replace  ///
			nomtitles ///
			star	(* .1 ** .05 *** .01) ///
			b		(%9.3f) ///
			se		(%9.3f) ///
			sfmt	(%9.3f) ///
			prefoot	("\\[-1.8ex] \hline \\[-1.8ex]") ///
			scalars	("riders Riders" ///
					 "line Line fixed effects" ///
					 "mean_low \\[-1.8ex] \multicolumn{10}{c}{\textit{Uncontrolled means for omitted categories}} \\ Low risk perceiver" ///
					 "se_low  \, " ///
					 "mean_full Low risk perceiver, many men in reserved space, low crowding" ///
					 "se_full  \, ") ///
			prehead	("\begin{tabular}{l*{9}{c}} \hline\hline \\[-1.8ex] & \multicolumn{9}{c}{Dependent variable: Chose reserved space} \\") ///
			posthead("\hline \\[-1ex] \multicolumn{10}{c}{\textit{Panel A: By risk type, zero opportunity cost}} \\\\[-1ex]") ///

/*------------------------------------------------------------------------------
	PART 3.2: Bottom panel
------------------------------------------------------------------------------*/

		esttab 	grope1 grope2 grope3 comments1 comments2 comments3 robbed1 robbed2 robbed3 ///
				using "${out_github}/delete_me.tex", ///
			label f tex se append  ///
			nomtitles nonumbers ///
			star	(* .1 ** .05 *** .01) ///
			b		(%9.3f) ///
			se		(%9.3f) ///
			sfmt	(%9.3f) ///
			prehead	("") ///
			prefoot	("\\[-1.8ex] \hline \\[-1.8ex]") ///
			postfoot("\hline\hline \end{tabular}") ///
			keep	(zero_low pos_low zero_high pos_high d_highcongestion) ///
			scalars	("riders Riders" ///
					 "line Line fixed effects" ///
					 "risktype Type of perceived risk" ///
					 "diff_high \hline \\[-1ex] \multicolumn{10}{c}{\textit{Post-estimate tests for heterogeneous effects}} \\\\[-1ex] \multicolumn{10}{l}{By opportunity cost: zero opportunity cost - positive opportunity cost} \\ \quad $\Delta \hat\beta$ for high risk perceivers" "ftest_high \quad P-value" ///
					 "diff_low \quad $\Delta \hat\beta$ for low risk perceivers" "ftest_low  \quad P-value" ///
					 "diff_zero  \multicolumn{10}{l}{By risk perception: high risk - low risk perceivers} \\ \quad $\Delta \hat\beta$ when zero opportunity cost" "ftest_zero \quad P-value" ///
					 "diff_pos \quad $\Delta \hat\beta$ when positive opportunity cost" "ftest_pos \quad P-value") ///
			posthead("\hline \\[-1ex] \multicolumn{10}{c}{\textit{Panel B: By risk type and opportunity cost}} \\\\[-1ex] ")
		
		* Add line break to harassment type labels so table fits the page
		filefilter 	"${out_github}/delete_me.tex" "${out_github}/`spec'_wtprisk.tex", 	///		
					from(" harassment \BSend") ///
					to(" \BS\BS harassment \BSend") replace
		
		erase "${out_github}/delete_me.tex"
		copy  "${out_github}/`spec'_wtprisk.tex" "${out_tables}/`spec'_wtprisk.tex", replace		
		
		drop d_risk_high zero_high pos_high zero_low pos_low
	}
