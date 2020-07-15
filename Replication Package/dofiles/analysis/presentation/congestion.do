
	use "${dt_rider_fin}/pooled_rider_audit_rides.dta", clear


	lab def time 	1  "6-6:30" ///
					2  "6:30-7" ///
					3  "7-7:30" ///
					4  "7:30-8" ///
					5  "8-8:30" ///
					6  "8:30-9" ///
					7  "5-5:30" ///
					8  "5:30-6" ///
					9  "6-6:30" ///
					10 "6:30-7" ///
					11 "7-7:30" ///
					12 "7:30-8", replace

	recode MA_crowd_rate* (1 = 100) (2 = 75) (3 = 50) (4 = 10)

	collapse (mean) MA_crowd_rate_pink MA_crowd_rate_mix, ///
				by(RI_time_bin)

	gr drop _all 
	twoway 	bar MA_crowd_rate_mix RI_time_bin if RI_time_bin <= 6, ///
			xlab(, valuelabel noticks) yscale(range(45(5)70)) color(gs12) graphregion(color(white)) ///
			ylab(, glcolor(gs15)) ytitle(Passangers seated (%)) xtitle("") name(mixam) ///
			title(Mixed car: AM, box bexpand bcolor(gs15))

	twoway 	bar MA_crowd_rate_mix RI_time_bin if RI_time_bin > 6, ///
			xlab(, valuelabel noticks) yscale(range(45(5)70)) color(gs12) graphregion(color(white)) ///
			ylab(, glcolor(gs15)) ytitle(Passangers seated (%)) xtitle("") name(mixpm) ///
			title(Mixed car: PM, box bexpand bcolor(gs15))

	twoway 	bar MA_crowd_rate_pink RI_time_bin if RI_time_bin <= 6, ///
			xlab(, valuelabel noticks) yscale(noline range(45(5)70)) color(pink) graphregion(color(white)) ///
			ylab(, glcolor(gs15) nolab noticks) ytitle("") xtitle("") name(pinkam) ///
			title(Women's car: AM, box bexpand bcolor(gs15))

	twoway 	bar MA_crowd_rate_pink RI_time_bin if RI_time_bin > 6, ///
			xlab(, valuelabel noticks) yscale(noline range(45(5)70)) color(pink) graphregion(color(white)) ///
			ylab(, glcolor(gs15) nolab noticks) ytitle("") xtitle("") name(pinkpm) ///
			title(Women's car: PM, box bexpand bcolor(gs15))


	gr combine mixam pinkam mixpm  pinkpm, cols(2) ycommon

	gr export "$dropbox/Presentations/IDRC workshop/Plots/congestion.png", width(5000) replace
