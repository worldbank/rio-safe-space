	
/********************************************************************************
       PART 1: Define sample 
********************************************************************************/

	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear
	
	xtset user_id
	
	foreach var of varlist CI_time* {
		replace `var' = `var'/60
	}
	
/********************************************************************************
       PART 3: Regressions
********************************************************************************/

	local adjustind CI_wait_time_min d_against_traffic CO_switch RI_spot CI_time_AM CI_time_PM

	foreach var in `adjustind' {
	
		reg `var' ///
			[pw = weightfe] ///
			if inlist(phase, 1, 2) & d_pos_premium == 0, ///
			vce(cluster user_id)
			
		local mean 	= el(r(table), 1,1)
		local se   	= el(r(table), 2,1)
		local se  	= round(`se', .001)
		local se 	"(0`se')"
		
		* Phase 2
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

		reg `var' ///
			[pw = weightfe] ///
			 if phase == 3 & d_women_car == 1, ///
			vce(cluster user_id)
			
		local mean 	= el(r(table), 1,1)
		local se   	= el(r(table), 2,1)
		local se  	= round(`se', .001)
		local se 	"(0`se')"

		xtreg 	`var' d_mixed_car  ///
				if phase == 3 ///
				[pw=weightfe], ///
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
	
	local models 	CI_wait_time_minp2 d_against_trafficp2 CO_switchp2 RI_spotp2 CI_time_AMp2 CI_time_PMp2
	
	tableprep `models', panel(A) title(Revealed preference rides) posthead("& (1) & (2)  & (3) & (4) & (5) & (6) \\")
	
	esttab 	`models' using "${out_github}/adjustment.tex",  ///
			`r(table_options)' ///
			nonumbers ///
			drop(_cons) ///
			scalars	("riders Riders" ///
					 "mean Uncontrolled mean when zero opportunity cost" ///
					 "se \,") 
			
	local models CI_wait_time_minp3 d_against_trafficp3 CO_switchp3 RI_spotp3 CI_time_AMp3 CI_time_PMp3
	
	tableprep `models', panel(B) title(Randomized assignment of space)
	
	esttab 	`models' using "${out_github}/adjustment.tex",  ///
			drop(_cons) ///
			`r(table_options)' ///
			nonumbers nomtitles ///
			scalars	("riders Riders" ///
					 "mean Uncontrolled mean when zero opportunity cost" ///
					 "se \,")
			
	
	copy "${out_github}/adjustment.tex" "${out_tables}/adjustment.tex", replace
	
*--------------------------------- The end ------------------------------------*


