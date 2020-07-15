/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************

	OUTLINE:	PART 1: Load data
				PART 2: Run regressions
				PART 3: Export table

	REQUIRES:	${dt_final}/platform_survey_constructed.dta
	CREATES:	${out_tables}/priming.tex

	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]
		
********************************************************************************
       PART 1: Load data
********************************************************************************/

	use "${dt_final}/platform_survey_constructed.dta", clear

/********************************************************************************
       PART 2: Run regressions
********************************************************************************/

	reg scorereputation i.q_group, robust
	est sto priming1
	
	sum scorereputation
	estadd scalar mean `r(mean)'
	
	reg scoresecurity i.q_group, robust
	est sto priming2
	
	sum scoresecurity
	estadd scalar mean `r(mean)'

	
/********************************************************************************
       PART 3: Export table
********************************************************************************/

	esttab priming1 priming2 ///
		using "${out_tables}/${star}priming.tex",  ///
		${star} ///
		tex se replace label  star(* .1 ** .05 *** .01) ///
		nomtitles nonotes ///
		drop(1.q_group) ///
		b(%9.3f) se(%9.3f) ///
		scalar("mean Sample mean") ///
		prehead("\begin{tabular}{l*{2}{c}} \hline\hline \\[-1.8ex] & \multicolumn{2}{c}{Dependent variable:} \\ & \multicolumn{2}{c}{IAT D-Score} \\ & Advances & Safety \\") ///
		posthead("\hline \\[-1.8ex]") ///
		prefoot("(Omitted category: Order: safety IAT; safety questions; advances IAT; advances questions) & & \\ \\[-1.8ex] \hline \\[-1.8ex]") ///
		postfoot("\hline\hline \end{tabular}")
			
**************************** End of do-file ************************************