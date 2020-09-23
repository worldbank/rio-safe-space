/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************

	OUTLINE:	PART 1: Prepare data
				PART 2: Run regressions
				PART 3: Export table

	REQUIRES:	${dt_final}/platform_survey_constructed.dta
	CREATES:	${out_tables}/mainiat.tex
				${out_graphs}/presentation_iat_coef.png

	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]
		
*******************************************************************************
	PART 1: Prepare data
*******************************************************************************/
	
	* Load platform survey data
	use "${dt_final}/platform_survey_constructed.dta", clear

	* Drop observations that don't have both safety and advances IAT -- otherwise, 
	* we're not comparing the D-scores
	keep if !missing(scoresecurity) & !missing(scorereputation)

	* Reshape to long: each line is one participant and IAT type
	reshape long score, i(id) j(version) string

	* Subset sample: drop career iat
	drop if version == "career" | missing(score) | version == "_diff"
	merge m:1 id using "${dt_final}/platform_survey_constructed.dta", keepusing(scorecareer) nogen keep(3)
	
	* Create interactions variables
	gen reputationversion 			= (version == "reputation")
	gen reputationversion_male 		= reputationversion * d_man

	* Change table labels
	lab var score 						"IAT D-Score"
	lab var reputationversion			"Advances instrument"
	lab var reputationversion_male 		"Advances instrument \\$\times\\$ Male respondent"
	
/*******************************************************************************
	PART 2: Run regressions
*******************************************************************************/

/*------------------------------------------------------------------------------
	No controls
-------------------------------------------------------------------------------*/

	* Simple
	reg score reputationversion ///
		[pw = weight_platform], ///
		cluster(id) 
	est sto main1
	
	estadd local lines 	"No"
	estadd local riders	"`e(N_clust)'"
	
	* Control for gender-career IAT
	reg score reputationversion scorecareer ///
		[pw = weight_platform], ///
		cluster(id) 
	est sto main2
	
	estadd local lines 	"No"
	estadd local riders	"`e(N_clust)'"
	
/*------------------------------------------------------------------------------
	By gender
-------------------------------------------------------------------------------*/

	* By gender
	reg score reputationversion_male d_man 	reputationversion 	///
		[pw = weight_platform], ///
		cluster(id) 
	est sto main3
	
	lincom reputationversion_male + reputationversion
	estadd scalar 	betahat `r(estimate)'
	estadd scalar	ftest	`r(p)'

	estadd local 	lines 	"No"
	estadd local 	riders	"`e(N_clust)'"
	
	* By gender, controlling for gender-career IAT
	reg score reputationversion_male d_man 	reputationversion scorecareer ///
		[pw = weight_platform], ///
		cluster(id) 
	est sto main4
	
	lincom reputationversion_male + reputationversion
	estadd scalar 	betahat `r(estimate)'
	estadd scalar	ftest	`r(p)'
	
	estadd local 	lines 	"No"
	estadd local 	riders	"`e(N_clust)'"

/*------------------------------------------------------------------------------
	With demographic controls
-------------------------------------------------------------------------------*/

	* By gender
	reg score reputationversion_male d_man reputationversion 	///
		d_employed d_young d_lowed	i.platform ///
		[pw = weight_platform], ///
		cluster(id) 
	est sto main5
	
	lincom reputationversion_male + reputationversion
	estadd scalar 	betahat `r(estimate)'
	estadd scalar	ftest	`r(p)'
	
	estadd local 	lines 	"Yes"
	estadd local 	riders	"`e(N_clust)'"
	
	* By gender, controlling for gender-career IAT
	reg score reputationversion_male d_man reputationversion scorecareer ///
		d_employed d_young d_lowed	i.platform ///
		[pw = weight_platform], ///
		cluster(id) 
	est sto main6
	
	lincom reputationversion_male + reputationversion
	estadd scalar 	betahat `r(estimate)'
	estadd scalar	ftest	`r(p)'
	
	estadd local 	lines 	"Yes"
	estadd local 	riders	"`e(N_clust)'"

/*******************************************************************************
       PART 3: Export table
********************************************************************************/

	local	   models main1 main3 main5 main2 main4 main6
	tableprep `models', panel(A) depvar(Dependent variable: IAT D-Score)
	
	esttab  `models' using "${out_tables}/mainiat.tex", ///
			drop(*.platform) ///
			`r(table_options)' ///
			${star} ///
			nomtitles  nonotes ///
			order(reputationversion reputationversion_male d_man d_employed d_young d_lowed scorecareer) ///
			scalars("riders  Respondents" ///
					"lines   Platform Fixed Effect" ///
					"betahat \hline \\[-1ex] \multicolumn{`r(ncols)'}{c}{\textit{Post-estimate test for difference between instruments among men}} \\ $\hat\beta_{\text{Advances} \times \text{Male respondent}} + \hat\beta_{\text{Advances}}$" ///
					"ftest   P-value") ///
			postfoot("\hline\hline \end{tabular}")
			
/*******************************************************************************
       PART 4: Export coefplots
********************************************************************************/
	
	gr drop _all
	lab var	reputationversion 		"Female respondents"
	lab var	reputationversion_male	"Male respondents"
			
	
	coefplot main2, keep(reputationversion) vertical ///
					yline(0, lpattern(dash)) ///
					levels(90 95) ///
					ylab(, noticks glcolor(${col_box}) labsize(${grlabsize})) ///
					graphregion(color(white)) ///
					xlab(, noticks) ///
					ciopt(color(gs10 gs10) recast(rcap)) ///
					ytitle("Difference in D-Scores", size(${grlabsize})) ///
					title(Overall, box bexpand bcolor(gs15) size(${grlabsize})) ///
					color(navy) ///
					name(all)
					
	coefplot main3, keep(reputationversion reputationversion_male) ///
					vertical ///
					yline(0, lpattern(dash)) levels(90 95) ///
					ylab(, noticks labcolor(white) glcolor(${col_box}) labsize(${grlabsize})) ///
					xlab(, noticks) ///
					yscale(noline) ///
					graphregion(color(white)) ///
					ciopt(color(gs10 gs10) recast(rcap)) ///
					ytitle("", size(${grlabsize})) ///
					title(By gender, box bexpand bcolor(gs15) size(${grlabsize})) ///
					color(${col_1}) ///
					name(high) 
					
	gr combine all high, graphregion(color(white)) cols(2) ycommon title("Difference in D-scores") subtitle("(Provocation - Safety)")
		
	* Export graph
	gr export "${out_graphs}/presentation_iat_coef.png", width(5000) replace
	
*============================================================= That's all, folks!
