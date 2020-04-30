	
/********************************************************************************
       PART 1: Load data
********************************************************************************/	
	
	* Load full rider data
	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear
	
	* Relevant variables are in the exit survey, so only one obs per rider
	duplicates drop user_uuid, force

/********************************************************************************
       PART 2: Prepare data
********************************************************************************/	

	* Reshape, as one user can list multiple factors
	reshape long advantage_pink_, i(user_uuid) j(advantage)
	
	* Drop blank observations created by reshape
	drop if missing(advantage_pink_)

	* Count number of riders that answered this question
	qui 	unique 			user_uuid
	local 	participants 	= r(unique)

	* Count number of riders that mentioned each factor
	collapse (sum) advantage_pink_, by(advantage)

	* Make the variable a share of riders
	replace advantage_pink_ = (advantage_pink_/`participants')*100
	
	* Order the graph by most mentioned factor
	sort 	advantage_pink_
	gen 	order = _n
	
	* Label factors
	lab def advantage 	1 "None" ///
						3 `" "More" "comfort" "' ///
						6 `" "Less" "harassment" "' ///
						4 `" "Less" "crowding" "' ///
						5 "Safety" ///
						2 "Other"
	lab val order advantage
	
/********************************************************************************
       PART 3: Create graph
********************************************************************************/
	
	gr bar (mean) 	advantage_pink_, ///
					over(order) ///
					ytitle(Percent of riders that mention factor) ///
					bar(1, color(${col_womencar})) ///
					graphregion(color(white)) bgcolor(white) ylab(,glcolor(${col_box})) ///
					blabel(bar, format(%9.2f))
			
	gr export "${out_graphs}/advantages_pink_car.png", replace width(5000)
	
***************************************************************** End of do-file
