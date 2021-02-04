
	* Load platform survey data
	use "${dt_platform_fin}/platform_survey_constructed.dta", clear

	* Drop observations that don't have both safety and advances IAT -- otherwise, 
	* we're not comparing the D-scores
	keep if !missing(scoresecurity) & !missing(scorereputation)

	* Reshape to long: each line is one participant and IAT type
	reshape long score time errorrate, i(id) j(version) string

	* Subset sample: drop career iat
	drop if version == "career" | missing(score) | version == "_diff"
	merge m:1 id using "${dt_platform_fin}/platform_survey_constructed.dta", keepusing(scorecareer) nogen keep(3)
	
	* Create interactions variables
	gen reputationversion 			= (version == "reputation")
	
	lab def reputationversion  1 "Provocation" 0 "Safety"
	lab val reputationversion reputationversion

	* Change table labels
	lab var score 						"IAT D-Score"
	
/*******************************************************************************
	mainiat.tex	
*******************************************************************************/

	gr drop  _all 
	reg score i.reputationversion scorecareer ///
		[pw = weight_platform], ///
		cluster(id)
	
	matrix 	results = r(table)
	local 	pvalue = results[4,2]
	local 	pvalue : di %5.3f `pvalue'
	local 	pvalue = trim("`pvalue'")
	
	
	margins reputationversion
	marginsplot, ///
			recast(bar) ///
			plotopts(color(${col_aux_light}) barwidth(0.5)) ///
			ciopts(recast(rcap) color("navy")) ///
			title("") ///
			${plot_options} ///
			ylabel(, noticks labsize(${grlabsize}) glcolor(gs15)) ///
			xlabel(, labsize(${grlabsize})) ///
			xtitle(Instrument, size(${grlabsize})) 	///
			ytitle("D-Score", size(${grlabsize})) ///
			title(All respondents, box fcolor(gs15) bcolor(gs15) bexpand size(${grlabsize})) ///
			text(.38 .47 "t-test for" "coefficients equality" "P-value  = `pvalue'", size(medium)) ///
			name(all)
			
			
	reg score i.reputationversion scorecareer if d_man == 1 ///
		[pw = weight_platform], ///
		cluster(id) 
	
	matrix 	results = r(table)
	local 	pvalue = results[4,2]
	local 	pvalue : di %5.3f `pvalue'
	local 	pvalue = trim("`pvalue'")
	
	margins reputationversion
	marginsplot, ///
			recast(bar) ///
			plotopts(color(${col_aux_light}) barwidth(0.5)) ///
			ciopts(recast(rcap) color(${col_1})) ///
			title("") ///
			${plot_options} ///
			ylabel(, noticks labsize(${grlabsize}) labcolor(white) glcolor(gs15)) ///
			xlabel(, labsize(${grlabsize})) ///
			xtitle(Instrument, size(${grlabsize})) ///
			yscale(noline) ///
			ytitle("") ///
			title(Male respondents, box fcolor(gs15) bcolor(gs15) bexpand size(${grlabsize})) ///
			text(.38 .47 "t-test for" "coefficients equality" "P-value  = `pvalue'", size(medium)) ///
			name(male)
			
	reg score i.reputationversion scorecareer if d_man == 0 ///
		[pw = weight_platform], ///
		cluster(id) 
		
	matrix 	results = r(table)
	local 	pvalue = results[4,2]
	local 	pvalue : di %5.3f `pvalue'
	local 	pvalue = trim("`pvalue'")
	
	margins reputationversion
	marginsplot, ///
			recast(bar) ///
			plotopts(color(${col_aux_light}) barwidth(0.5)) ///
			ciopts(recast(rcap) color(${col_2})) ///
			title("") ///
			${plot_options} ///
			ylabel(, noticks labsize(${grlabsize}) labcolor(white) glcolor(gs15)) ///
			xlabel(, labsize(${grlabsize})) ///
			xtitle(Instrument, size(${grlabsize})) ///
			yscale(noline) ///
			ytitle("") ///
			title(Female respondents, box fcolor(gs15) bcolor(gs15) bexpand size(${grlabsize})) ///
			text(.38 .47 "t-test for" "coefficients equality" "P-value  = `pvalue'", size(medium)) ///
			name(female)
			
	gr combine all female male, ycommon cols(3) graphregion(color(white))
	
	* Export graph
	gr export "${out_graphs}/Presentation/iat_reg.png", width(5000) replace
	 
******************************** The end ***************************************
