
	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear
	
	preserve
		collapse (count) ride if inlist(phase, 1, 2), by(user_id)
		sum ride
	restore
	
	preserve
		collapse (count) ride if phae == 3, by(user_id)
		sum ride
	restore
	
		* Load platform survey data
		* Load platform survey data
	use "${dt_platform_fin}/platform_survey_constructed.dta", clear

	* Drop observations that don't have both safety and advances IAT -- otherwise, 
	* we're not comparing the D-scores
	keep if !missing(scoresecurity) & !missing(scorereputation)

	* Reshape to long: each line is one participant and IAT type
	reshape long score time errorrate, i(id) j(version) string
		
	reg score if version == "security"
	reg score if version == "reputation"

	* Penetration of smartphone usage
	tab d_smartphone
