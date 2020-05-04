/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 		 Impact of randomized assignment of car on reported harassment	 	   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:	${out_tables}/paper_carimpactharassment_main.tex
				${out_tables}/paper_carimpactharassment_appendix.tex
				${out_tables}/online_carimpactharassment_main.tex
				${out_tables}/online_carimpactharassment_appendix.tex
				
	WRITEN BY:  Luiza Andrade [lcardoso@worldbank.org]

********************************************************************************
       PART 1: Define sample
********************************************************************************/

	use "${dt_final}/pooled_rider_audit_constructed.dta", clear

	* Only randomized car assignment rides
	keep if phase == 3 & missing(flag_nomapping)
	
	* Change label for this table only
	lab var d_women_car "Assigned to reserved space"


	foreach spec in paper online {

	local mean 		""
	local mean_low 	""
	local mean_high ""

	if "`spec'" == "online" {
		keep if d_exit == 1

	}

/********************************************************************************
       PART 2: Top panel regressions
********************************************************************************/

		est clear

		local estimates_main 		""
		local estimates_appendix 	""

		foreach harVar in d_harassment d_physical_har d_verbal_har d_staring {

			* Calculate unconditional means
			reg   `harVar' 					[pw = weightfe] ///
				  if d_women_car == 0

			local `harVar'_mean 	= el(r(table), 1,1)
			local `harVar'_mean		= round(``harVar'_mean', .001)
			local `harVar'_mean		= "0``harVar'_mean'"
			local `harVar'_se 		= el(r(table), 2,1)
			local `harVar'_se		= round(``harVar'_se', .001)
			local `harVar'_se		= "(0``harVar'_se')"

			* Run regressions
			reg 	`harVar' d_women_car	[pw = weightfe], cluster(user_id)
			eststo 	`harVar'unconditional

			areg 	`harVar' d_women_car	[pw = weightfe], cluster(user_id) absorb(CI_line)
			eststo 	`harVar'linefe

			xtreg  	`harVar' d_women_car	[pw = weightfe], cluster(user_id) fe
			eststo 	`harVar'userfe

			xtreg 	`harVar' d_women_car	///
					 d_highcongestion d_highcompliance	///
											[pw = weightfe], cluster(user_id) fe
			eststo 	`harVar'congestion

			* Save regression in locals to export
			local estimates_main 		"`estimates_main' `harVar'userfe `harVar'congestion"
			local estimates_appendix 	"`estimates_appendix' `harVar'unconditional `harVar'linefe"

		}

		* Main results: user FE, user FE + crowding

		foreach est in main appendix {

			tableprep 	`estimates_`est'' ///
						, ///
						panel(A) ///
						title(Overall impact of randomized assignment) ///
						prefoot("\multicolumn{9}{c}{\textit{Mean dependent variable}} \\ Assigned to public space & \multicolumn{2}{c}{`d_harassment_mean'} & \multicolumn{2}{c}{`d_physical_har_mean'} & \multicolumn{2}{c}{`d_verbal_har_mean'} & \multicolumn{2}{c}{`d_staring_mean'} \\ \, & \multicolumn{2}{c}{`d_harassment_se'} & \multicolumn{2}{c}{`d_physical_har_se'} & \multicolumn{2}{c}{`d_verbal_har_se'} & \multicolumn{2}{c}{`d_staring_se'} \\")

			esttab 	`estimates_`est'' using "${out_tables}/`spec'_carimpactharassment_`est'0.tex" ///
					,  ///
					`r(table_options)' ///
					noobs nomtitles ///
					mgroups ("Any harassment" "Physical harassment" "Verbal harassment" "Staring", ///
							 pattern(1 0 1 0 1 0 1 0) ///
							 prefix(\multicolumn{@span}{c}{) suffix(}) ///
							 span erepeat(\cmidrule(lr){@span}))

		}

/********************************************************************************
	PART 3: Bottom panel regressions
********************************************************************************/

		est clear

		local estimates_main 		""
		local estimates_appendix 	""

		foreach harVar in d_harassment d_physical_har d_verbal_har d_staring {

			***************
			* No controls *
			***************

			reg `harVar' 	${interactionvars} 				[pw = weightfe], nocons cluster(user_id)

			estimates store `harVar'unconditional
			estadd local  	riders		`e(N_clust)'
			estadd scalar	obs			`e(N)'
			estadd local	line		"No"
			estadd local	user		"No"


			lincom pink_highcompliance - pink_lowcompliance
			estadd scalar 		diff_pink	`r(estimate)'
			estadd scalar		ftest_pink	`r(p)'

			lincom mixed_highcompliance - mixed_lowcompliance
			estadd scalar 		diff_mixed	`r(estimate)'
			estadd scalar		ftest_mixed	`r(p)'

			lincom pink_highcompliance - mixed_highcompliance
			estadd scalar 		diff_high	`r(estimate)'
			estadd scalar		ftest_high	`r(p)'

			lincom pink_lowcompliance - mixed_lowcompliance
			estadd scalar		diff_low	`r(estimate)'
			estadd scalar		ftest_low	`r(p)'

			***********
			* Line FE *
			***********

			reg `harVar' 	${interactionvars}	i.CI_line 	[pw = weightfe], nocons cluster(user_id)

			estimates store `harVar'linefe
			estadd local  	riders	`e(N_clust)'
			estadd scalar	obs		`e(N)'
			estadd local	line	"Yes"
			estadd local	user	"No"

			lincom pink_highcompliance - pink_lowcompliance
			estadd scalar 		diff_pink	`r(estimate)'
			estadd scalar		ftest_pink	`r(p)'

			lincom mixed_highcompliance - mixed_lowcompliance
			estadd scalar 		diff_mixed	`r(estimate)'
			estadd scalar		ftest_mixed	`r(p)'

			lincom pink_highcompliance - mixed_highcompliance
			estadd scalar 		diff_high	`r(estimate)'
			estadd scalar		ftest_high	`r(p)'

			lincom pink_lowcompliance - mixed_lowcompliance
			estadd scalar		diff_low	`r(estimate)'
			estadd scalar		ftest_low	`r(p)'

			***********
			* User FE *
			***********

			reg `harVar' 	${interactionvars}	i.user_id 	[pw = weightfe], nocons cluster(user_id)

			estimates store `harVar'userfe
			estadd local  	riders	`e(N_clust)'
			estadd scalar	obs		`e(N)'
			estadd local	line	"No"
			estadd local	user	"Yes"

			lincom pink_highcompliance - pink_lowcompliance
			estadd scalar 		diff_pink	`r(estimate)'
			estadd scalar		ftest_pink	`r(p)'

			lincom mixed_highcompliance - mixed_lowcompliance
			estadd scalar 		diff_mixed	`r(estimate)'
			estadd scalar		ftest_mixed	`r(p)'

			lincom pink_highcompliance - mixed_highcompliance
			estadd scalar 		diff_high	`r(estimate)'
			estadd scalar		ftest_high	`r(p)'

			lincom pink_lowcompliance - mixed_lowcompliance
			estadd scalar		diff_low	`r(estimate)'
			estadd scalar		ftest_low	`r(p)'

			************************
			* User FE + congestion *
			************************

			reg `harVar' 	${interactionvars}	i.user_id d_highcongestion [pw = weightfe], nocons cluster(user_id)

			estimates store `harVar'congestion
			estadd local  	riders	`e(N_clust)'
			estadd scalar	obs		`e(N)'
			estadd local	line	"No"
			estadd local	user	"Yes"

			lincom pink_highcompliance - pink_lowcompliance
			estadd scalar 		diff_pink	`r(estimate)'
			estadd scalar		ftest_pink	`r(p)'

			lincom mixed_highcompliance - mixed_lowcompliance
			estadd scalar 		diff_mixed	`r(estimate)'
			estadd scalar		ftest_mixed	`r(p)'

			lincom pink_highcompliance - mixed_highcompliance
			estadd scalar 		diff_high	`r(estimate)'
			estadd scalar		ftest_high	`r(p)'

			lincom pink_lowcompliance - mixed_lowcompliance
			estadd scalar		diff_low	`r(estimate)'
			estadd scalar		ftest_low	`r(p)'

			* Store main and appendix tables separately
			local estimates_main 		"`estimates_main' 		`harVar'userfe `harVar'congestion"
			local estimates_appendix 	"`estimates_appendix' 	`harVar'unconditional `harVar'linefe "

			* Calculate unconditional means
			reg   `harVar' ///
				  [pw = weightfe] ///
				  if d_women_car == 0 & d_highcompliance == 1, ///
				  cluster(user_id)

			local `harVar'_mean_few 	= el(r(table), 1,1)
			local `harVar'_mean_few		= round(``harVar'_mean_few', .001)
			local `harVar'_mean_few		= "0``harVar'_mean_few'"
			local `harVar'_se_few 		= el(r(table), 2,1)
			local `harVar'_se_few		= round(``harVar'_se_few', .001)
			local `harVar'_se_few		= "(0``harVar'_se_few')"

			reg   `harVar' ///
				  [pw = weightfe] ///
				  if d_women_car == 0 & d_highcompliance == 0, ///
				  cluster(user_id)

			local `harVar'_mean_many 	= el(r(table), 1,1)
			local `harVar'_mean_many	= round(``harVar'_mean_many', .001)
			local `harVar'_mean_many	= "0``harVar'_mean_many'"
			local `harVar'_se_many 		= el(r(table), 2,1)
			local `harVar'_se_many		= round(``harVar'_se_many', .001)
			local `harVar'_se_many		= "(0``harVar'_se_many')"
		}

/********************************************************************************
	PART 4: Export tables
********************************************************************************/

		local keepmain			d_highcongestion
		local scalarappendix	`" "line Line fixed effect" "'
		local scalarmain		`" "user Rider fixed effect" "'

		foreach est in main appendix {

			tableprep 	`estimates_`est'' ///
						, ///
						panel(B) ///
						title(Impact of randomized assignment by presence of men in reserved space) ///
						prefoot("\multicolumn{9}{c}{\textit{Mean dependent variable}} \\ Assigned to public space $\times$ Few men in reserved space& \multicolumn{2}{c}{`d_harassment_mean_few'} & \multicolumn{2}{c}{`d_physical_har_mean_few'} & \multicolumn{2}{c}{`d_verbal_har_mean_few'} & \multicolumn{2}{c}{`d_staring_mean_few'} \\  & \multicolumn{2}{c}{`d_harassment_se_few'} & \multicolumn{2}{c}{`d_physical_har_se_few'} & \multicolumn{2}{c}{`d_verbal_har_se_few'} & \multicolumn{2}{c}{`d_staring_se_few'} \\ Assigned to public space $\times$ Many men in reserved space & \multicolumn{2}{c}{`d_harassment_mean_many'} & \multicolumn{2}{c}{`d_physical_har_mean_many'} & \multicolumn{2}{c}{`d_verbal_har_mean_many'} & \multicolumn{2}{c}{`d_staring_mean_many'} \\  & \multicolumn{2}{c}{`d_harassment_se_many'} & \multicolumn{2}{c}{`d_physical_har_se_many'} & \multicolumn{2}{c}{`d_verbal_har_se_many'} & \multicolumn{2}{c}{`d_staring_se_many'} \\\\[-1ex]")
			
			esttab `estimates_`est'' using "${out_tables}/`spec'_carimpactharassment_`est'0.tex" ///
					,  ///
					keep(${interactionvars} `keep`est'') ///
					nomtitles nonumbers ///
					`r(table_options)' ///
					scalar("riders Riders" `scalar`est'' ///
						   "diff_high  `r(footer_title)' \multicolumn{`r(ncols)'}{l}{Impact on harassment when few men in reserved space: reserved space - public space} \\ \quad $\hat\beta_{M_1}$ - $\hat\beta_{M_2}$" "ftest_high \quad P-value" ///
						   "diff_low   \multicolumn{`r(ncols)'}{l}{Impact on harassment when many men in reserved space: reserved space - public space} \\\quad $\hat\beta_{M_3}$ - $\hat\beta_{M_4}$" "ftest_low  \quad P-value")

			* Fix the automatic escape of subscripts
			filefilter 	"${out_tables}/`spec'_carimpactharassment_`est'0.tex" "${out_tables}/`spec'_carimpactharassment_`est'.tex", ///
							from("\BSbeta\BS_{M\BS_") to("\BSbeta_{M_") replace
			
			erase 		"${out_tables}/`spec'_carimpactharassment_`est'0.tex"
					
		}
	}

*--------------------------------- The end ------------------------------------*
