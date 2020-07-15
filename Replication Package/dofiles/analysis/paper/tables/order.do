/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 			Test for order effects in on screen presentation of space		   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:	${out_tables}/order.tex
				
	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]

********************************************************************************
       PART 1: Define sample
********************************************************************************/

	use "${dt_final}/pooled_rider_audit_constructed.dta", clear
	
	* Only baseline and price experiment rider
	keep if inlist(phase, 1, 2)
	
	* Only observations that we know the order of options shown
	keep if !missing(top_car)
	
/********************************************************************************
	PART 2: Run regressions
********************************************************************************/	
	
	* Only car choice
	reg d_women_car i.top_car ///
		[pw = weight] ///
		, ///
		cluster(user_uuid)
		
	est sto top1
	
	estadd local riders `e(N_clust)'

	* Interaction with opportunity cost: only for riders who did OC rides
	reg d_women_car top_car##d_pos_premium ///
		if d_anyphase2 ///
		[pw = weight] ///
		, ///
		cluster(user_uuid)
		
	est sto top2
	
	estadd local riders `e(N_clust)'

/********************************************************************************
	PART 3: Export regression table
********************************************************************************/	

	esttab top1 top2 using "${out_tables}/${star}order.tex" ///
		, ///
		${star} ///
		scalars("riders Riders") ///
		label tex replace se ///
		star(* .1 ** .05 *** .01) ///
		nonotes nomtitles nobaselevels noomit ///
		b(%9.3f) se(%9.3f) ///
		prehead("\begin{tabular}{l*{2}{c}} \hline\hline \\[-1.8ex] & \multicolumn{2}{c}{\begin{tabular}{@{}c@{}}Dependent variable: \\ Chose reserved space\end{tabular}} \\" ) ///
		postfoot("\hline\hline \end{tabular}") ///
		posthead("\hline \\[-1.8ex]")

*============================================================= That's all, folks!