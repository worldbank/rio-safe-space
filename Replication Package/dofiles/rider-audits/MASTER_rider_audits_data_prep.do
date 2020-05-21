
/*******************************************************************************
	First wave of data collection
*******************************************************************************/
	
	/************************************************************************
	*	 Import and de-identify baseline data			 		   			*
	*************************************************************************
	* REQUIRES:		${encrypt}/Baseline/07112016/Contributions 07112016
	*				${doc_rider}/baseline-study/codebooks/raw.xlsx
	*				${doc_rider}/baseline-study/codebooks/raw_deidentify.xlsx
	* CREATES:		${encrypt}/baseline_raw.dta
	*				${dt_raw}/baseline_raw_deidentified.dta
	************************************************************************/			
	if ${encrypted} do "${do}/rider-audits/baseline/1. Import raw.do" 
	
	/************************************************************************
	*			   Clean baseline demographic survey			 		    *
	*************************************************************************
	* REQUIRES:		${dt_raw}/baseline_raw_deidentified.dta
	*				${doc_rider}/baseline-study/codebooks/demo.xlsx
	* CREATES:		${dt_int}/baseline_demographic.dta
	************************************************************************/
	do "${do}/rider-audits/baseline/2. Cleaning/demo.do" 
	
	/************************************************************************
	*   				   Clean baseline survey check-in task		 	    *
	*************************************************************************
	* REQUIRES:		${dt_raw}\baseline_raw_deidentified.dta
	*				${doc_rider}/baseline-study/codebooks/check_in.xlsx
	* CREATES:	  	${dt_int}\baseline_ci.dta
	************************************************************************/
	do "${do}/rider-audits/baseline/2. Cleaning/check-in.do" 
	
	/************************************************************************
	*			   Clean baseline survey check-out task				  	    *
	*************************************************************************
	* REQUIRES:		${dt_raw}/baseline_raw_deidentified.dta
	*				${doc_rider}/baseline-study/codebooks/check_out.xlsx																		
	* CREATES:	  	${dt_int}/baseline_co.dta
	************************************************************************/
	do "${do}/rider-audits/baseline/2. Cleaning/check-out.do" 
	
	/************************************************************************
	* 			    Clean baseline survey ride task				  	   	    *
	*************************************************************************	
	* REQUIRES:		${dt_raw}/baseline_raw_deidentified.dta
	*				${doc_rider}/baseline-study/codebooks/ride.xlsx
	* CREATES:	  	${dt_int}/baseline_ride
	************************************************************************/
	do "${do}/rider-audits/baseline/2. Cleaning/ride.do" 
	
	/************************************************************************
	* 		       Clean baseline exit survey				  	   	   		*
	*************************************************************************
	* REQUIRES:	  	${dt_raw}/baseline_raw_deidentified.dta
	*			  	${doc_rider}/baseline-study/codebooks/exit.xlsx
	* CREATES:	  	${dt_int}/baseline_exit.dta
	************************************************************************/
	do "${do}/rider-audits/baseline/2. Cleaning/exit.do" 
	
	/************************************************************************
	* 			  	 	Clean baseline platform observations			 	*
	*************************************************************************
	* REQUIRES:		${encrypt}/Baseline/07112016/Mapping 07112016
	*				${encrypt}/Baseline/mapping_task_key
	*				${doc_rider}/baseline-study/codebooks/mapping.xlsx
	*				${doc_rider}/baseline-study/codebooks/mapping_long.xlsx																		
	* CREATES:	 	${dt_int}/baseline_mapping.dta
	*				${dt_int}/baseline_mapping_long.dta
	************************************************************************/
	do "${do}/rider-audits/baseline/2. Cleaning/mapping.do" 

	/***********************************************************************
	* Merge tasks						 			 					   *
	************************************************************************		
	* REQUIRES:		${dt_int}/baseline_ci.dta
	*				${dt_int}/baseline_ride.dta
	*				${dt_int}/baseline_co.dta
	*				${dt_int}/baseline_demographic.dta
	*				${dt_int}/baseline_exit.dta
	*				${dt_int}/baseline_mapping_long.dta
	*				${doc_rider}/baseline-study/codebooks/merged.xlsx
	* CREATES:		${dt_int}/baseline_merged.dta
	***********************************************************************/
	do "${do}/rider-audits/baseline/3. Merge.do" 
	
/*******************************************************************************
	Second wave of data collection
*******************************************************************************/

	/***********************************************************************
	*		 Import and de-identify compliance pilot data			 	   *
	***********************************************************************/
	* REQUIRES:	${encrypt}/Compliance pilot/02212017/Contributions 02212017.csv"
	*			${doc_rider}/compliance-pilot/codebooks/raw.xlsx"
	* CREATES:	${encrypt}/compliance_pilot_raw.dta"
	*			${dt_raw}/compliance_pilot_deidentified.dta"
	***********************************************************************/	
	if ${encrypted} do "${do}/rider-audits/compliance-pilot/1. Import raw.do" 
	
	/***********************************************************************
	*		Clean compliance pilot demographic survey task			 	   *
	************************************************************************
	* REQUIRES:		${dt_raw}/compliance_pilot_deidentified_corrected.dta
	*				${doc_rider}/compliance-pilot/codebooks/demo.xlsx
	* CREATES:		${dt_int}/compliance_pilot_demographic.dta	
	***********************************************************************/
	do "${do}/rider-audits/compliance-pilot/2. Cleaning/demo.do" 
	
	/***********************************************************************
	*		 Clean compliance pilot check-in survey task			 	   *
	************************************************************************
	* REQUIRES:		${dt_raw}/compliance_pilot_deidentified.dta
	* 				${doc_rider}/compliance-pilot/codebooks/check_in.xlsx
	* CREATES:		${dt_int}/compliance_pilot_ci.dta
	***********************************************************************/
	do "${do}/rider-audits/compliance-pilot/2. Cleaning/check-in.do" 
	
	/***********************************************************************
	* 		   Clean compliance pilot check-out survey task		 	       *
	*************************************************************************
	* REQUIRES:		${dt_raw}/compliance_pilot_deidentified.dta
	*				${doc_rider}/compliance-pilot/codebooks/check_out.xlsx
	* CREATES:		${dt_int}/compliance_pilot_co.dta
	***********************************************************************/

	do "${do}/rider-audits/compliance-pilot/2. Cleaning/check-out.do" 
	
	/***********************************************************************
	*		    Clean compliance pilot ride survey task			 	       *
	************************************************************************
	* REQUIRES:		${dt_raw}/compliance_pilot_deidentified.dta
	*				${doc_rider}/compliance-pilot/codebooks/ride.xlsx
	* CREATES:		${dt_int}/compliance_pilot_ride.dta
	***********************************************************************/
	do "${do}/rider-audits/compliance-pilot/2. Cleaning/ride.do" 

	/***********************************************************************
	* 		    	Clean compliance pilot exit survey			 	       *
	*************************************************************************		
	* REQUIRES:	   ${dt_raw}/compliance_pilot_deidentified.dta
	*			   ${doc_rider}/compliance-pilot/codebooks/exit.xlsx
	* CREATES:	   ${dt_int}/compliance_pilot_exit.dta
	***********************************************************************/
	do "${do}/rider-audits/compliance-pilot/2. Cleaning/exit.do" 
	
	/***********************************************************************
	*	  	 	Clean compliance pilot platform observations		 	   *
	************************************************************************
	* REQUIRES:  	${encrypt}/Compliance pilot/02212017/Mapping 02212017
	*				${doc_rider}/compliance-pilot/codebooks/mapping.xlsx
	*				${doc_rider}/compliance-pilot/codebooks/mapping_long.xlsx
	* CREATES:		${dt_int}/compliance_pilot_mapping.dta
	*				${dt_int}/compliance_pilot_clean_mapping_long.dta
	***********************************************************************/
	do "${do}/rider-audits/compliance-pilot/2. Cleaning/mapping.do" 
	
	/***********************************************************************
	* 				 Merge compliance pilot ride tasks				 	   *
	************************************************************************
	* REQUIRES:		${dt_int}/compliance_pilot_ci.dta
	*				${dt_int}/compliance_pilot_ride.dta
	*				${dt_int}/compliance_pilot_co.dta
	*				${dt_int}/compliance_pilot_demographic.dta
	*				${dt_int}/compliance_pilot_clean_mapping_long.dta
	*				${doc_rider}/compliance-pilot/codebooks/merged.xlsx	
	* CREATES:		${dt_int}/compliance_pilot_merged.dta
	***********************************************************************/
	do "${do}/rider-audits/compliance-pilot/3. Merge.do" 
	
/*******************************************************************************
	Merge waves
*******************************************************************************/

	/***********************************************************************
	*	  Append baseline and pilot exit surveys			 			   *
	************************************************************************
	* REQUIRES: 	${dt_int}/compliance_pilot_exit
	*				${dt_int}/baseline_exit
	*				${doc_rider}/pooled/pooled_exit.xlsx						  
	* CREATES:		${dt_int}/pooled_rider_audit_exit.dta 	 
	***********************************************************************/
	do "${do}/rider-audits/pooled/pool_exit.do" 
	
	/***********************************************************************
	*    Append baseline and pilot platoform observations surveys		   *
	************************************************************************
	* REQUIRES: 	${dt_rider_int}/baseline_mapping.dta
	* 		    	${dt_rider_int}/compliance_pilot_mapping.dta
	* CREATES:  	${dt_rider_fin}/pooled_mapping.dta
	***********************************************************************/	
	do "${do}/rider-audits/pooled/pool_mapping.do" 
	
	/***********************************************************************
	*			 Append baseline and pilot rides				 		   *
	************************************************************************
	* REQUIRES:  	${dt_int}/compliance_pilot_merged
	*				${dt_int}/baseline_merged
	*				${doc_rider}/pooled/codebooks/pooled_rides.xlsx
	* CREATES:		${dt_int}/pooled_rider_audit_rides.dta
	***********************************************************************/	
	do "${do}/rider-audits/pooled/pool_rides.do" 
	
************************************************************************ The end.