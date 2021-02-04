/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*				 Transform congestion data to station level			 	 	   *
********************************************************************************

	REQUIRES:	${dt_int}/congestion_station_level.dta
	CREATES:	${dt_int}/congestion_ride_level.dta
	WRITEN BY:  Luiza Andrade [lcardoso@worldbank.org]
	
********************************************************************************
*								PART 0:  Open data							   *
********************************************************************************/
	
	use 	"${dt_int}/congestion_station_level.dta", clear
	
	* Keep variables we're using
	keep 	hora month_merge year CI_direction CI_line CI_station ///
			CI_loadfact lengthkm timemin
	
	
********************************************************************************
*						PART 1:  Generate ride level var					   *
********************************************************************************

	qui levelsof CI_station, local(stations)
	
	* Aggregate variables per trip for each possible trip in a same line: 
	* create average congestion, total distance and total duration
	* ------------------------------------------------------------
	
	foreach varAux in lengthkm timemin loadfact {
	
		* Create final variable
		foreach station of local stations {
			gen RI_`varAux'`station' = .
		}
	
		* Loop through possible station combinations
		foreach station1 of local stations {
			foreach station2 of local stations {
			
				* Create variable if traveling inbound
				if floor(`station1'/100) == floor(`station2'/100) & `station1' > `station2' {
				
					if "`varAux'" == "loadfact" {
					
						* Get average over ride segment
						bys year month_merge hora: egen RI_loadfact_`station1'_`station2'_0 = mean(CI_loadfact) if CI_station <= `station1' & CI_station > `station2' & CI_direction == 0
						
						* Keep observation only for the check-in station
						replace RI_loadfact_`station1'_`station2'_0 = . if CI_station != `station1'
						
						* Round numbers
						replace RI_loadfact_`station1'_`station2'_0 = round(RI_loadfact_`station1'_`station2'_0,.001)
					
					}
					else {
					
						* Get sum over ride segment
						bys year month_merge hora: egen RI_`varAux'_`station1'_`station2'_0 = sum(`varAux') if CI_station <= `station1' & CI_station > `station2' & CI_direction == 0
						
						* Keep observation only for the check-in station
						replace RI_`varAux'_`station1'_`station2'_0 = . if CI_station != `station1'
					}		
				}
				
				* Create variable if traveling outbound
				if floor(`station1'/100) == floor(`station2'/100) & `station1' < `station2' {
				
					if "`varAux'" == "loadfact" {
						
						* Get average over ride segment
						bys year month_merge hora: egen RI_loadfact_`station1'_`station2'_1 = mean(CI_loadfact) if CI_station >= `station1' & CI_station < `station2' & CI_direction == 1
						
						* Keep observation only for the check-in station
						replace RI_loadfact_`station1'_`station2'_1 = . if CI_station != `station1'
						
						* Round numbers
						replace RI_loadfact_`station1'_`station2'_1 = round(RI_loadfact_`station1'_`station2'_1,.001)
						
					}
					else {
					
						* Get sum over ride segment
						bys year month_merge hora: egen RI_`varAux'_`station1'_`station2'_1 = sum(`varAux') if CI_station >= `station1' & CI_station < `station2' & CI_direction == 1
						
						* Keep observation only for the check-in station
						replace RI_`varAux'_`station1'_`station2'_1 = . if CI_station != `station1'
					}
				}
					
				* Save both directions in the final variable
				if floor(`station1'/100) == floor(`station2'/100) {
				
					* If inbound
					if `station1' > `station2' {
						replace RI_`varAux'`station2' = RI_`varAux'_`station1'_`station2'_0 if CI_station == `station1' & CI_direction == 0
						drop RI_`varAux'_`station1'_`station2'_0
					}
					* If outbound
					else if `station1' < `station2' {
						replace RI_`varAux'`station2' = RI_`varAux'_`station1'_`station2'_1 if CI_station == `station1' & CI_direction == 1
						drop RI_`varAux'_`station1'_`station2'_1
					}
				
				}
			}
		}
	}
	

********************************************************************************
*							PART 2:  Reshape dataset						   *
********************************************************************************

	* Each observations is now a combination of check-in and check-out station
	reshape long RI_loadfact@ RI_lengthkm@ RI_timemin@, ///
			i(hora month_merge year CI_direction CI_station) j(CO_station)
	
	* Drop null stations combinations
	drop if RI_loadfact ==. & RI_lengthkm == . &  RI_timemin == .
	
	
********************************************************************************
*							PART 3:  Save dataset						   	   *
********************************************************************************	
	
	save 				"${dt_int}/congestion_ride_level.dta", replace
	iemetasave 	using 	"${dt_int}/congestion_ride_level.txt", replace
	
********************************************************************************	
