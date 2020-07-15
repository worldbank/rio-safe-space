/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
********************************************************************************

	OUTLINE:	PART 1: Load data
				PART 2: Run regressions
				PART 3: Export table

	REQUIRES:	${dt_final}/platform_survey_constructed.dta
	CREATES:	${out_tables}/response.tex

	WRITEN BY:  Luiza Andrade
	
********************************************************************************
       PART 1: Load data
********************************************************************************/

	use "${dt_final}/platform_survey_constructed.dta", clear
	
/*******************************************************************************
       PART 2: Run regressions
********************************************************************************/
	
	* Are women more likely to take the survey?
	reg d_accepted d_woman, robust 
	est sto responsesurvey1
	
	sum 	d_accepted
	estadd 	scalar 	samplemean 	= round(r(mean),.001) 	
	
	estadd 	local 	sample 		"All" 
	estadd 	local 	platform 	"No"
	
	* Are women more likely to take the survey, controlling for platform?
	reg d_accepted d_woman i.platform , robust 
	est sto responsesurvey2
	
	test 	(i2.platform == 0)  ///
			(i6.platform == 0)  ///
			(i8.platform == 0)  ///
			(i11.platform == 0) ///
			(i12.platform == 0)
	estadd scalar f = round(r(p),.001) 	
	
	sum d_accepted
	estadd scalar samplemean = round(r(mean),.001)
	estadd local sample "All" 
	estadd local platform "Yes"
	
	* Are women more likely to take the IAT?
	* (Only applies to people invited to take IAT)
	reg d_iat d_woman 							if d_iat_invited == 1, robust 
	est sto response1
	
	sum 	d_iat 	if d_iat_invited == 1
	estadd 	scalar 	samplemean 	= round(r(mean),.001) 	
	estadd 	local 	sample 		"All" 
	estadd 	local 	platform 	"No"
	
	* Are women more likely to take the IAT, controlling for platform?
	* (Only applies to people invited to take IAT)
	reg d_iat d_woman i.platform 				if d_iat_invited == 1, robust 
	est sto response2
	
	test 	(i2.platform == 0)  ///
			(i6.platform == 0)  ///
			(i8.platform == 0)  ///
			(i11.platform == 0) ///
			(i12.platform == 0)
			
	estadd 	scalar 	f 			= round(r(p),.001) 	
	sum 	d_iat 	if d_iat_invited == 1
	estadd 	scalar 	samplemean 	= round(r(mean),.001) 	
	estadd 	local 	sample 		"All" 
	estadd 	local 	platform 	"Yes"
	
	* Are women who ride the pink car more likely to take the IAT?
	* (Only applies to women invited to take IAT)
	reg d_iat mostlypink_self i.platform   			if d_woman == 1 & d_iat_invited == 1, robust 
	est sto response3
	
	test 	(i2.platform == 0)  ///
			(i6.platform == 0)  ///
			(i8.platform == 0)  ///
			(i11.platform == 0) ///
			(i12.platform == 0)
			
	estadd 	scalar 	f 			= round(r(p),.001)
	sum 	d_iat	if d_woman == 1 & d_iat_invited == 1
	estadd 	scalar 	samplemean 	= round(r(mean),.001) 	
	estadd 	local 	sample 		"Females" 
	estadd 	local 	platform 	"Yes"
	
	* Are men who have women in the family riding the pink car more likely to take the IAT?
	* (Only applies to men invited to take IAT)
	reg d_iat mostlypink_family i.platform  			if d_woman == 0 & d_iat_invited == 1, robust 
	est sto response4
	
	test 	(i2.platform == 0)  ///
			(i6.platform == 0)  ///
			(i8.platform == 0)  ///
			(i11.platform == 0) ///
			(i12.platform == 0)
			
	estadd 	scalar 	f 			= round(r(p),.001) 		
	sum 	d_iat 	if d_woman == 0 & d_iat_invited == 1
	estadd 	scalar 	samplemean 	= round(r(mean),.001) 	
	estadd 	local	sample 		"Males" 
	estadd 	local 	platform 	"Yes"

/*******************************************************************************
       PART 3: Export table
********************************************************************************/
	
	esttab responsesurvey2 response2 response3 response4 ///
		using "${out_tables}/${star}response", ///
		${star} ///
		tex se replace nomtitles nodepvars drop(*.platform) ///
		label  star(* .1 ** .05 *** .01) nonotes ///
		scalars("sample Sample" "platform Platform FE" "f F-test for platform dummies (p-value)" "samplemean Sample mean") ///
		sfmt(%9.3f) b(%9.3f) se(%9.3f) ///
		prehead("\begin{tabular}{l*{5}{c}} \hline\hline \\[-1.8ex] & \multicolumn{4}{c}{Dependent variable:} \\ & \multicolumn{1}{c}{Responds platform survey} & \multicolumn{3}{c}{Responds IAT} \\ \cmidrule(lr){2-2}\cmidrule(lr){3-5}") ///
		posthead("\hline \\[-1.8ex]")	///
		prefoot("\\[-1.8ex] \hline \\[-1.8ex]")	///
		postfoot("\hline\hline \end{tabular}")	

*============================================================= That's all, folks!