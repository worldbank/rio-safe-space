/*******************************************************************************
	Prepare data
*******************************************************************************/

	use "${dt_rider_fin}/pooled_mapping.dta", clear

	collapse (mean) pct_standing_public pct_standing_reserved, by(time_bin)
			
	recode time_bin 	(1 = 6) (2 = 6.5) (3 = 7) (4 = 7.5) (5 = 8) (6 = 8.5) ///
						(7 = 17) (8 = 17.5)  (9 = 18) (10 = 18.5) (11 = 19) (12 = 19.5)
						
	
	tempfile mapping
	save 	`mapping'
	
	* Load administrative data from Supervia
	use "${dt_rider_int}/congestion_station_level.dta", clear
	
	* Add time of day label (from 24 to 12 hours)
	lab def hora 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "1" 14 "2" 15 "3" 16 "4" 17 "5" 18 "6" 19 "7" 20 "8" 21 "9" 22 "10" 25 ""
	lab val hora hora
	
	* Calculte average congestino per hour
	collapse (mean) CI_loadfact, by(hora)
		
	append using `mapping'
	
/*******************************************************************************
	Create plot
*******************************************************************************/

	twoway 	(bar  pct_standing_reserved time_bin, ///
				barwidth(.5) lcolor(${col_womencar}) fcolor(none)) ///
			(bar  pct_standing_public time_bin, ///
				barwidth(.5) lcolor(${col_mixedcar}) fcolor(none)) ///
			(line CI_loadfact hora if hora <= 22, color(gs10) yaxis(2)), ///				Line plot: load factor
		xline(12, lcolor(${col_highlight}) lpattern(dot)) ///				    			Separate AM and PM
		yline(50, lcolor(${col_highlight}) lpattern(dot)) ///						Indicate high crowding
		text(51.2 19 "High crowding", size(small)) ///
		text(15 11 "AM") ///
		text(15 13 "PM") ///
		${plot_options} ///
		ytitle("Percent of passengers in the space who are standing", size(3)) ///
		ytitle("Share of maximum allowed capacity", axis(2) size(3)) ///
		xtitle("Time of day", size(3)) ///
		xlabel(4(1)22, valuelabel labsize(3)) ///
		yscale(range(0(.1).55) axis(2)) ///
		ylabel(0(.1).55, axis(2) noticks labsize(3)) ///
		ylabel(0(10)55, axis(1) noticks labsize(3)) ///
		yscale(range(0(10)55)  axis(1)) ///
		xscale(range(4(1)22)) ///
		legend(order(1 "${lab_womencar}" ///
					 2 "${lab_mixedcar}" ///
					 3 "Load factor") ///
				region(lcolor(white)) ///
				cols(3))
		
	* Save graph
	gr export "${out_graphs}/loadfactor.png", width(5000) replace

***************************************************************** End of do-file 
