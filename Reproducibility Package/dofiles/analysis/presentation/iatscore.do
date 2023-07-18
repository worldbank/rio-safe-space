	
	* Load platform survey data
	use "${dt_platform_fin}/platform_survey_constructed.dta", clear
	
	* We cannot apply weights to density plots, so we will expand observations
	* according to their weights
	*gen expand = round(weight_platform*1000, 1)
	*expand expand

	local scale ylabel(0(.5)1)
	
/******************************************************************************* 
						Women only: safety vs advances
*******************************************************************************/

*	replace scoresecurity = -1 * scoresecurity
	
	twoway 	(kdensity scorereputation,  color(${col_mixedcar})) ///
			(kdensity scoresecurity,  	color(${col_womencar})), ///
			xline(0, lpattern(dash)) xtitle("IAT D-score") ///
			legend(order(2 "Safety IAT" 1 "Advances IAT") size(4) region(lcolor(white))) ///
			ytitle("Density", size(4)) ///
			ylab(, noticks labsize(4) glcolor(gs15)) ///
			graphregion(color(white)) bgcolor(white) ///
			ylab(, glcolor(gs15) labsize(4)) ///
			xtitle(, size(4))
			
	gr export	"${out_graphs}/Presentation/IAT_byversion.png", width(5000) replace
	
**************************** End of do-file ************************************
