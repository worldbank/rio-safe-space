/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 						Adjustment on other margins							   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta
	CREATES:	${out_tables}/adjustment.tex
				
	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]

********************************************************************************
       PART 1: Define sample 
********************************************************************************/

	use "${dt_final}/pooled_rider_audit_constructed.dta", clear
	
	foreach var of varlist CI_time* {
		replace `var' = `var'/60
	}
	
/********************************************************************************
       PART 3: Regressions
********************************************************************************/

	foreach var of global adjustind {

/*------------------------------------------------------------------------------
	Panel A
------------------------------------------------------------------------------*/

		* Uncontrolled means
		reg `var' ///
			[pw = weightfe] ///
			if inlist(phase, 1, 2) & d_pos_premium == 0, ///
			vce(cluster user_id)
			
		local mean 	= el(r(table), 1,1)
		local se   	= el(r(table), 2,1)
		local se  	= round(`se', .001)
		local se 	"(0`se')"
		
		* Revealed preference rides
		xtreg 	`var' d_pos_premium ///
				if inlist(phase, 1, 2) ///
				[pw = weightfe], ///
				vce(cluster user_id) ///
				fe
				
		est sto `var'p2
		
		estadd local 	users 	"Yes" 
		estadd local 	riders	"`e(N_clust)'"
		estadd scalar 	mean 	`mean'
		estadd local  	se 		`se'

/*------------------------------------------------------------------------------
	Panel B
------------------------------------------------------------------------------*/

		* Uncontrolled mean
		reg `var' ///
			[pw = weightfe] ///
			 if phase == 3 & d_women_car == 1, ///
			vce(cluster user_id)
			
		local mean 	= el(r(table), 1,1)
		local se   	= el(r(table), 2,1)
		local se  	= round(`se', .001)
		local se 	"(0`se')"

		* Random assignment rides
		xtreg 	`var' d_mixed_car  ///
				if phase == 3 ///
				[pw = weightfe], ///
				vce(cluster user_id) ///
				fe
				
		est sto `var'p3
		
		estadd local 	users 	"Yes" 
		estadd local 	riders	"`e(N_clust)'"
		estadd scalar 	mean 	`mean'
		estadd local  	se 		`se'
		
		
	}
		
/********************************************************************************
		PART 4: Export table
********************************************************************************/	
	
/*------------------------------------------------------------------------------
	Panel A
------------------------------------------------------------------------------*/

	local models 	CI_wait_time_minp2 d_against_trafficp2 CO_switchp2 RI_spotp2 CI_time_AMp2 CI_time_PMp2
	
	tableprep `models', panel(A) title(Revealed preference rides) posthead("& (1) & (2)  & (3) & (4) & (5) & (6) \\")
	
	esttab 	`models' using "${out_tables}/${star}adjustment.tex",  ///
			`r(table_options)' ${star} ///
			nonumbers ///
			drop(_cons) ///
			scalars	("riders Riders" ///
					 "mean Uncontrolled mean when zero opportunity cost" ///
					 "se \,") 
			

/*------------------------------------------------------------------------------
	Panel B
------------------------------------------------------------------------------*/

	local models CI_wait_time_minp3 d_against_trafficp3 CO_switchp3 RI_spotp3 CI_time_AMp3 CI_time_PMp3
	
	tableprep `models', panel(B) title(Randomized assignment of space)
	
	esttab 	`models' using "${out_tables}/${star}adjustment.tex",  ///
			drop(_cons) ///
			`r(table_options)' ${star} ///
			nonumbers nomtitles ///
			scalars	("riders Riders" ///
					 "mean Uncontrolled mean when zero opportunity cost" ///
					 "se \,")
			
	
************************************************************************ The end


