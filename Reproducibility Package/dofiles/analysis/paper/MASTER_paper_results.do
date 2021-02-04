* Main figures =================================================================

	****************************************************************************
	* Figure 2: Rides sequence and take-up of reserved space			   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   	   *
	*	CREATES: ${out_graphs}/Paper/eventstudy_bypremium.png			   	   *
	****************************************************************************

	do "${do_graphs}/eventstudy_bypremium.do"	
	
	****************************************************************************
	* Figure 3: Take-up of reserved space by opportunity cost			   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   	   *
	*	CREATES:  ${out_graphs}/takeup_fe.png							   	   *
	*			  ${out_graphs}/takeup_person.png						   	   *
	****************************************************************************

	do "${do_graphs}/takeup.do"
	
	****************************************************************************
	* Figure 4: Joint distribution of takeup and harassment by presence of men *
	*--------------------------------------------------------------------------*
	*	REQUIRES: 	${dt_final}/pooled_rider_audit_constructed.dta		 	   *
	* 	CREATES:  	${out_graphs}/wtp_harass.png						 	   *
	****************************************************************************
		
    do "${do_graphs}/wtp_harass.do"

	****************************************************************************
	* Figure 5: IAT D-Score distribution by test type and gender		   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/platform_survey_constructed.dta			   	   *
	*	CREATES:  ${out_graphs}/IAT_safety.png							   	   *
	*	 		  ${out_graphs}/IAT_advances.png						   	   *
	*			  ${out_graphs}/IAT_men.png								   	   *
	*			  ${out_graphs}/IAT_women.png							   	   *
	****************************************************************************

	do "${do_graphs}/iatscores.do"

* Main tables ==================================================================

	****************************************************************************
	* Table 1: Sample description										   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   	   *
	*	  		  ${dt_final}/platform_survey_constructed.dta	 		   	   *
	*	CREATES:  ${out_tables}/balance_table.tex						   	   *
	****************************************************************************
	
	do "${do_tables}/balance_table.do"

	****************************************************************************
	* Table 2: Revealed preferences, overall and by ride condition		   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   	   *
	*	CREATES:  ${out_tables}/paper_wtp_main.tex						   	   *
	*			  ${out_tables}/paper_wtp_appendix.tex					   	   *
	*			  ${out_tables}/online_wtp_main.tex					   	   	   *
	*			  ${out_tables}/online_wtp_appendix.tex					   	   *
	****************************************************************************
		
	do "${do_tables}/wtp.do"

	****************************************************************************
	* Table 3: Impact of randomized assignment of space on reported harassment *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta	   		   *
	*	CREATES:  ${out_tables}/paper_carimpactharassment_main.tex		 	   *
	*			  ${out_tables}/paper_carimpactharassment_appendix.tex		   *
	*			  ${out_tables}/online_carimpactharassment_main.tex			   *
	*			  ${out_tables}/online_carimpactharassment_appendix.tex		   *
	****************************************************************************
		
	do "${do_tables}/carimpactharassment.do"

	****************************************************************************
	* Table 4: Revealed preferences by rider risk perception			   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   	   *
	*	CREATES:  ${out_tables}/paper_wtprisk.tex						   	   *
	*			  ${out_tables}/online_wtprisk.tex						   	   *
	****************************************************************************

	do "${do_tables}/wtprisk.do"
		
	****************************************************************************
	* Table 5: Back-of-envelope estimates of cost of harassment			   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed_full.dta 	   	   *
	*	CREATES: ${out_tables}/back_envelope_costs_full.tex  			   	   *
	****************************************************************************
		
	do "${do_tables}/back_envelope_benefit_table.do"
		
* Appendix figures =============================================================

	****************************************************************************
	* Figure A2: Congestion in the system by time window				   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_mapping.dta						   	   *
	*			  ${dt_rider_int}/congestion_station_level.dta			   	   *
	*	CREATES:  ${out_graphs}/loadfactor.png							   	   *
	****************************************************************************
		
	do "${do_graphs}/loadfactor.do"

	****************************************************************************
	* Figure A3: Presence of male riders by space						   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_mapping.dta						   	   *
	*	CREATES:  ${out_graphs}/Paper/mappingcompliancebycar.png		   	   *
	*			  ${out_graphs}/Presentation/mappingcompliancebycar.png    	   *
	****************************************************************************

	do "${do_graphs}/mappingcompliancebycar.do"

	****************************************************************************
	* Figure A5: Difference in presence of male riders between spaces	   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_rider_fin}/pooled_mapping.dta					   	   *
	*	CREATES:  ${out_graphs}/Paper/diffcompliance.png		   		   	   *
	****************************************************************************

	do "${do_graphs}/diffcompliance.do"

	****************************************************************************
	* Figure A6: Correlation between take-up of reserved space and presence of *
	* male riders												 			   *
	*--------------------------------------------------------------------------*
	*	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta			   *
	*   CREATES:	${out_graphs}/Paper/takeupandcongestion.png			 	   *
	****************************************************************************

	do "${do_graphs}/takeupandcongestion.do"

	****************************************************************************
	* Figure A7: Rides sequence and take-up of reserved space			   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta	 	   	   *
	*	CREATES:	${out_graphs}/Paper/eventstudy.png					   	   *
	*				${out_graphs}/Paper/eventstudy_hist.png				   	   *
	****************************************************************************

    do "${do_graphs}/eventstudy.do"
		
	****************************************************************************
	* Figure A8: Advantages of reserved space: unprompted responses from   	   *
	* participants of rider crowdsourcing								   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   	   *
	*	CREATES:  ${out_graphs}/advantages_pink_car.png				       	   *
	****************************************************************************

	do "${do_graphs}/advantagespinkcar.do"

	****************************************************************************
	* Figure A9: Take-up of women-reserved space with positive opportunity 	   *
	* cost: stated and revealed preferences								   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta		   	   *
	*	CREATES:	${out_graphs}/statedrevealed3.png					   	   *
	****************************************************************************

	do "${do_graphs}/statedrevealed3.do"

	****************************************************************************
	* Figure A10: Sorting of men between spaces							   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   	   *
	*	CREATES:  ${out_graphs}/presentation_selection.png				   	   *
	*			  ${out_graphs}/paper_selection.png						   	   *
	****************************************************************************

	do "${do_graphs}/selection.do"

	****************************************************************************
	* Figure A11: First and second order beliefs: percent of respondents who   *
	* believe women who ride the public space are more open to advances than   *
	* those who ride the women-reserved space						 		   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/platform_survey_constructed.dta	 			   *
	*	CREATES:  ${out_graphs}/beliefs.png									   *
	****************************************************************************

	do "${do_graphs}/beliefs.do"

* Appendix tables ==============================================================

	****************************************************************************
	* Table A1: Sample size description									   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta 	 	   	   *
	*				${dt_final}/platform_survey_constructed.dta   		   	   *
	*	CREATES:	${out_tables}/sample_table.tex						   	   *
	****************************************************************************

	do "${do_tables}/sample_table.do"

	****************************************************************************
	* Table A3: Correlation between platform observations data and rider   	   *
	* reports	 														   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta 		   	   *
	*	CREATES:  ${out_tables}/mappingridercorr.tex					   	   *
	****************************************************************************

	do "${do_tables}/mappingridercorr.do"

	****************************************************************************
	* Table A4: Response to platform survey and IAT						   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/platform_survey_constructed.dta	  		   	   *
	* 	CREATES:  ${out_tables}/response.tex							   	   *
	****************************************************************************

	do "${do_tables}/response.do"

	****************************************************************************
	* Table A5: IAT: Robustness check for priming with survey questions	   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/platform_survey_constructed.dta		 	   	   *
	*	CREATES:  ${out_tables}/priming.tex							  	   	   *
	****************************************************************************

	do "${do_tables}/priming.do"

	****************************************************************************
	* Table A6: Test for order effects in on screen presentation of 	   	   *
	* public / reserved space											   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta	 	   	   *
	*	CREATES:  ${out_tables}/order.tex							  	   	   *
	****************************************************************************

	do "${do_tables}/order.do"

	****************************************************************************
	* Table A7: Adjustment on other margins								   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		  	   *
	*	CREATES:  ${out_tables}/adjustment.tex							   	   *
	****************************************************************************

	do "${do_tables}/adjustment.do"

	****************************************************************************
	* Table A8: Impact of randomized assignment of car on fear and subjective  *
	* well-being, overall and by ride condition								   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta			   *
	*	CREATES:  ${out_tables}/paper_wellbeing_main.tex					   *
	*			  ${out_tables}/paper_wellbeing_appendix.tex				   *
	*			  ${out_tables}/online_wellbeing_main.tex					   *
	*			  ${out_tables}/online_wellbeing_appendix.tex				   *
	****************************************************************************

	do "${do_tables}/wellbeing.do"

	****************************************************************************
	* Table A9: Social norms survey										   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/platform_survey_constructed.dta			       *
	* 	CREATES:  ${out_tables}/genderdescriptives.tex					   	   *
	****************************************************************************

	do "${do_tables}/genderdescriptives.do"

	****************************************************************************
	* Table A10: IAT results											       *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/platform_survey_constructed.dta	  		       *
	*	CREATES:  ${out_tables}/mainiat.tex								       *
	*			  ${out_graphs}/presentation_iat_coef.png				       *
	****************************************************************************

	do "${do_tables}/mainiat.do"


* Not mentioned in main text ===================================================

	****************************************************************************
	* Table D1: Correlates of attrition across phases					   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed_full.dta  	  	   *
	*	CREATES:  ${out_tables}/attrition.tex							   	   *
	****************************************************************************

	do "${do_tables}/attrition.do"

	****************************************************************************
	* Figure D1: Take-up of reserved space by opportunity cost level - 	   	   *
	* lower bounds for attrition										   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta	       	   *
	*	CREATES:  ${out_graphs}/takeup_person_bound.png					   	   *
	****************************************************************************

	do "${do_graphs}/takeup_person_bound.do"

	****************************************************************************
	* Table D2: Effect of random assignment on participation			   	   *
	*--------------------------------------------------------------------------*
	*	REQUIRES: ${dt_final}/pooled_rider_audit_phase3_offers.dta	   	   	   *
	*	CREATES:  ${out_tables}/phase3participation.tex					   	   *
	****************************************************************************

	do "${do_tables}/phase3participation.do"

*---------------------------------------------------------------- End of do-file