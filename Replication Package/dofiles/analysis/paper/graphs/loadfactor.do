/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 				Congestion in the system by time window						   *
********************************************************************************

	REQUIRES:	${dt_final}/pooled_mapping.dta
				${dt_final}/congestion_station_level.dta
	CREATES:	${out_graphs}/loadfactor.png
				
	WRITEN BY:  Luiza Andrade [lcardosodeandrad@worldbank.org]

********************************************************************************
	Prepare data
*******************************************************************************/

	use "${dt_final}/pooled_mapping.dta", clear

	collapse (mean) pct_standing*, by(time_bin)
		
	recode time_bin 	(1 = 6) (2 = 6.5) (3 = 7) (4 = 7.5) (5 = 8) (6 = 8.5) ///
						(7 = 17) (8 = 17.5)  (9 = 18) (10 = 18.5) (11 = 19) (12 = 19.5)
						
	
	tempfile mapping
	save 	`mapping'
	
	* Load administrative data from Supervia
	use "${dt_final}/congestion_station_level.dta", clear
	
	* Add time of day label (from 24 to 12 hours)
	lab def hora 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "1" 14 "2" 15 "3" 16 "4" 17 "5" 18 "6" 19 "7" 20 "8" 21 "9" 22 "10" 25 ""
	lab val hora hora
	
	* Calculte average congestino per hour
	collapse (mean) loadfact = CI_loadfact, by(hora)
		
	append using `mapping'
	
/*******************************************************************************
	Create plot
*******************************************************************************/

	twoway 	(bar  pct_standing_public time_bin ///
				  , ///
				  barwidth(.5) lcolor(${col_mixedcar}) fcolor(none)) ///
			(bar  pct_standing_reserved time_bin ///
				  , ///
				  barwidth(.5) lcolor(${col_womencar}) fcolor(none)) ///
			(line loadfact hora if hora <= 22, color(gs10) yaxis(2)) ///			Line plot: load factor
		, ///				
		xline(12, lcolor(${col_highlight}) lpattern(dot)) ///				    			Separate AM and PM
		yline(50, lcolor(${col_highlight}) lpattern(dot)) ///						Indicate high crowding
		text(51.2 19 "High crowding") ///
		text(15 11 "AM") ///
		text(15 13 "PM") ///
		${plot_options} ///
		ytitle("Percent of passengers who are standing") ///
		ytitle("Share of maximum allowed capacity", axis(2)) ///
		xtitle("Time of day") ///
		xlabel(4(1)22, valuelabel) ///
		yscale(range(0(.1).55) axis(2)) ///
		ylabel(0(.1).55, axis(2) noticks) ///
		ylabel(0(10)55, axis(1) noticks) ///
		yscale(range(0(10)55)  axis(1)) ///
		xscale(range(4(1)22)) ///
		legend(order(1 "${lab_mixedcar}" ///
					 2 "${lab_womencar}" ///
					 3 "Load factor") ///
				region(lcolor(white)) ///
				cols(3))
		
	* Save graph
	gr export "${out_graphs}/loadfactor.png", width(5000) replace
	
*============================================================= That's all, folks!
