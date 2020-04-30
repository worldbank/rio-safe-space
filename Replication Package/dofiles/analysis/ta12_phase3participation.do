/*******************************************************************************
							Prepare data
*******************************************************************************/

	use "${dt_rider_fin}\pooled_rider_audit_phase3_offers.dta", clear			// Only 1 offer per day was merged.

	
	drop if date >= lastday	// results are not robust to changes in this cutoff
	
	areg 	offer_taken 	d_offered_women, cluster(user_uuid) a(user_uuid)
	est sto rider
	estadd 	local riders `e(N_clust)'
	
	
	collapse 	(mean)	d_offered_women ///
				(max) 	offer_taken	///
				(count) user_id ///												There are only 541 user-days with 2 rides. So we should lose ~270 observations when collapsing
				, ///
			by  (user_uuid date)

	lab var d_offered_women	"Assigned to reserved space"
	
	tempfile	phase3
	save		`phase3'

/*******************************************************************************
							Create table
*******************************************************************************/

	areg 	offer_taken 	d_offered_women, cluster(user_uuid) a(user_uuid)
	est sto day
	estadd 	local riders `e(N_clust)'
	
	esttab 	rider day using "${out_github}/phase3participation.tex", ///
			mtitles("Rider-ride" "Rider-day") ///
			label tex replace se ///
			star(* .1 ** .05 *** .01) ///
			b(%9.3f) se(%9.3f) ///
			scalars("riders Riders") ///
			prehead("\begin{tabular}{l*{1}{cc}} \hline\hline \\[-1.8ex] & \multicolumn{2}{c}{Dependent variable: Accepted task} \\" ) ///
			prefoot("\hline \\[-1.8ex]") ///
			postfoot("\hline\hline \end{tabular}") ///
			posthead("\hline \\[-1.8ex]")
			
	copy "${out_github}/phase3participation.tex" "${out_tables}/phase3participation.tex", replace
	
******************************** The end ***************************************
