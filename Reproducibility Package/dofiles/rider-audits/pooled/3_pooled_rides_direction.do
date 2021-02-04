/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*				Identify ride direction (inbound/outbound)					   *
********************************************************************************

	* REQUIRES:  	${dt_int}/pooled_rider_audit_rides_coverage
	* CREATES:		${dt_int}/pooled_rider_audit_rides_coverage_direction

	* WRITEN BY:   Luiza Andrade

*******************************************************************************/

	use	"${dt_int}/pooled_rider_audit_rides_coverage.dta", clear

	gen 	CI_direction_1st_line  = .
	gen 	CI_direction_2nd_line  = .

	* From lines 4/5 to lines 2/3
	forvalues CI_line = 4/5 {
		forvalues CO_line = 2/3 {
			replace CI_direction_1st_line = (CI_station <= `CI_line'03) if CI_line == `CI_line' & CO_line == `CO_line'
			replace CI_direction_2nd_line = (CO_station >= `CO_line'03) if CI_line == `CI_line' & CO_line == `CO_line'
		}
	}
	
	* From lines 2/3 to lines 4/5
	forvalues CI_line = 2/3 {
		forvalues CO_line = 4/5 {
			replace CI_direction_1st_line = (CI_station <= `CI_line'03) if CI_line == `CI_line' & CO_line == `CO_line'
			replace CI_direction_2nd_line = (CO_station >= `CO_line'03) if CI_line == `CI_line' & CO_line == `CO_line'
		}
	}
	
	* From lines 4/5 to line 1
	forvalues CI_line = 4/5 {
		replace CI_direction_1st_line = (CI_station <= `CI_line'03) 	if CI_line == `CI_line' & CO_line == 1
		replace CI_direction_2nd_line = (CO_station >= 104)			if CI_line == `CI_line' & CO_line == 1
	}
		
	* From line 1 to lines 4/5
	forvalues CO_line = 4/5 {
		replace CI_direction_1st_line = (CI_station <= 104)			if CO_line == `CO_line' & CI_line == 1
		replace CI_direction_2nd_line = (CI_station >= `CI_line'03) 	if CO_line == `CO_line' & CI_line == 1
	}
	
	* From line 4 to line 5 (and vice-versa)
	replace CI_direction_1st_line = (CI_station <= 403) if CI_line == 4 & CO_line == 5
	replace CI_direction_2nd_line = (CO_station >= 503) if CI_line == 4 & CO_line == 5
	replace CI_direction_1st_line = (CI_station <= 503) if CI_line == 5 & CO_line == 4
	replace CI_direction_2nd_line = (CO_station >= 403) if CI_line == 5 & CO_line == 4
	
	* From line 3 to line 2
	replace CI_direction_1st_line = (CI_station <= 307) if CI_line == 3 & CO_line == 2
	replace CI_direction_2nd_line = (CO_station >= 208) if CI_line == 3 & CO_line == 2
	
	* From line 2 to line 3
	replace CI_direction_1st_line = (CI_station <= 208) if CO_line == 3 & CI_line == 2
	replace CI_direction_2nd_line = (CO_station >= 307) if CO_line == 3 & CI_line == 2
										
	* From line 3 to line 1
	replace CI_direction_1st_line = (CI_station == 301 | CI_station == 302) | ///
									(CI_station == 306 & inlist(CO_station,119,118)) if ///
									CI_line == 3 & CO_line == 1
									
	replace CI_direction_2nd_line = 0 if CI_line == 3 & CO_line == 1
	
	* From line 2 to line 1
	replace cover_118 = 1 if CI_station == 201 & CO_station == 118
	replace cover_119 = 1 if CI_station == 201 & CO_station == 118
	
	replace CI_direction_1st_line = (CI_station == 203 & CO_station == 116) | ///
									(CI_station == 202 & CO_station == 106) | ///
									CI_station == 201 if CI_line == 2 & CO_line == 1
	replace CI_direction_2nd_line = (CI_station == 201 & inlist(CO_station,118,109,106)) | ///
									(CI_station == 202 & CO_station == 106) | ///
									(CI_station <= 207 & CO_station == 116) ///
									if CI_line == 2 & CO_line == 1
	
	
	
	* From line 1 to line 3
	replace CI_direction_1st_line = CI_station <= 110 | ///
									CO_station >= 307 ///
									if CI_line == 1 & CO_line == 3
	replace CI_direction_2nd_line = CI_station <= 110 | ///
									CO_station >= 307 ///
									if CI_line == 1 & CO_line == 3
		
	* From line 1 to line 2
	replace CI_direction_1st_line = CI_station <= 103 | ///
									CI_station == 109 | ///
									(CI_station == 110 & CO_station >= 208) | ///
									CI_station == 111 | ///
									(CI_station >= 115 & CO_station > 208) ///
									if CI_line == 1 & CO_line == 2
	replace CI_direction_2nd_line = CI_station <= 103 | ///
									CI_station == 109 | ///
									(CI_station == 110 & CO_station >= 208) | ///
									CI_station == 111 | ///
									(CI_station >= 115 & CO_station > 208) ///
									if CI_line == 1 & CO_line == 2
									
	gen 	CI_direction = CO_station > CI_station 	if (CI_line == CO_line)
	replace CI_direction = CI_direction_1st_line 	if (CI_direction_1st_line == CI_direction_2nd_line) & missing(CI_direction)
	replace CI_direction = .c 					 	if (CI_direction_1st_line != CI_direction_2nd_line) & missing(CI_direction)
									
	compress
	dropmiss, force
	
	save 			 "${dt_int}/pooled_rider_audit_rides_coverage_direction.dta", replace
	iemetasave using "${dt_int}/pooled_rider_audit_rides_coverage_direction.txt", replace
	
********************************************************************************
