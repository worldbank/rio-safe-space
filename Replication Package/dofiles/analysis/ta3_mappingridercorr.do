	
/********************************************************************************
       PART 1: Define sample 
********************************************************************************/

	use "${dt_rider_fin}/pooled_rider_audit_constructed_full.dta", clear

/********************************************************************************
       PART 2: Regressions  
********************************************************************************/

	reg CI_men_present_pink MA_men_present_pink, cluster(user_uuid) 
	est sto corr1
	estadd local	riders	`e(N_clust)'

	reg rider_obs_crowd d_highcongestion, cluster(user_uuid) 
	est sto corr2 
	estadd local	riders	`e(N_clust)'

		
/********************************************************************************
		PART 3: Export table
********************************************************************************/	
		
	esttab corr1 corr2 using "${out_github}/mappingridercorr.tex", tex t(3) b(3) ///
		label se star(* .1 ** .05 *** .01) ///
		replace nonotes nomtitle ///
		scalar("riders Riders") ///
		prehead("\begin{tabular}{l*{2}{c}} \hline\hline \\[-1.8ex] & \multicolumn{2}{c}{\begin{tabular}{@{}c@{}}Dependent variable: Rider reports \end{tabular}} \\ Platform observations & Share of men in reserved space & High crowding \\" )  ///
		posthead("\hline \\[-1.8ex]") ///
		prefoot("\hline \\[-1.8ex]") ///
		postfoot("\hline\hline \end{tabular}")
		
	copy "${out_github}/mappingridercorr.tex" "${out_tables}/mappingridercorr.tex", replace

***************************************************************** End of do-file

	
