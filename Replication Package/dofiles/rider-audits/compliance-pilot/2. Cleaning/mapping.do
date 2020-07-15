/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*		  	 	Clean compliance pilot platform observations		 		   *
********************************************************************************

	* REQUIRES:  	${encrypt}/Compliance pilot/02212017/Mapping 02212017
					${doc_rider}/compliance-pilot/codebooks/mapping.xlsx
					${doc_rider}/compliance-pilot/codebooks/mapping_long.xlsx
	* CREATES:		${dt_int}/compliance_pilot_mapping.dta
					${dt_int}/compliance_pilot_clean_mapping_long.dta
				  
	* WRITEN BY:   Luiza Andrade [lcardoso@worldbank.org]
	
********************************************************************************
*	Clean mapping data
********************************************************************************/

	if ${encrypted} {
	
		import 	delimited using "${encrypt}/Compliance pilot/02212017/Mapping 02212017", ///
					delim (",")  varnames(1) clear


		* Date of obsevation 
		* ------------------
		split 		created_at, p("")
		split 		created_at1, p("-")
		destring 	created_at11 created_at12 created_at13, replace
		split 		created_at2, p(":")
				
		gen double 	MA_date = mdy(created_at12, created_at13, created_at11)
		format 		MA_date 	%td
				
		* Categorical variables for congestion and compliance
		* ---------------------------------------------------
		foreach var in 	regular_ride_men_present pink_ride_men_present ///
						regular_ride_crowd pink_ride_crowd police_present ///
						time_bin {
						
			encode 	`var', gen(`var'_)
			drop	`var'
			
		}
		
		* Identify station groups
		* -------------------------
		
		rename 	line 		lineVar
		rename 	station 	stationVar
		do 		"${do}/ado/encode stations.do"
		rename	(lineCode stationCode) (line station)
		drop	lineVar stationVar
			
		gen 	station_bin = .	
		replace station_bin = 1  if station >= 101 & station <= 105
		replace station_bin = 2  if station >= 106 & station <= 110
		replace station_bin = 3  if station >= 111 & station <= 115
		replace station_bin = 4  if station >= 116 & station <= 119
		replace station_bin = 5  if station >= 201 & station <= 205
		replace station_bin = 6  if station >= 206 & station <= 211
		replace station_bin = 7  if station >= 212 & station <= 216
		replace station_bin = 8  if station >= 217 & station <= 220
		replace station_bin = 9  if station >= 221 & station <= 224
		replace station_bin = 10 if station >= 301 & station <= 306
		replace station_bin = 11 if station >= 307 & station <= 311
		replace station_bin = 12 if station >= 312 & station <= 315
		replace station_bin = 13 if station >= 316 & station <= 320
		replace station_bin = 14 if station >= 401 & station <= 405
		replace station_bin = 15 if station >= 406 & station <= 410
		replace station_bin = 16 if station >= 411 & station <= 415
		replace station_bin = 17 if station >= 416 & station <= 419
		replace station_bin = 18 if station >= 501 & station <= 505
		replace station_bin = 19 if station >= 506 & station <= 510
		replace station_bin = 20 if station >= 511 & station <= 514
		replace station_bin = 21 if station >= 515 & station <= 517
		replace station_bin = 22 if station >= 518 & station <= 520

		
		isid obs_uuid
		compress
		
		iecodebook apply using "${doc_rider}/compliance-pilot/codebooks/mapping.xlsx", drop
		
		save 			 "${dt_int}/compliance_pilot_mapping.dta", replace
		iemetasave using "${dt_int}/compliance_pilot_mapping.txt", replace
		
	}
	
********************************************************************************
*	Prepare to merge with rides
********************************************************************************/

	use "${dt_int}/compliance_pilot_mapping.dta"
	
	drop if missing(station_bin) // 54 observations deleted: these are stations that are not in our sample

	* Average compliance per bin (segment, time) -- take mid-point of the range
	* -------------------------------------------------------------------------
	gen MA_men_present_pink = pink_ride_men_present 
	gen MA_men_present_mix = regular_ride_men_present
	
	foreach varAux in  MA_men_present_pink MA_men_present_mix {
		replace `varAux' = 0.05 if `varAux' == 1
		replace `varAux' = 0.20 if `varAux' == 2
		replace `varAux' = 0.40 if `varAux' == 3
		replace `varAux' = 0.60 if `varAux' == 4
		replace `varAux' = 0.80 if `varAux' == 5
		replace `varAux' = 0.95 if `varAux' == 6
	}
		
	* Calculate mean compliance and median congestion
	* ------------------------------------------------
	collapse  	(mean) 	 MA_men_present_pink MA_men_present_mix /// 
				(median) MA_crowd_rate_mix  = regular_ride_crowd ///
						 MA_crowd_rate_pink = pink_ride_crowd,  ///
				by		(time_bin station_bin line	)
	
	foreach varAux in MA_crowd_rate_mix MA_crowd_rate_pink {
		replace `varAux' = round(`varAux')
	}
	
	gen 	stage = 1
	
	* Clean up and save
	* -----------------
	isid time_bin station_bin
	
	compress
	
	iecodebook apply using "${doc_rider}/compliance-pilot/codebooks/mapping_long.xlsx"
	
	save 			 "${dt_int}/compliance_pilot_clean_mapping_long.dta", replace
	iemetasave using "${dt_int}/compliance_pilot_clean_mapping_long.txt", replace
	
***************************************************************** End of do-file


