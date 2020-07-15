
	use "${dt_final}/pooled_rider_audit_constructed.dta", clear
	
	keep if phase ==3
	
	tempfile rides
	save `rides'
	
	* List all users
	preserve
	
		gen 	lastday = date if phase_ride == 10	
		
		collapse group /// 
				(max) lastday /// = date
				(min) firstday = date, by(user_uuid user_id stage)
		
		drop if missing(group)
		
		unique user_uuid if stage == 1
		local stage1users = r(N)
		
		unique user_uuid if stage == 0
		local stage0users = r(N)
		
		isid user_uuid stage
		bys stage: gen id = _n
		
		tempfile users
		save 	`users'
		
	restore
	
	preserve
	
		collapse (mean) d_women_car, by(phase group stage date)

		// 118 out of 409 rides got mixed assignments:
		
		gen d_offered_women = round(d_women_car, 1)
		
		keep 			d_offered_women group stage phase date
		duplicates drop
		
		drop if missing(group) 
		
		isid group stage date
		
		tempfile offers
		save `offers' 
	
	restore
	
	* List all dates
	
	keep stage date
	duplicates drop
	isid stage date
	
	expand `stage1users' if stage == 1
	expand `stage0users' if stage == 0
	
	bys 	  stage date: gen id = _n
	merge m:1 stage id using `users', assert(3) nogen
	
	drop if date < firstday
	drop firstday id

	merge m:1 stage group date using `offers', nogen
	
	drop if missing(d_offered_women)
	
	
	merge 1:m user_uuid date using `rides', keep(1 3) nogen // 18 users that we don't know the group didn't match
	
	
	drop if d_offered_women != d_women_car & !missing(d_women_car)
	
	gen offer_taken = (d_offered_women == d_women_car) if !missing(d_offered_women)
	
	replace datetime = date*24*60*60*1000 if missing(datetime)

	bys stage user_id: egen potential_ride = rank(datetime)
	egen id = group(stage user_id)

	xtset id potential_ride

	gen lastoffer = l.d_offered_women if phase_ride != 1
	
	save 				"${dt_final}/pooled_rider_audit_phase3_offers.dta", replace
	iemetasave using	"${dt_final}/pooled_rider_audit_phase3_offers.txt", replace

***************************************************************** End of do-file	
