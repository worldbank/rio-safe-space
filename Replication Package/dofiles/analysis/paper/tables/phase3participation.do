/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*					Correlates of attrition across phases					   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_phase3_offers.dta
	CREATES:	${out_tables}/attrition.tex
				
	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]

********************************************************************************
	Prepare data
*******************************************************************************/

	use "${dt_final}/pooled_rider_audit_phase3_offers.dta", clear			// Only 1 offer per day was merged.

	* Keep only the first 10 rides of phase 3: that's all riders were supposed
	* to take. However, some riders received extra rides if they completed their
	* rides too quickly
	drop if date >= lastday	// results are not robust to changes in this cutoff
	
	
/*******************************************************************************
	Ride level regression
*******************************************************************************/

	* Ride
	areg 	offer_taken 	d_offered_women, cluster(user_uuid) a(user_uuid)
	est sto rider
	estadd 	local riders `e(N_clust)'

/*******************************************************************************
	Rider-day level regression
*******************************************************************************/
	
	* Collapse data to drop duplicated entries for the same rider on the same 
	* day
	collapse 	(mean)	d_offered_women ///
				(max) 	offer_taken	///
				(count) user_id ///												There are only 541 user-days with 2 rides. So we should lose ~270 observations when collapsing
				, ///
			by  (user_uuid date)

	lab var d_offered_women	"Assigned to reserved space"
	
	areg 	offer_taken 	d_offered_women, cluster(user_uuid) a(user_uuid)
	est sto day
	estadd 	local riders `e(N_clust)'

/*******************************************************************************
							Create table
*******************************************************************************/
	
	esttab 	rider day using "${out_tables}/${star}phase3participation.tex", ///
			mtitles("Rider-ride" "Rider-day") ///
			${star} ///
			label tex replace se ///
			star(* .1 ** .05 *** .01) ///
			b(%9.3f) se(%9.3f) ///
			scalars("riders Riders") ///
			prehead("\begin{tabular}{l*{1}{cc}} \hline\hline \\[-1.8ex] & \multicolumn{2}{c}{Dependent variable: Accepted task} \\" ) ///
			prefoot("\hline \\[-1.8ex]") ///
			postfoot("\hline\hline \end{tabular}") ///
			posthead("\hline \\[-1.8ex]")
				
******************************** The end ***************************************
