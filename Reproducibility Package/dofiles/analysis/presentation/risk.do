/*******************************************************************************
	Prepare data
*******************************************************************************/
	
	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear
	
	
	keep if inlist(phase, 1, 2) & d_anyphase2 ==1
	
	replace d_women_car = d_women_car * 100
	
	label variable d_grope_high 		"Physical harassment" 
	label variable d_comments_high 		"Verbal harassment"
	label variable d_robbed_high 		"Robbery" 
	
	reg d_women_car ///
		[pw = weight] ///
		if phase == 1

	
/*******************************************************************************
	Run regressions and create plot
*******************************************************************************/

	local	gropecolor		${col_womencar}
	local 	gropetitle		Physical harassment
	local 	gropeytitle		Percent of reserved space rides
	local	commentscolor	${col_mixedcar}
	local 	commentstitle	Verbal harassment
	local 	commentsscale	noline
	local 	commentsytitle	`" "" "'
	local	commentslabel	labcolor(white)
	local	robbedcolor		navy
	local 	robbedtitle		Robbery
	local 	robbedscale		noline
	local 	robbedytitle	`" "" "'
	local	robbedlabel		labcolor(white)
	lab def risk 			0 "Low risk" 1 "High risk", replace
		
	gr drop _all 
	
	foreach risk in grope comments robbed {

		reg d_women_car i.d_`risk'_high ///
			 d_highcongestion d_highcompliance ///
			 i.CI_line ///
			 [pw = weight] ///
			if phase == 1, ///
			cluster(user_id) 
			
		lab val d_`risk'_high	risk
	
		margins d_`risk'_high
		
		marginsplot, ///
			recast(bar) ///
			plotopts(color(${col_aux_light}) barwidth(0.5)) ///
			ciopts(recast(rcap) color("``risk'color'")) ///
			title("") ///
			${plot_options} ///
			ylabel(0(10)40, noticks labsize(${grlabsize}) ``risk'label' glcolor(gs15)) ///
			yscale(range(0(10)45) ``risk'scale') ///
			name(`risk') ///
			ytitle(``risk'ytitle' , size(${grlabsize}))
			
	} 
	
	graph combine grope comments robbed, cols(3) graphregion(color(white))
				
	gr export "${out_graphs}/Presentation/risk.png", width(5000) replace
	
******************************** The end ***************************************
