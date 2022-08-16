
********************************************************************************
*						PART 4: Merge IAT data
********************************************************************************

	preserve 
	
		* Merge IAT time
		use "${dt_platform_int}/iat_stimuli.dta", clear
		
		collapse (sum) time (mean) errorrate = correct, by(id version)
		replace version = lower(version)
		
		* Time: from ms to s
		replace time = time/1000 
		
		reshape wide time errorrate, i(id) j(version) string
	
		* Merge IAT scores
		* ----------------
		merge 1:1 id using "${dt_platform_int}/iat_scores.dta", assert(3) nogen
	
		tempfile iat
		save	 `iat'
		
	restore
	
	merge 1:1 id using `iat', assert(1 3) nogen
	

********************************************************************************
*						PART 5: Clean up and save
********************************************************************************

	* Fix inconsistent gender
	* -----------------------
	* From Field Team: the IAT records would be the correct ones in this case. Since
	* the questionnaires are different for men or women, the IAT enumerator 
	* would notice if they were asking the women's questionnaire to a man or
	* vice-versa. And at the platform, if the respondent accepts to take the IAT,
	* the enumerator would have only asked socioeconomic questions and wouldn't
	* be able to notice that she marked the wrong gender.
	
	replace gender_interview = 	gender_interview_iat if ///
			gender_interview != gender_interview_iat & ///
			!missing(gender_interview_iat)		
			
	* Drop variables that were only used for quality control purposes
	drop 	submissiondate starttime endtime deviceid subscriberid simid ///
			devicephonenum username caseid enumerator enumeratorname *duration ///
			random_iat key ///
			pacote phone_number phone_yesno phone_yesno_refused ///
			done* whyleave_open instanceid general_notes formdef_version ///
			id_dup random_order id_check order_data
			
	compress
	save 			 "${dt_platform_int}/merged.dta", replace
	iemetasave using "${dt_platform_int_git}/merged.txt", replace
		
************************************************************* That's all, folks!		
