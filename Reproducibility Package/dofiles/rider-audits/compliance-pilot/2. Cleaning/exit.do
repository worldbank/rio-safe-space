/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 				    	Clean compliance pilot exit survey			 	       *
********************************************************************************
			
	* REQUIRES:	   "${dt_raw}/compliance_pilot_deidentified.dta"
				   "${doc_rider}/compliance-pilot/codebooks/exit.xlsx"
	* CREATES:	   "${dt_int}/compliance_pilot_exit.dta"
				  
	* WRITEN BY:   Luiza Andrade [lcardoso@worldbank.org]

********************************************************************************
*	Load data and select variables					   
********************************************************************************/

	use 	"${dt_raw}/compliance_pilot_deidentified.dta", clear
	keep 	if entity_uuid == "b89d7008-4bc3-4d1b-9c2b-e9758afede2f"		// Select exit data
	
	* Keep only exit task vars
	* ------------------------
	keep 	user_uuid sv_usual_choice sv_preference radio* ///
			types_men_open types_women_pink types_women_mixed option* ///
			assured_male_free price_option* advantages_sv_open ///
			disadvantages_sv_open mixed_comments_rate fem_robbed_rate ///
			mixed_touch_rate mixed_robbed_rate  ///
			fem_comment_rate fem_touch_rate /// 
			percent* discover_premise govt_continue_pink why_govt_continue_pink ///
			consider_riding_pink*
	
********************************************************************************
*	Rename variables to match previous round		   	  
********************************************************************************
	
	rename		option_1 							option0
	rename		option_2 							option10
	rename		option_3 							option15
	rename		option_4 							option30
	rename		option_5 							option65
	rename		price_option_1						price_option0
	rename		price_option_2 						price_option10
	rename		price_option_3 						price_option30
	rename		price_option_4 						price_option65
	rename		price_option_5 						price_option180
	rename		radio_ride_choice_paid_1			radio_ride_choice_paid_5
	rename		radio_ride_choice_paid_2 			radio_ride_choice_paid_15
	rename		why_govt_continue_pink				continue_why
	rename		percent_comment_centralmixed_con	comments_mixed_central_consent
	rename		percent_comment_mixed_consent 		comments_mixed_consent
	rename		percent_comments_fem_consent		comments_pink_consent
	rename 		percent_femcentral_comments_cons 	comments_pink_central_consent
	rename 		percent_femcentral_touched_conse 	grope_pink_central_consent
	rename 		percent_robbed_fem_consent 			robbed_pink_consent
	rename 		percent_robbed_mixed_consent 		robbed_mixed_consent
	rename 		percent_touched_centralmixed_con 	grope_mixed_central_consent
	rename 		percent_touched_fem_consent 		grope_pink_consent
	rename 		percent_touched_mixed_consent		grope_mixed_consent
	
	
	
********************************************************************************
*	Encode variables 				 	 	   
********************************************************************************

	foreach option in a b c d e f g {
		
		gen 	consider_riding_pink_`option' = .
		replace consider_riding_pink_`option' = 1 if consider_riding_pink`option' == "'true'"
		drop 	consider_riding_pink`option'
	
	}
	
	foreach varAux of varlist *_consent {
		replace `varAux' = "0" if substr(`varAux',1,1) == "N"
		replace `varAux' = "1" if substr(`varAux',1,1) == "S"
		destring `varAux', replace
	}
	

	foreach varAux in 	sv_usual_choice sv_preference assured_male_free ///
						radio_mixed_car_often radio_pink_car_often radio_premise_ride_choice ///
						mixed_comments_rate percent_comment_mixed ///
						mixed_touch_rate percent_touched_mixed ///
						mixed_robbed_rate percent_robbed_mixed ///				
						fem_comment_rate percent_comments_fem ///
						fem_touch_rate percent_touched_fem ///
						fem_robbed_rate percent_robbed_fem ///
						percent_comment_centralmixed percent_touched_centralmixed ///
						percent_femcentral_comments percent_femcentral_touched ///
						govt_continue_pink discover_premise {
		
		if "`varAux'" == "sv_usual_choice" {
			local newVar usual_car
		}
		if "`varAux'" == "sv_preference" {
			local newVar pref_nocompl
		}
		if "`varAux'" == "radio_mixed_car_often" {
			local newVar usedmixed_prefpink
		}
		if "`varAux'" == "radio_pink_car_often" {
			local newVar usedpink_prefmixed
		}
		if "`varAux'" == "radio_premise_ride_choice" {
			local newVar pref_paidride
		}
		if "`varAux'" == "assured_male_free" {
			local newVar pref_fullcompl
		}
		if "`varAux'" == "mixed_comments_rate" {
			local newVar comments_mixed_rate
		}		
		if "`varAux'" == "percent_comment_mixed" {
			local newVar comments_mixed
		}		
		if "`varAux'" == "mixed_touch_rate" {
			local newVar grope_mixed_rate
		}
		if "`varAux'" == "percent_touched_mixed" {
			local newVar grope_mixed
		}
		if "`varAux'" == "mixed_robbed_rate" {
			local newVar robbed_mixed_rate
		}	
		if "`varAux'" == "percent_robbed_mixed" {
			local newVar robbed_mixed
		}					
		if "`varAux'" == "fem_comment_rate" {
			local newVar comments_pink_rate
		}
		if "`varAux'" == "percent_comments_fem" {
			local newVar comments_pink
		}
		if "`varAux'" == "fem_touch_rate" {
			local newVar grope_pink_rate
		}
		if "`varAux'" == "percent_touched_fem" {
			local newVar grope_pink
		}
		if "`varAux'" == "fem_robbed_rate" {
			local newVar robbed_pink_rate
		}	
		if "`varAux'" == "percent_robbed_fem" {
			local newVar robbed_pink
		}	
		if "`varAux'" == "percent_comment_centralmixed" {
			local newVar comments_mixed_central
		}
		if "`varAux'" == "percent_touched_centralmixed" {
			local newVar grope_mixed_central
		}
		if "`varAux'" == "percent_femcentral_comments" {
			local newVar comments_pink_central
		}
		if "`varAux'" == "percent_femcentral_touched" {
			local newVar grope_pink_central
		}
		if "`varAux'" == "discover_premise" {
			local newVar premise_recruit
		}
		if "`varAux'" == "govt_continue_pink" {
			local newVar continue_pink
		}
		
		local typeVar: type `varAux'
		
		if substr("`typeVar'",1,1) == "s" {
			encode `varAux', gen(`newVar')
			drop 	`varAux'
		}
		else {
			gen		`newVar' = .
			drop 	`varAux'
		}
	}

	foreach cents in 0 10 15 30 65 {
		encode 	option`cents', 			g(nocomp_pref`cents')	
		drop 	option`cents'
	}
	foreach cents in 0 10 30 65 180 {
		encode 	price_option`cents', 	g(fullcomp_pref`cents')
		drop	price_option`cents'
	} 
	foreach value in 5 15 {
		encode 	radio_ride_choice_paid_`value', 	g(paidride_pref`value')
		drop	radio_ride_choice_paid_`value'
	}
	
	* ---------------------------------------------------------------
	* Some observations used an earlier version of the questionnaire,
	* with different values. Here we correct the values for those obs
	* ---------------------------------------------------------------	
	foreach centsNew in 20 35 70 180 {
		
		if `centsNew' == 20		local centsOld = 10
		if `centsNew' == 35		local centsOld = 15
		if `centsNew' == 70		local centsOld = 30
		if `centsNew' == 180	local centsOld = 65
		
		gen nocomp_pref`centsNew' = nocomp_pref`centsOld' 	  if inlist(user_uuid, ///
															  "58d354c0-663e-46c1-8a62-be0a2b807264", ///
															  "1ab5d2e8-355d-454e-9f62-8b808a1dab3c", ///
															  "5567302f-849c-419a-9a99-ff0d014da0fb", ///
															  "22406cf0-2490-36c7-24f2-d8c7d2fb7c6e", ///
															  "395007d8-7702-4b69-959b-df9eec8b1ee2", ///
															  "06648d9c-7dfd-4ed3-91b6-781547d7e33d", ///
															  "a04c87b2-cb08-4fb1-bbed-04ba0b95b115", ///
															  "eff72f86-4d4f-4df8-848c-3a85a3e8d508") | ///
															  inlist(user_uuid, ///
															  "744967d3-b5db-496c-a646-d71bfb996fe0", ///
															  "a6c0319e-43ae-4841-a442-0444b3eef128", ///
															  "b4f56b7b-d5fd-412a-8d2b-7787852d38e4", ///
															  "9b63d787-22f7-4291-942e-70ee1854d9a7")
		replace nocomp_pref`centsOld' = .		  			  if inlist(user_uuid, ///
															  "58d354c0-663e-46c1-8a62-be0a2b807264", ///
															  "1ab5d2e8-355d-454e-9f62-8b808a1dab3c", ///
															  "5567302f-849c-419a-9a99-ff0d014da0fb", ///
															  "22406cf0-2490-36c7-24f2-d8c7d2fb7c6e", ///
															  "395007d8-7702-4b69-959b-df9eec8b1ee2", ///
															  "06648d9c-7dfd-4ed3-91b6-781547d7e33d", ///
															  "a04c87b2-cb08-4fb1-bbed-04ba0b95b115") | ///
															  inlist(user_uuid, ///
															  "eff72f86-4d4f-4df8-848c-3a85a3e8d508", ///
															  "744967d3-b5db-496c-a646-d71bfb996fe0", ///
															  "a6c0319e-43ae-4841-a442-0444b3eef128", ///
															  "b4f56b7b-d5fd-412a-8d2b-7787852d38e4", ///
															  "9b63d787-22f7-4291-942e-70ee1854d9a7")
	}
	
	foreach centsNew in 20 35 70 {
		
		if `centsNew' == 20		local centsOld = 10
		if `centsNew' == 35		local centsOld = 30
		if `centsNew' == 70		local centsOld = 65

		gen fullcomp_pref`centsNew' = fullcomp_pref`centsOld' if inlist(user_uuid, ///
															  "58d354c0-663e-46c1-8a62-be0a2b807264", ///
															  "1ab5d2e8-355d-454e-9f62-8b808a1dab3c", ///
															  "5567302f-849c-419a-9a99-ff0d014da0fb", ///
															  "22406cf0-2490-36c7-24f2-d8c7d2fb7c6e", ///
															  "395007d8-7702-4b69-959b-df9eec8b1ee2", ///
															  "06648d9c-7dfd-4ed3-91b6-781547d7e33d", ///
															  "a04c87b2-cb08-4fb1-bbed-04ba0b95b115") | ///
															  inlist(user_uuid, ///
															  "eff72f86-4d4f-4df8-848c-3a85a3e8d508", ///
															  "744967d3-b5db-496c-a646-d71bfb996fe0", ///
															  "a6c0319e-43ae-4841-a442-0444b3eef128", ///
															  "b4f56b7b-d5fd-412a-8d2b-7787852d38e4", ///
															  "9b63d787-22f7-4291-942e-70ee1854d9a7")
		replace fullcomp_pref`centsOld' = .		  		  	  if inlist(user_uuid, ///
															  "58d354c0-663e-46c1-8a62-be0a2b807264", ///
															  "1ab5d2e8-355d-454e-9f62-8b808a1dab3c", ///
															  "5567302f-849c-419a-9a99-ff0d014da0fb", ///
															  "22406cf0-2490-36c7-24f2-d8c7d2fb7c6e", ///
															  "395007d8-7702-4b69-959b-df9eec8b1ee2", ///
															  "06648d9c-7dfd-4ed3-91b6-781547d7e33d", ///
															  "a04c87b2-cb08-4fb1-bbed-04ba0b95b115") | ///
															  inlist(user_uuid, ///
															  "eff72f86-4d4f-4df8-848c-3a85a3e8d508", ///
															  "744967d3-b5db-496c-a646-d71bfb996fe0", ///
															  "a6c0319e-43ae-4841-a442-0444b3eef128", ///
															  "b4f56b7b-d5fd-412a-8d2b-7787852d38e4", ///
															  "9b63d787-22f7-4291-942e-70ee1854d9a7")
	}
			
********************************************************************************
*	Check data						   	   
********************************************************************************

	egen	consider = rowtotal(consider_riding_pink_*)
	qui 	count if consider < 1 & ///
			!inlist(user_uuid,"58d354c0-663e-46c1-8a62-be0a2b807264", ///
							  "1ab5d2e8-355d-454e-9f62-8b808a1dab3c", ///
							  "5567302f-849c-419a-9a99-ff0d014da0fb", ///
							  "22406cf0-2490-36c7-24f2-d8c7d2fb7c6e", ///
							  "395007d8-7702-4b69-959b-df9eec8b1ee2", ///
							  "06648d9c-7dfd-4ed3-91b6-781547d7e33d", ///
							  "a04c87b2-cb08-4fb1-bbed-04ba0b95b115") & ///
			!inlist(user_uuid,"eff72f86-4d4f-4df8-848c-3a85a3e8d508", ///
							  "744967d3-b5db-496c-a646-d71bfb996fe0", ///
							  "a6c0319e-43ae-4841-a442-0444b3eef128", ///
							  "b4f56b7b-d5fd-412a-8d2b-7787852d38e4", ///
							  "9b63d787-22f7-4291-942e-70ee1854d9a7")
	assert	`r(N)' == 0
	drop 	consider
	
********************************************************************************
*	Save data						   	   
********************************************************************************

	isid user_uuid
	compress 
	dropmiss, force
	
	iecodebook apply using "${doc_rider}/compliance-pilot/codebooks/exit.xlsx", drop
	
	order 	user_uuid advantage_pink disadvantage_pink ///
			pref_nocompl nocomp_pref* pref_fullcompl fullcomp_pref* pref_paidride ///
			paidride_pref* continue_pink continue_why comments* grope* robbed* ///
			consider* 
			
	save 			 "${dt_int}/compliance_pilot_exit.dta", replace
	iemetasave using "${dt_int}/compliance_pilot_exit.txt", replace
	
*************************************************************************** Done!
