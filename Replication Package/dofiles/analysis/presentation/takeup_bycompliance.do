

	use "${dt_rider_fin}/pooled_rider_audit_constructed.dta", clear
	
	keep if phase < 3 & d_anyphase3 == 1 				/// Keeping those who completed all the Opportunity Cost levels as we want to test differential response between levels

	xtset user_id
	
	lab var d_pos_premium "Positive"
	lab var d_zero_premium "None"
	
	gen d_lowcompliance = d_highcompliance == 0 
	lab var d_highcompliance "Low"
	lab var d_lowcompliance  "High"
	
	
	
	replace d_women_car = d_women_car * 100
	
	reg d_women_car d_zero_premium d_pos_premium, nocons cluster(user_id)
	estimates store unconditional
	
	reg d_women_car d_highcompliance d_lowcompliance [pw = weight] if premium == 0, nocons cluster(user_id)
	estimates store nopremium
	test d_highcompliance = d_lowcompliance
	local fnopremium = round(r(p),.0001)
	
	reg d_women_car d_highcompliance d_lowcompliance [pw = weight] if premium != 0 & !missing(premium), nocons cluster(user_id)
	estimates store pospremium
	test d_highcompliance = d_lowcompliance
	local fpospremium = round(r(p),.001)	

	gr drop _all
	
	coefplot 	nopremium, ///
				keep(d_highcompliance = d_lowcompliance) ///
				vertical recast(bar) barwidth(0.5) ///
				yscale(range(0(5)30)) ylab(, glcolor(gs15) labsize(5)) xlab(, noticks labsize(5)) ///
				graphregion(color(white)) ///
				color(gs12) ciopt(color(purple) recast(rcap)) citop ///
				name(nopremium) ///
				xtitle(Male presence, size(5)) ///
				ytitle(Percentage of rides on reserved space, size(5)) ///
				ylab(, noticks labsize(4) glcolor(gs15)) ///
				title(No opportunity cost, box bexpand bcolor(gs15) size(5)) ///
				text(30 1.8 "P-value = 0`fnopremium'", ///
					orient(horizontal) size(medium) justification(center))
				
	coefplot 	pospremium, ///
				keep(d_highcompliance = d_lowcompliance) ///
				vertical recast(bar) barwidth(0.5) ///
				yscale(range(0(5)30) noline) ylab(, nolab noticks glcolor(gs15) labsize(5)) xlab(, noticks labsize(5)) ///
				graphregion(color(white)) ///
				color(gs12) ciopt(color(purple) recast(rcap)) citop ///
				name(pospremium) ///
				xtitle(Male presence, size(5)) ///
				ylab(, noticks labsize(4) glcolor(gs15)) ///
				title(Positive opportunity cost, box bexpand bcolor(gs15) size(5)) ///
				text(12 1.7 "P-value = 0`fpospremium'", ///
					orient(horizontal) size(medium) justification(center))
	
	gr combine 	nopremium pospremium, ///
				ycommon cols(3) ///
				graphregion(color(white))
				
	gr export	"${out_graphs}/Presentation/takeup_bycompliance.png", width(5000) replace
