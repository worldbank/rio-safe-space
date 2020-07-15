/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*	 				Identify stations covered by each ride			 		   *
********************************************************************************

	* REQUIRES:  	${dt_final}/pooled_rider_audit_rides.dta
					${dt_final}/pooled_rider_audit_exit.dta
					${dt_raw}/baseline_raw_deidentified.dta
					${doc_rider}/pooled/codebooks/label-constructed-data.xlsx
	* CREATES:		${dt_final}/pooled_rider_audit_constructed_full.dta
					${dt_final}/pooled_rider_audit_constructed.dta

	* WRITEN BY:   	Luiza Andrade, Kate Vyborny, Astrid Zwager
	
	* OVERVIEW:		Load and merge data
					Fix users who received mixed assignments
					Construct new variables
					Recoding variables
					Keep only variables used for analysis
					Save full data set
					Save paper sample	
	
*******************************************************************************
	Load and merge data
*******************************************************************************/
	
	* Load data from rides
	use "${dt_final}/pooled_rider_audit_rides.dta", clear

	* Merge exit survey data
	merge m:1 user_uuid using "${dt_final}/pooled_rider_audit_exit.dta", assert(1 3) gen(_mergeexit) // 5,532 observations not merged : users who didn't finish all tasks

	* We're only considering female riders
	keep if user_gender == 1
	
	* Drop rides when women car is not available
	drop if missing(RI_time_bin)

	encode user_uuid, gen(user_id) // ID cannot be a string for the purpose of some commands
	
	* Extra 10 cents rides: recode as willigness to pay rides
	recode phase (4 = 2)

/*******************************************************************************
	Fix users who received mixed assignments
*******************************************************************************/
						
	preserve
	
		use "${dt_raw}/baseline_raw_deidentified.dta", clear
		gen group = substr(campaign_id, -1, 1)
		
		keep if regex(campaign_id, "hase3")
		keep user_uuid group
		
		destring group, force replace
		drop if missing(group)
		duplicates drop
		duplicates tag user_uuid, gen(dup)
		drop if dup == 1 // 18 users got mixed assignments
		
		gen phase = 3
		gen stage = 0
		
		tempfile ph3blgroup
		save `ph3blgroup'
		
	restore
	
	merge m:1 user_uuid stage phase using `ph3blgroup', update nogen keep(1 4)	
	
/*******************************************************************************
	Construct new variables
*******************************************************************************/

	/*--------------------------------
	 Dummy for completing exit survey
	--------------------------------*/		
	gen d_exit = (_mergeexit == 3)
	
	/*------------------------------
	 Dummy for having mapping data
	------------------------------*/	
	gen d_nomapping = missing(MA_men_present_mix)
	
	/*--------------------------------
	 Dummy for riding in public space
	--------------------------------*/	
	gen 	d_mixed_car = 1 - CI_women_car
		
	/*-------------------------------
	 Take up variables at user level
	--------------------------------*/	
	
	* Dummy for ever riding the women's car at a given premium level
	foreach premium in 0 5 10 20 {
		
		gen 					  takeup_`premium' = (premium == `premium' & CI_women_car == 1)
		bysort 	user_uuid: egen d_takeup_`premium' = max(takeup_`premium') 
		drop takeup_`premium'
		
	}
	
	* Dummy for ever riding women's car at baseline rides
	bys user_uuid: egen bl_takeup 	= max(CI_women_car) if phase == 1
	bys user_uuid: egen d_bl_takeup = max(bl_takeup)
	drop bl_takeup
	
	* Average take up when no opportunity cost
	bysort user_uuid: 	egen pcbaselinetakeup 	= mean(d_bl_takeup) 
	replace 				 pcbaselinetakeup 	= pcbaselinetakeup * 100 
	
	* Any take up at positive OC?
	gen    takeup510 = inlist(premium, 5, 10) & CI_women_car == 1 & !missing(premium)
	bysort user_uuid: 	egen any510takeup 		= max(takeup510)
	
	/*--------------------------
	 Opportunity cost variables
	---------------------------*/	
	gen 	d_pos_premium 	= (premium > 0 & !missing(premium))	
	gen 	d_zero_premium 	= ((d_pos_premium == 0) & !missing(d_pos_premium))
	
	/*-----------------------
	 Heterogeneity variables
	------------------------*/	
	gen 	rider_obs_crowd = 	(RI_crowd_rate > 2) if !missing(RI_crowd_rate)

	* Congestion variable is categorical: considered high crowding if category is "Very crowded"
	gen 	d_highcongestion 	= (MA_crowd_rate_mix > 3) if ! missing(MA_crowd_rate_mix) 
	
	* Compliance is continuous: high compliance means above the median
	xtile 	d_highcompliance 	= MA_men_present_pink if !missing(MA_men_present_pink), nq(2) 							
	recode 	d_highcompliance 	(1 = 1) (2 = 0) 
	
	* Perceived risk of harassment
	foreach risk in grope comments robbed {
		xtile 	d_`risk'_high = `risk'_mixed, nq(2)
		recode 	d_`risk'_high (1 = 0) (2 = 1)
	}
	
	* Crime rate
	foreach crime in allcrime violent rape theft {
		xtile 	d_`crime'_high =  CI_rate_`crime', nq(2)
		recode 	d_`crime'_high (1 = 0) (2 = 1)
	}
	
	* Interactions
	egen  	oc_compliance = group(d_pos_premium d_highcompliance)			
				
	recode 	oc_compliance	(1 = 4) (2 = 2) (3 = 3) (4 = 1)
	lab def oc_compliance	1	"$\hat\beta_{M_1}$: Positive opportunity cost \$\times\$ Few men in reserved space" 	///
							2	"$\hat\beta_{M_2}$: Zero opportunity cost \$\times\$ Few men in reserved space" 		///
							3	"$\hat\beta_{M_3}$: Positive opportunity cost \$\times\$ Many men in reserved space"	///
							4	"$\hat\beta_{M_4}$: Zero opportunity cost \$\times\$ Many men in reserved space"
	lab val oc_compliance	oc_compliance	
	
	egen 	car_compliance = group(CI_women_car d_highcompliance)	
	
	recode 	car_compliance	(1 = 4) (2 = 2) (3 = 3) (4 = 1)
	lab def car_compliance	1 	"$\hat\beta_{M_1}$: Assigned to reserved space $\times$ Few men in reserved space"	///
							2	"$\hat\beta_{M_2}$: Assigned to public space $\times$ Few men in reserved space"	///
							3	"$\hat\beta_{M_3}$: Assigned to reserved space $\times$ Many men in reserved space"	///
							4	"$\hat\beta_{M_4}$: Assigned to public space $\times$ Many men in reserved space"
	lab val car_compliance	car_compliance

				
	/*-----------------------------
	 Demographic variables dummies
	------------------------------*/	
	
	* Create variables
	gen 	d_lowed 	= (user_ed < 3) 				if !missing(user_ed)
	gen 	d_young 	= (user_age == 1) 				if !missing(user_age)
	gen 	d_single 	= (user_marital == 3) 			if !missing(user_marital)
	gen 	d_employed 	= inlist(user_employment, 3, 4) if !missing(user_employment)
	gen 	d_highses 	= (user_ses < 3) 				if !missing(user_ses)

	* If only answered demographic survey in one round, carry it over to the next
	preserve
		
		keep if stage == 0
		keep ${demographics} user_uuid
		duplicates drop
		
		tempfile  demo_bl
		save	 `demo_bl'
		
	restore
	
		preserve
		
		keep if stage == 1
		keep ${demographics} user_uuid
		duplicates drop
		
		tempfile  pilot_bl
		save	 `pilot_bl'
		
	restore
	
	merge m:1 user_uuid using `demo_bl',  update nogen
	merge m:1 user_uuid using `pilot_bl', update nogen
	
	/*-----------------------------------
	 Ride direction vs traffic direction
	------------------------------------*/
	gen 	d_against_traffic = 0 if !missing(CI_direction)
	replace d_against_traffic = 1 if CI_direction == 1 & RI_hour <= 12 // outbound in the morning
	replace d_against_traffic = 1 if CI_direction == 0 & RI_hour >  12 // inbound in the evening

		
	/*--------------------------------------
	 Categorical variable for premium level
	(To make regressions easier, since we're 
	not using it as a continuous variable)
	----------------------------------------*/
	recode 	premium 	(0 = 1) ///
						(5 = 2) ///
						(10 = 3) ///
						(20 = 4), ///
						gen(premium_cat) 
						
	replace premium_cat = . if !inlist(premium_cat, 1, 2 ,3, 4)
	replace premium_cat = 1 if missing(premium_cat) & phase == 3
		
	/*-----------------------------------------------------------------
	 Dummy for suffering at least one type of harassment during a ride
	------------------------------------------------------------------*/
	
	egen 	d_harassment = anymatch(CO_touch CO_comments CO_stare), v(1)
	replace d_harassment = . if missing(CO_touch)
	replace d_harassment = . if missing(CO_touch)
	
	gen 	CI_time_AM =  CI_hour 		* 60 + CI_min if (CI_hour <= 12 & !missing(CI_hour))
	gen 	CI_time_PM = (CI_hour - 12) * 60 + CI_min if (CI_hour > 12  & !missing(CI_hour))

	
	gen 	CI_wait_time_min = RI_time - CI_time
	replace CI_wait_time_min = CI_wait_time_min/60000
	replace CI_wait_time_min = . 						if CI_wait_time_min < 0 
	replace CI_wait_time_min = . 						if CI_wait_time_min > 60 // Wait times > 1 hour appear to be errors 
	
	/*-------------------------------------
	 Change values of well being variables
	-------------------------------------*/

	foreach var of global wellbeing {
	
		local wellbeing_type = substr("`var'", 4, .)
		
		xtile 	`wellbeing_type'_high = `var', nq(2) 				// Divide in two quantiles : high and low
		replace `wellbeing_type'_high = `wellbeing_type'_high - 1 	// Turn into 0/1, with 1 being high
				
	}
	
	/*----------------------------------------------------
	 Create participation variables to identify attriters
	-----------------------------------------------------*/
	
	* Identify riders who completed the study:  more than 10 rides in the last phase
	bys user_id phase: 		gen n_rides = _N									// Number of rides
	gen phase3completer 	=  (n_rides >= 10 & !missing(n_rides) & phase == 3) // Dummy for at least 10 rides in that phase
	bys user_uuid: 			egen d_completer = max(phase3completer)				// Carrying over for all phases
	
		
	* By phase	
	forvalues phase = 1/3 {
		gen d_phase`phase' = (phase == `phase')
		
		bys user_uuid: 		 egen d_anyphase`phase' 		= max(d_phase`phase')
		bys user_uuid phase: egen d_anyphase`phase'_instage = max(d_anyphase`phase')
	}	

	* Number of baseline rides
	bysort user_uuid: 	egen baselinerides 		= total(d_phase1)
	
	* Number of rides at 5 or 10 cents premium
	gen 					 fiveten 			= inlist(premium, 5, 10) & !missing(premium)
	bysort user_uuid: 	egen fivetenrides 		= total(fiveten)
	
	/*-----------------------------------------------
	 Identify riders who participated in both stages
	------------------------------------------------*/
	
	preserve
	
		keep 	user_id stage
		
		duplicates drop
		
		bys 	user_id: gen n_stages = _N
		
		tempfile  n_stages
		save	 `n_stages'
		
	restore
	
	merge m:1 user_id stage using `n_stages', assert(3) nogen
	
	/*-----------------------------------------------
	 Difference in presence of men between cars
	------------------------------------------------*/
	gen 	MA_compliance_diff 		 	= (MA_men_present_mix - MA_men_present_pink) * 100
	xtile	MA_compliance_diff_quint 	= MA_compliance_diff, nq(5)
	gen 	pink_compliance_diff_quint 	= CI_women_car * MA_compliance_diff_quint	
	
	

/*******************************************************************************
	Recoding variables
*******************************************************************************/
	
	* Education: categories turn into years of education
	recode  user_ed 	(0 = 12) ///
						(1 = 9)  ///
						(2 = 16) ///
						(3 = 12) ///
						(4 = 19), ///
			gen(educ_year)
			
	recode 	user_age	(1 = 21)   ///
						(2 = 27.5) ///
						(2 = 27.5) ///
						(3 = 35)   ///
						(4 = 45)   ///
						(5 = 55)   ///
						(6 = 65), ///
			gen(age_year)
						
	* Car choice: turn into probability of using pink car 
	foreach var of varlist usual_car {
		gen 	`var'_cont = `var'
		recode 	`var'_cont	 (1 = 1)   /// Always reserved space
							 (2 = .75) /// Mostly reserved space
							 (3 = .5)  /// 50/50
							 (4 = .25) /// Mostly public space
							 (5 = 0)   //  Always public space
	}
	
	foreach var of varlist *comp_* {
		
		* Rename to be consistent with platform survey
		local 	newName = subinstr("`var'", "pref", "", .)
		rename  `var' `newName'
		
		* Now repcde
		gen 	`newName'_cont = `newName'
		recode 	`newName'_cont	(1 = 0) 	/// Always public space
								(2 = .25)  /// Mostly public space
								(3 = .5) 	/// 50/50
								(4 = .75) 	/// Mostly reserved space
								(5 = 1)
	}
	
	
/*******************************************************************************
	Keep only variables used for analysis
*******************************************************************************/	

	iecodebook apply using "${doc_rider}/pooled/codebooks/label-constructed-data.xlsx", drop
	
/*******************************************************************************
	Save full data set
*******************************************************************************/

	compress
	order 	user_uuid session
	
	save 			  "${dt_final}/pooled_rider_audit_constructed_full.dta", replace
	iemetasave  using "${dt_final}/pooled_rider_audit_constructed_full.txt", replace
	
/*******************************************************************************
	Save paper sample
*******************************************************************************/
		
	/*-----------------------------------------------
	  Keep only final sample
	------------------------------------------------*/	
	
	* Drop users who didn't move on to phase 2
	drop if d_anyphase2 == 0
	
	* Remove randomized car assignment rides that had positive premium: this was an app mistake
	drop if premium_cat == 3 & phase == 3
	
	* Drop observations that got mixed assignments due to app issues
	drop if inlist(phase, 1, 2) & missing(premium_cat)	
	drop if 	   user_uuid == "26e54dba-974a-46db-bd52-8c5b76ffca2a"
	drop if inlist(user_uuid, "f7aec218-3cd1-407c-a9c4-3ceef74b15da", ///
							  "f049a022-a1b8-44b5-a1be-014039ea22cf", ///
							  "e2e3091b-de98-43e0-aaa2-8507fd2cf0fa") ///
					& phase == 3 
	/*-----------------------------------------------
	  Create weight variables
	------------------------------------------------*/

	bysort 	user_uuid premium: gen phaseobs = _N
	gen 	weight = 1 / phaseobs
	
	gen 	phasegroup = phase
	replace phasegroup = 1 if phase==2 
	bysort 	user_uuid phasegroup: gen phasegroupobs = _N
	gen 	weightfe = 1 / phasegroupobs
	
	drop phasegroup phasegroupobs phaseobs
						
	/*-----------------------------------------------
	   Time series variables for event study
	------------------------------------------------*/
	
	gen 	datetime = clock(RI_started, "YMD hms")
	format 	datetime %tcNN/DD/CCYY_HH:MM:SS
	replace datetime = datetime + 3600000 if session == "455a6c80_session_64a3d8dde7ebd4d" // break tie due to imprecision of clock function
 
	bys 	user_uuid			  : egen ride 	    = rank(datetime)
	bys 	user_uuid stage phase : egen phase_ride = rank(datetime)
		
	gen event = ride if phase_ride == 1 & phase == 2
	
	bys user_id stage: egen event_ride = mean(event) if phase != 3
	replace event_ride = ride - event_ride + 100 // categorical variables must be non-negative
	gen d_post = event_ride > 99 if ride >= 99	// 0 = last 0 OC ride
	
		
	drop phase_ride event RI_started datetime
	
	
/*------------------------------------------------------------------------------
* We want to align the premia and use only the last 10 rides for each level,
* because that's the number of rides that should have been taken. Only a few
* riders took more than 10 rides
------------------------------------------------------------------------------*/

	preserve
	
		keep if phase != 3
		
		* Order rides within premium level
		bys user_id phase premium: egen premium_ride = rank(ride)
		
		* Now we will identify the first ride at each premium level within the
		* whole ride sequencing, 
		gen first_premium_ride = ride if premium == 20 & premium_ride == 1
		bys user_id: egen firstpremiumride = max(first_premium_ride)
		gen premiumride = ride - firstpremiumride if premium == 0
		
		gen first_five_ride = ride if premium == 5 & premium_ride == 1
		bys user_id: egen firstfiveride = max(first_five_ride)
		replace premiumride = ride - firstfiveride if premium == 20
		
		gen first_ten_ride = ride if premium == 10 & premium_ride == 1
		bys user_id: egen firsttenride = max(first_ten_ride)
		replace premiumride = ride - firsttenride if premium == 5
		
		bys user_id: egen lastride = max(ride) if premium == 10
		
		sort user_id ride
		replace premiumride = ride - lastride if premium == 10
		
		drop if premiumride < -10 | premiumride > 0
		drop premium_ride
		bys user_id phase premium: egen premium_ride = rank(ride)
		
		replace premium_ride = premium_ride + 10 if premium == 20
		replace premium_ride = premium_ride + 20 if premium == 5
		replace premium_ride = premium_ride + 30 if premium == 10
		drop if premium_ride == 41

		tempfile eventstudy_bypremium
		save	`eventstudy_bypremium'
		
	restore
	
	merge 1:1 session using `eventstudy_bypremium', keepusing(premium_ride) assert(1 3) nogen

	/*-----------------------------------------------
	 Clean up and save
	------------------------------------------------*/

	xtset 				user_id ride
	
	sort 				user_id ride	
	order 	user_uuid 	user_id ride session stage n_stages phase premium premium_cat d_pos_premium	///
			d_return_rider d_anyphase2 d_anyphase3 d_exit ///
			ride_frequency 	educ_year age_year ///
			top_car d_women_car d_mixed_car ///
			CI_line CI_time_AM CI_time_PM CI_wait_time_min ///
			RI_spot RI_men_present rider_obs_crowd ///
			CO_switch ///
			d_verbal_har d_staring d_physical_har d_harassment ///
			comments_mixed_cont comments_pink_cont ///
			grope_mixed_cont grope_pink_cont ///
			advantage_pink_0 advantage_pink_1 advantage_pink_2 advantage_pink_3 advantage_pink_4 advantage_pink_5 ///
			load_factor home_rate_allcrime home_rate_violent home_rate_theft ///
			d_lowed d_young d_single d_employed d_highses /// demographic controls
			pcbaselinetakeup any510takeup baselinerides fivetenrides /// attrition vars
			d_highcongestion d_highcompliance d_against_traffic /// ride conditions
			d_grope_high d_comments_high d_robbed_high ///
			concern_high feel_level_high happy_high sad_high tense_high ///
			relaxed_high frustrated_high satisfied_high feel_compare_high ///
			oc_compliance car_compliance  ///
			MA_men_present_pink MA_men_present_mix MA_compliance_diff ///
			MA_compliance_diff_quint pink_compliance_diff_quint ///
			usual_car_cont nocomp_20 nocomp_30_cont nocomp_65_cont fullcomp_30_cont fullcomp_65_cont ///
			event_ride premium_ride d_post ///
			weight weightfe flag_nomapping flag_nodemovars 
			
			
	lab var d_post 			"Ride happened after introduction of opportunity cost"
	lab val d_post			yesno
	
	lab var event_ride		"Ride order in event study"
	lab var premium_ride	"Ride order within opportunity cost"
	lab var weight			"Sampling weight"
	lab var weightfe		"Sampling weight within opportunity cost"
	
	label data "Rider audits | ID variable: 'session'"
		
	iecodebook export 	using	"${doc_rider}/pooled/codebooks/rider-audits-constructed.xlsx", replace 
	
	save 				"${dt_final}/rider-audits-constructed.dta", replace
	iemetasave using 	"${dt_final}/rider-audits-constructed.txt", replace

***************************************************************** End of do-file
