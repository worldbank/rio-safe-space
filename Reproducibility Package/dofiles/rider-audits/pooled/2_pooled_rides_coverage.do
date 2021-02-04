/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*	 				Identify stations covered by each ride			 		   *
********************************************************************************

	* REQUIRES:  	${dt_int}/pooled_rider_audit_rides
	* CREATES:		${dt_int}/pooled_rider_audit_rides_coverage

	* WRITEN BY:   Luiza Andrade

*******************************************************************************/

	use	"${dt_int}/pooled_rider_audit_rides.dta", clear

	local stationList1 	101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119
	local stationList2 	201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224
	local stationList3 	301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320
	local stationList4 	401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 418 419
	local stationList5 	501 502 503 504 505 506 507 508 509 510 511 512 513 514 515 516 517 518 519 520
	local stationList	101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 ///
						201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 ///
						301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 ///
						401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 418 419 ///
						501 502 503 504 505 506 507 508 509 510 511 512 513 514 515 516 517 518 519 520
	
	foreach stationCode of local stationList {
		gen cover_`stationCode' = 	((CI_station <= `stationCode' & CO_station >= `stationCode') | ///
									(CI_station >= `stationCode' & CO_station <= `stationCode')) & ///
									CI_line == CO_line
	}
	
	* If switched
	* -----------
	
	* From lines 4/5 to lines 2/3
	forvalues CI_line = 4/5 {
		forvalues CO_line = 2/3 {
			foreach stationCode of local stationList`CI_line' {
				if `stationCode' >= `CI_line'03 {
					replace cover_`stationCode' = 1 if CI_line == `CI_line' & CO_line == `CO_line' & CI_station >= `stationCode'
				}
				else {
					replace cover_`stationCode' = 1 if CI_line == `CI_line' & CO_line == `CO_line' & CI_station <= `stationCode'
				}
			}
			foreach stationCode of local stationList`CO_line' {
				if `stationCode' >= `CO_line'03 {
					replace cover_`stationCode' = 1 if CI_line == `CI_line' & CO_line == `CO_line' & CO_station >= `stationCode'
				}
				else {
					replace cover_`stationCode' = 1 if CI_line == `CI_line' & CO_line == `CO_line' & CO_station <= `stationCode'
				}
			}
		}
	}
	
	* From lines 2/3 to lines 4/5
	forvalues CI_line = 2/3 {
		forvalues CO_line = 4/5 {
			foreach stationCode of local stationList`CI_line' {
				if `stationCode' >= `CI_line'03 {
					replace cover_`stationCode' = 1 if CI_line == `CI_line' & CO_line == `CO_line' & CI_station >= `stationCode'
				}
				else {
					replace cover_`stationCode' = 1 if CI_line == `CI_line' & CO_line == `CO_line' & CI_station <= `stationCode'
				}
			}
			foreach stationCode of local stationList`CO_line' {
				if `stationCode' >= `CO_line'03 {
					replace cover_`stationCode' = 1 if CI_line == `CI_line'& CO_line == `CO_line' & CO_station >= `stationCode'
				}
				else {
					replace cover_`stationCode' = 1 if CI_line == `CI_line' & CO_line == `CO_line' & CO_station <= `stationCode'
				}
			}
		}
	}
	
	* From lines 4/5 to line 1
	forvalues CI_line = 4/5 {
		foreach stationCode of local stationList`CI_line' {
			if `stationCode' >= `CI_line'03 {
				replace cover_`stationCode' = 1 if CI_line == `CI_line' & CO_line == 1 & CI_station >= `stationCode'
			}
			else {
				replace cover_`stationCode' = 1 if CI_line == `CI_line' & CO_line == 1 & CI_station <= `stationCode'
			}
		}
		foreach stationCode of local stationList2 {
			if `stationCode' >= 104 {
				replace cover_`stationCode' = 1 if CI_line == `CI_line'& CO_line == 1 & CO_station >= `stationCode'
			}
			else {
				replace cover_`stationCode' = 1 if CI_line == `CI_line' & CO_line == 1 & CO_station <= `stationCode'
			}
		}
	}
	
	
	* From line 1 to lines 4/5
	forvalues CO_line = 4/5 {
		foreach stationCode of local stationList`CI_line' {
			if `stationCode' >= 104 {
				replace cover_`stationCode' = 1 if CI_line == 1 & CO_line == `CO_line' & CI_station >= `stationCode'
			}
			else {
				replace cover_`stationCode' = 1 if CI_line == 1 & CO_line == `CO_line' & CI_station <= `stationCode'
			}
		}
		foreach stationCode of local stationList2 {
			if `stationCode' >= `CO_line'03 {
				replace cover_`stationCode' = 1 if CI_line == 1 & CO_line == `CO_line' & CO_station >= `stationCode'
			}
			else {
				replace cover_`stationCode' = 1 if CI_line == 1 & CO_line == `CO_line' & CO_station <= `stationCode'
			}
		}
	}

	
	* Between lines 4 and 5
	forvalues CI_line = 4/5 {
		forvalues CO_line = 4/5 {
			if CI_line != CO_line {
				foreach stationCode of local stationList`CI_line' {
					if `stationCode' >= `CI_line'04 {
						replace cover_`stationCode' = 1 if CI_line == `CI_line' & CO_line == `CO_line' & CI_station >= `stationCode'
					}
					else {
						replace cover_`stationCode' = 1 if CI_line == `CI_line' & CO_line == `CO_line' & CI_station <= `stationCode'
					}
				}
				foreach stationCode of local stationList2 {
					if `stationCode' >= `CO_line'04 {
						replace cover_`stationCode' = 1 if CI_line == `CI_line' & CO_line == `CO_line' & CO_station >= `stationCode'
					}
					else {
						replace cover_`stationCode' = 1 if CI_line == `CI_line' & CO_line == `CO_line' & CO_station <= `stationCode'
					}
				}
			}
		}
	}
	
	* From line 3 to line 2
	foreach stationCode of local stationList3 {
		if `stationCode' >= 307 {
			replace cover_`stationCode' = 1 if CI_line == 3 & CO_line == 2 & CI_station >= `stationCode'
		}
		else {
			replace cover_`stationCode' = 1 if CI_line == 3 & CO_line == 2 & CI_station <= `stationCode'
		}
	}
	foreach stationCode of local stationList2 {
		if `stationCode' >= 208 {
			replace cover_`stationCode' = 1 if CI_line == 3 & CO_line == 2 & CO_station >= `stationCode'
		}
		else {
			replace cover_`stationCode' = 1 if CI_line == 3 & CO_line == 2 & CO_station <= `stationCode'
		}
	}
	
	* From Santa Cruz to Japeri
	foreach stationCode of local stationList3 {
		if `stationCode' >= 307 {
			replace cover_`stationCode' = 1 if CO_line == 3 & CI_line == 2 & CO_station >= `stationCode'
		}
		else {
			replace cover_`stationCode' = 1 if CO_line == 3 & CI_line == 2 & CO_station <= `stationCode'
		}
	}
	foreach stationCode of local stationList2 {
		if `stationCode' >= 208 {
			replace cover_`stationCode' = 1 if CO_line == 3 & CI_line == 2 & CI_station >= `stationCode'
		}
		else {
			replace cover_`stationCode' = 1 if CO_line == 3 & CI_line == 2 & CI_station <= `stationCode'
		}
	}
										
	* From line 3 to line 1, inbound
	foreach stationCode of local stationList3 {
		if `stationCode' >= 307 {
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station >= `stationCode' & CO_line == 1
		}
		else if `stationCode' == 306 { 
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station >= `stationCode' & CO_line == 1 & CO_station <= 115
		}
		else if `stationCode' == 305 {
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station >= `stationCode' & CO_line == 1 & CO_station <= 111
		}
		else if inlist(`stationCode',304,303) {
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station >= `stationCode' & CO_line == 1 & CO_station <= 104
		}
		else if `stationCode' == 302 {
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station >= `stationCode' & CO_station == 102
		}
	}
	
	foreach stationCode of local stationList1 {
		if `stationCode' > 115 {
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station >= 307 & CO_line == 1 & CO_station <= `stationCode' & CO_station > 115 
		}
		else if `stationCode' <= 115 & `stationCode' > 111 { 
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station >= 306 & CO_line == 1 & CO_station <= `stationCode' & CO_station > 111 
		}
		else if `stationCode' <= 111 & `stationCode' > 104 {
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station >= 305 & CO_line == 1 & CO_station <= `stationCode' & CO_station > 104 
		}
		
		replace cover_104 = 1 if CI_line == 3 & CI_station >= 303 & CO_line == 1 & CO_station == 104
		
		else if `stationCode' < 104 &`stationCode' >= 101 {
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station >= 302 & CO_line == 1 & CO_station <= `stationCode' & CO_station >= 101 
		}
	}
	
	* From line 3 to line 1, outbound
	foreach stationCode of local stationList3 {
		
		replace cover_307 = 1 if CI_line == 3 & CI_station <= 307 & CO_station == 119
		
		else if `stationCode' <= 306 {
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station <= `stationCode' & CO_line == 1 & CO_station >= 115
		}
		else if `stationCode' <= 305 {
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station <= `stationCode' & CO_line == 1 & CO_station >= 111
		}
		else if `stationCode' == 303 {
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station <= `stationCode' & CO_station >= 103
		}
		else if `stationCode' <= 302 {
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station <= `stationCode' & CO_station >= 102
		}
	}
	
	foreach stationCode of local stationList1 {
	
		replace cover_119 = 1 if CI_line == 3 & CI_station <= 307 & CO_station == 119
		if `stationCode' <= 115 & `stationCode' > 111 { 
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station <= 306 & CO_line == 1 & CO_station <= `stationCode' & CO_station > 111 
		}
		else if `stationCode' <= 111 & `stationCode' > 104 {
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station <= 305 & CO_line == 1 & CO_station <= `stationCode' & CO_station > 104 
		}
		
		replace cover_104 = 1 if CI_line == 3 & CI_station <= 303 & CO_line == 1 & CO_station == 104
		
		else if `stationCode' < 104 &`stationCode' >= 101 {
			replace cover_`stationCode' = 1 if CI_line == 3 & CI_station <= 302 & CO_line == 1 & CO_station <= `stationCode' & CO_station >= 101 
		}
	}
	
	* From line 2 to line 1, inbound
	foreach stationCode of local stationList2 {
		if `stationCode' >= 208 {
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station >= `stationCode' & CO_line == 1
		}
		else if `stationCode' == 207 { 
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station >= `stationCode' & CO_line == 1 & CO_station <= 115
		}
		else if `stationCode' == 206 {
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station >= `stationCode' & CO_line == 1 & CO_station <= 111
		}
		else if inlist(`stationCode',205,204,203) {
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station >= `stationCode' & CO_line == 1 & CO_station <= 104
		}
		else if `stationCode' == 202 {
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station >= `stationCode' & CO_station == 102
		}
	}
	
	foreach stationCode of local stationList1 {
		if `stationCode' > 115 {
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station >= 208 & CO_line == 1 & CO_station <= `stationCode' & CO_station > 115 
		}
		else if `stationCode' <= 115 & `stationCode' > 111 { 
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station >= 207 & CO_line == 1 & CO_station <= `stationCode' & CO_station > 111 
		}
		else if `stationCode' <= 111 & `stationCode' > 104 {
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station >= 206 & CO_line == 1 & CO_station <= `stationCode' & CO_station > 104 
		}
		
		replace cover_104 = 1 if CI_line == 2 & CI_station >= 203 & CO_line == 1 & CO_station == 104
		
		else if `stationCode' < 104 &`stationCode' >= 101 {
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station >= 202 & CO_line == 1 & CO_station <= `stationCode' & CO_station >= 101 
		}
	}
									
	* From line 2 to line 1, outbound
	foreach stationCode of local stationList2 {
		
		replace cover_208 = 1 if CI_line == 2 & CI_station <= 208 & CO_station == 119
		
		if `stationCode' <= 202 {
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station <= `stationCode' & CO_station >= 102
		}
		else if `stationCode' == 203 {
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station <= `stationCode' & CO_station >= 103
		}
		else if `stationCode' <= 206 {
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station <= `stationCode' & CO_line == 1 & CO_station >= 111
		}
		else if `stationCode' <= 207 {
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station <= `stationCode' & CO_line == 1 & CO_station >= 115
		}		
	}
	
	foreach stationCode of local stationList1 {
	
		replace cover_119 = 1 if CI_line == 2 & CI_station <= 208 & CO_station == 119
		if `stationCode' <= 115 & `stationCode' > 111 { 
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station <= 207 & CO_line == 1 & CO_station <= `stationCode' & CO_station > 111 
		}
		else if `stationCode' <= 111 & `stationCode' > 104 {
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station <= 206 & CO_line == 1 & CO_station <= `stationCode' & CO_station > 104 
		}
		
		replace cover_104 = 1 if CI_line == 2 & CI_station <= 203 & CO_line == 1 & CO_station == 104
		
		else if `stationCode' < 104 &`stationCode' >= 101 {
			replace cover_`stationCode' = 1 if CI_line == 2 & CI_station <= 202 & CO_line == 1 & CO_station <= `stationCode' & CO_station >= 101 
		}
	}
	
	* From line 1 to line 3, outbound
	foreach stationCode of local stationList1 {
		if `stationCode' <= 103 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station <= `stationCode' & CO_line == 3 & CO_station >= 302
		}

		replace cover_104 = 1 if CI_line == 1 & CI_station == 104 & CO_line == 3 & CO_station >= 303
		
		else if `stationCode' > 104 & `stationCode' <= 111 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station <= `stationCode' & CI_station > 104 & CO_line == 3 & CO_station >= 305
		}
		else if `stationCode' > 111 & `stationCode' <= 115 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station <= `stationCode' & CI_station > 111 & CO_line == 3 & CO_station >= 306
		}
		else if `stationCode' > 115 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station <= `stationCode' & CI_station > 115 & CO_line == 3 & CO_station >= 307
		}
	}
	
	replace cover_306 = 1 if CI_line == 1 & CI_station <= 119 & CO_line == 3 & CO_station >= 306
	replace cover_305 = 1 if CI_line == 1 & CI_station <= 115 & CO_line == 3 & CO_station >= 305
	replace cover_302 = 1 if CI_line == 1 & CI_station <= 104 & CO_line == 3 & CO_station >= 302
		
	foreach stationCode of local stationList3 {
		if `stationCode' >= 307 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CO_line == 3 & CO_station >= `stationCode'
		}
		else if inlist(`stationCode',304,303) {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station <= 104 & CO_line == 3 & CO_station >= `stationCode'
		}
	}
	
	* From line 1 to line 2, outbound
	foreach stationCode of local stationList1 {
		if `stationCode' <= 103 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station <= `stationCode' & CO_line == 2 & CO_station >= 202
		}

		replace cover_104 = 1 if CI_line == 1 & CI_station == 104 & CO_line == 2 & CO_station >= 203
		
		else if `stationCode' > 104 & `stationCode' <= 111 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station <= `stationCode' & CI_station > 104 & CO_line == 2 & CO_station >= 206
		}
		else if `stationCode' > 111 & `stationCode' <= 115 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station <= `stationCode' & CI_station > 111 & CO_line == 2 & CO_station >= 207
		}
		else if `stationCode' > 115 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station <= `stationCode' & CI_station > 115 & CO_line == 2 & CO_station >= 208
		}
	}
	
	replace cover_207 = 1 if CI_line == 1 & CI_station <= 119 & CO_line == 2 & CO_station >= 207
	replace cover_206 = 1 if CI_line == 1 & CI_station <= 115 & CO_line == 2 & CO_station >= 206
	replace cover_202 = 1 if CI_line == 1 & CI_station <= 104 & CO_line == 2 & CO_station >= 202
		
	foreach stationCode of local stationList2 {
		if `stationCode' >= 208 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CO_line == 2 & CO_station >= `stationCode'
		}
		else if inlist(`stationCode',205,204,203) {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station <= 104 & CO_line == 2 & CO_station >= `stationCode'
		}
	}
	
	
	* From line 1 to line 3, inbound
	
	replace cover_103 = 1 if CI_station == 103
	
	foreach stationCode of local stationList1 {
		if `stationCode' >= 115 & `stationCode' <= 119 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station >= `stationCode' & CO_line == 3 & CO_station <= 306
		}
		if `stationCode' >= 111 & `stationCode' < 115 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station >= `stationCode' & CI_station < 115 & CO_line == 3 & CO_station <= 305
		}
		if `stationCode' >= 104 & `stationCode' < 111 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station >= `stationCode' & CI_station < 111 & CO_line == 3 & CO_station <= 302
		}
	}
	
	replace cover_303 = 1 if CI_line == 1 & CI_station >= 104 & CO_line == 3 & CO_station <= 303
	replace cover_306 = 1 if CI_line == 1 & CI_station >= 115 & CO_line == 3 & CO_station <= 306
		
	foreach stationCode of local stationList3 {
		if `stationCode' <= 302 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CO_line == 3 & CO_station <= `stationCode'
		}
		else if `stationCode' <= 305 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station >= 111 & CO_line == 3 & CO_station <= `stationCode'
		}
	}
	
	* From line 1 to line 2, inbound
	
	foreach stationCode of local stationList1 {
		if `stationCode' >= 115 & `stationCode' <= 119 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station >= `stationCode' & CO_line == 2 & CO_station <= 207
		}
		if `stationCode' >= 111 & `stationCode' < 115 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station >= `stationCode' & CI_station < 115 & CO_line == 2 & CO_station <= 206
		}
		if `stationCode' >= 104 & `stationCode' < 111 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station >= `stationCode' & CI_station < 111 & CO_line == 2 & CO_station <= 202
		}
	}
	
	replace cover_203 = 1 if CI_line == 1 & CI_station >= 104 & CO_line == 2 & CO_station <= 203
	replace cover_207 = 1 if CI_line == 1 & CI_station >= 115 & CO_line == 2 & CO_station <= 206
		
	foreach stationCode of local stationList2 {
		if `stationCode' <= 202 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CO_line == 2 & CO_station <= `stationCode'
		}
		else if `stationCode' <= 206 {
			replace cover_`stationCode' = 1 if CI_line == 1 & CI_station >= 111 & CO_line == 2 & CO_station <= `stationCode'
		}
	}

	compress
	dropmiss, force
	
	save 				"${dt_int}/pooled_rider_audit_rides_coverage.dta", replace 
	iemetasave using 	"${dt_int}/pooled_rider_audit_rides_coverage.txt", replace

********************************************************************************
