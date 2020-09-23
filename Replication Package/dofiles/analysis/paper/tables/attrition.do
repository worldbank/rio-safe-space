/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*					Correlates of attrition across phases					   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_constructed_full.dta
	CREATES:	${out_tables}/attrition.tex
				
	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]

********************************************************************************
	Prepare data
*******************************************************************************/

	* Load data
	use "${dt_final}/pooled_rider_audit_constructed_full.dta", clear
	/* This data set includes riders who are not in the main sample, because 
	   we're interested on what factors are correlated with their drop out */
	
	* Regression is at user level. All variables are constant per user, so
	* dropping duplicates does not affect them
	drop	if (n_stages == 2 & stage == 0)
	keep	user_id ${demographics} d_anyphase* pcbaselinetakeup baselinerides any510takeup fivetenrides
	
	duplicates drop 
	isid user_id
	
/*******************************************************************************
	Run regressions
*******************************************************************************/

	* Any phase 2 rides
	reg d_anyphase2 $demographics
	est sto attrition1
	
	sum 	d_anyphase2 if e(sample)
	estadd 	scalar 	mean1 	= round(r(mean), .001)

	* Any phase 2 rides, controlling for baseline takeup, if at least 5 rides at 0 OC
	reg d_anyphase2  $demographics pcbaselinetakeup 			if baselinerides >= 5
	est sto attrition2
	
	sum		d_anyphase2 if e(sample)
	estadd 	scalar 	mean1 	= round(r(mean), .001)
	
	* Any phase 3 rides
	reg d_anyphase3 $demographics
	est sto attrition3
	
	sum 	d_anyphase3 if e(sample)
	estadd 	scalar 	mean1 	= round(r(mean), .001)
	
	* Any phase 3 rides, controlling for baseline takeup, if at least 5 rides at 0 OC
	reg d_anyphase3  $demographics pcbaselinetakeup if baselinerides >= 5 & !missing(baselinerides)
	est sto attrition4
	
	sum d_anyphase3 if e(sample)
	estadd scalar	mean1 	= round(r(mean), .001)
	
	* Any phase 3 rides, controlling for baseline takeup and takeup at 5/10 cents, if at least 5 rides at 10 or 5 OC
	reg d_anyphase3 $demographics pcbaselinetakeup any510takeup if fivetenrides >= 5  & !missing(fivetenrides)
	est sto attrition5
	
	sum d_anyphase3 if e(sample)
	estadd scalar 	mean1 	= round(r(mean), .001)

/*******************************************************************************
	Export table
*******************************************************************************/

	esttab attrition1 attrition2 attrition3 attrition4 attrition5 ///
		using "${out_tables}/attrition.tex", ///
		tex replace se label nomtitles ///
		b(%9.3f) se(%9.3f) ///
		${star} ///
		scalars("mean1 Regression sample mean") ///
		prehead("\begin{tabular}{l*{6}{c}} \hline\hline \\[-1.8ex] & \multicolumn{5}{c}{Dependent variable:} \\[-1.8ex]" ) ///
		mgroups("{p{3.2cm}}{\center Started revealed preferences rides" "{p{5cm}}{\center Started randomized car assignment rides", ///
				pattern(1 0 1 0 0) prefix(\multicolumn{@span}) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		prefoot(" \\[-1.8ex] \hline  \\[-1.8ex]") ///
		postfoot("\hline\hline \end{tabular} ") ///
		posthead("\hline \\[-1.8ex]")

******************************** The end ***************************************
