/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*   					  	   MASTER DO-FILE							   	   *
********************************************************************************

					PART 0:  User inputs
					PART 1:  Prepare folder paths
					PART 2:  Load necessary packages
					PART 3:  Data preparation
					PART 4:  Analysis

********************************************************************************
	PART 0: USER INPUTS															
********************************************************************************/

	ieboilstart, v(14.0)  matsize(10000)
	`r(version)'

/*------------------------------------------------------------------------------
	Set folder paths
------------------------------------------------------------------------------*/

	global github		"C:\Users\wb501238\Documents\GitHub\rio-safe-space/Replication Package"		//	<----------------------------------------- ADD PATH TO YOUR CLONE HERE
	global encrypt		"C:\Users\wb501238\Dropbox\WB\RJ - Pink car study\Data\Rider audits\Data\Raw"
	
/*------------------------------------------------------------------------------
	Select sections to run
------------------------------------------------------------------------------*/

	local  packages			0 // Install user-written commands used in the project
	local  cleaning			0 // Run data cleaning
	global encrypted		0 // Start from identified data
	local  construction		0 // Re-create analysis indicators
	local  mainresults		1 // Re-create analysis outputs

/*------------------------------------------------------------------------------
	Set control variables
------------------------------------------------------------------------------*/

	global star					star	(* .1 ** .05 *** .01) // nostar

	global demographics 		d_lowed d_young d_single d_employed d_highses
	global interactionvars		pink_highcompliance mixed_highcompliance ///
								pink_lowcompliance mixed_lowcompliance
	global interactionvars_oc	pos_highcompliance zero_highcompliance ///
								pos_lowcompliance  zero_lowcompliance
	global wellbeing			CO_concern CO_feel_level CO_happy CO_sad ///
								CO_tense CO_relaxed CO_frustrated CO_satisfied ///
								CO_feel_compare
	
	* Balance variables (Table 1)
	global balancevars1			d_employed age_year educ_year ride_frequency ///
								home_rate_allcrime home_rate_violent home_rate_theft ///
								grope_pink_cont grope_mixed_cont ///
								comments_pink_cont comments_mixed_cont
	global balancevars2			usual_car_cont nocomp_30_cont nocomp_65_cont ///
								fullcomp_30_cont fullcomp_65_cont

	* Other adjustment margins (Table A7)
	global adjustind 			CI_wait_time_min d_against_traffic CO_switch ///
								RI_spot CI_time_AM CI_time_PM

/*------------------------------------------------------------------------------
	Plot settings
------------------------------------------------------------------------------*/

	set scheme s2color
	
	global grlabsize 		4
	global col_womencar		purple
	global col_mixedcar 	`" "18 148 144" "' // teal
	global col_1			`" "18 148 144" "' // teal
	global col_2			purple //`" "102 51 153" "'
	global col_aux_bold		gs6
	global col_aux_light	gs12
	global col_highlight	cranberry
	global col_box			gs15
	
	global paper_plotops	graphregion(color(white)) ///
							bgcolor(white) ///
							ylab(, glcolor(${col_box})) ///
							xlab(, noticks)
	global pres_plotops		graphregion(color(white)) ///
							bgcolor(white) ///
							ylab(, glcolor(${col_box}) labsize(${grlabsize})) ///
							xlab(, labsize(${grlabsize}) noticks)

	global plot_options		${paper_plotops}
	global lab_womencar		Reserved space
	global lab_mixedcar		Public space

/*******************************************************************************
					PART 1:  Prepare folder paths
*******************************************************************************/

	* Do files
	global	do					"${github}/dofiles"
	global	do_analysis			"${do}/analysis"
	global 	do_tables			"${do_analysis}/paper/tables"
	global 	do_graphs			"${do_analysis}/paper/graphs"

	* Data sets
	global	data				"${github}/data"
	global	dt_final			"${data}/final"
	global 	dt_raw				"${data}/raw"
	global	dt_int				"${data}/intermediate"

	* Documentation
	global	doc					"${github}/documentation"
	global 	doc_rider			"${doc}/rider-audits"
	
	* Outputs
	global	out_git				"${github}/outputs"
	global 	out_tables			"${out_git}/tables"
	global 	out_graphs			"${out_git}/graphs"

/*******************************************************************************
					PART 2:  Load necessary packages
********************************************************************************/

	if `packages' {
		ssc install	ietoolkit
		ssc install iefieldkit
		ssc install estout
		ssc install unique
		ssc install coefplot
	}

	* Custom commands
	do 		"${do}/ado/table_options.ado"
	do 		"${do}/ado/iemetasave.ado"
	do 		"${do}/ado/iecodebook.ado"
	

********************************************************************************
*						   PART 3: Data preparation     					   *
********************************************************************************

	if `cleaning' {
		do "${do}/rider-audits/MASTER_rider_audits_data_prep.do"
	}
	
	if `construction' {
		do "${do}/rider-audits/pooled/7_construct.do" 	
		do "${do}/rider-audits/pooled/8_reconstruct_p3_assignment.do"
	}

	
********************************************************************************
*							PART 4: Analysis     							   *
********************************************************************************

	if `mainresults' {

* Main figures =================================================================

		************************************************************************
		* Figure 2: Rides sequence and take-up of reserved space			   *
		*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
		*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   *
		*	CREATES: ${out_graphs}/Paper/eventstudy_bypremium.png			   *
		************************************************************************

		do "${do_graphs}/eventstudy_bypremium.do"	
		
		************************************************************************
		* Figure 3: Take-up of reserved space by opportunity cost			   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   *
		*	CREATES:  ${out_graphs}/takeup_fe.png							   *
		*			  ${out_graphs}/takeup_person.png						   *
		************************************************************************

		do "${do_graphs}/takeup.do"
		
	****************************************************************************
	* Figure 4: Joint distribution of takeup and harassment by presence of men *
	*--------------------------------------------------------------------------*
	*	REQUIRES: 	${dt_final}/pooled_rider_audit_constructed.dta		 	   *
	* 	CREATES:  	${out_graphs}/wtp_harass.png						 	   *
	****************************************************************************
		
    do "${do_graphs}/wtp_harass.do"

		************************************************************************
		* Figure 5: IAT D-Score distribution by test type and gender		   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/platform_survey_constructed.dta			   *
		*	CREATES:  ${out_graphs}/IAT_safety.png							   *
		*	 		  ${out_graphs}/IAT_advances.png						   *
		*			  ${out_graphs}/IAT_men.png								   *
		*			  ${out_graphs}/IAT_women.png							   *
		************************************************************************

		do "${do_graphs}/iatscores.do"

* Main tables ==================================================================

		************************************************************************
		* Table 1: Sample description										   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   *
		*	  		  ${dt_final}/platform_survey_constructed.dta	 		   *
		*	CREATES:  ${out_tables}/balance_table.tex						   *
		************************************************************************
		
		do "${do_tables}/balance_table.do"

		************************************************************************
		* Table 2: Revealed preferences, overall and by ride condition		   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   *
		*	CREATES:  ${out_tables}/paper_wtp_main.tex						   *
		*			  ${out_tables}/paper_wtp_appendix.tex					   *
		*			  ${out_tables}/online_wtp_main.tex					   	   *
		*			  ${out_tables}/online_wtp_appendix.tex					   *
		************************************************************************
		
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

		************************************************************************
		* Table 4: Revealed preferences by rider risk perception			   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   *
		*	CREATES:  ${out_tables}/paper_wtprisk.tex						   *
		*			  ${out_tables}/online_wtprisk.tex						   *
		************************************************************************

		do "${do_tables}/wtprisk.do"
		
		************************************************************************
		* Table 5: Back-of-envelope estimates of cost of harassment			   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed_full.dta 	   *
		*	CREATES: ${out_tables}/back_envelope_costs_full.tex  			   *
		************************************************************************
		
		do "${do_tables}/back_envelope_benefit_table.do"
		
* Appendix figures =============================================================

		************************************************************************
		* Figure A2: Congestion in the system by time window				   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_mapping.dta						   *
		*			  ${dt_rider_int}/congestion_station_level.dta			   *
		*	CREATES:  ${out_graphs}/loadfactor.png							   *
		************************************************************************
		
		do "${do_graphs}/loadfactor.do"

		************************************************************************
		* Figure A3: Presence of male riders by space						   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_mapping.dta						   *
		*	CREATES:  ${out_graphs}/Paper/mappingcompliancebycar.png		   *
		*			  ${out_graphs}/Presentation/mappingcompliancebycar.png    *
		************************************************************************

		do "${do_graphs}/mappingcompliancebycar.do"

		************************************************************************
		* Figure A5: Difference in presence of male riders between spaces	   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_rider_fin}/pooled_mapping.dta					   *
		*	CREATES:  ${out_graphs}/Paper/diffcompliance.png		   		   *
		************************************************************************

		do "${do_graphs}/diffcompliance.do"

	****************************************************************************
	* Figure A6: Correlation between take-up of reserved space and presence of *
	* male riders												 			   *
	*--------------------------------------------------------------------------*
	*	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta			   *
	*   CREATES:	${out_graphs}/Paper/takeupandcongestion.png			 	   *
	****************************************************************************

		do "${do_graphs}/takeupandcongestion.do"

		************************************************************************
		* Figure A7: Rides sequence and take-up of reserved space			   *
		*----------------------------------------------------------------------*
		*	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta	 	   *
		*	CREATES:	${out_graphs}/Paper/eventstudy.png					   *
		*				${out_graphs}/Paper/eventstudy_hist.png				   *
		************************************************************************

    do "${do_graphs}/eventstudy.do"
		
		************************************************************************
		* Figure A8: Advantages of reserved space: unprompted responses from   *
		* participants of rider crowdsourcing								   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   *
		*	CREATES:  ${out_graphs}/advantages_pink_car.png				       *
		************************************************************************

		do "${do_graphs}/advantagespinkcar.do"

		************************************************************************
		* Figure A9: Take-up of women-reserved space with positive opportunity *
		* cost: stated and revealed preferences								   *
		*----------------------------------------------------------------------*
		*	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta		   *
		*	CREATES:	${out_graphs}/statedrevealed3.png					   *
		************************************************************************

		do "${do_graphs}/statedrevealed3.do"

		************************************************************************
		* Figure A10: Sorting of men between spaces							   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   *
		*	CREATES:  ${out_graphs}/presentation_selection.png				   *
		*			  ${out_graphs}/paper_selection.png						   *
		************************************************************************

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

		************************************************************************
		* Table A1: Sample size description									   *
		*----------------------------------------------------------------------*
		*	REQUIRES:	${dt_final}/pooled_rider_audit_constructed.dta 	 	   *
		*				${dt_final}/platform_survey_constructed.dta   		   *
		*	CREATES:	${out_tables}/sample_table.tex						   *
		************************************************************************

		do "${do_tables}/sample_table.do"

		************************************************************************
		* Table A3: Correlation between platform observations data and rider   *
		* reports	 														   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta 		   *
		*	CREATES:  ${out_tables}/mappingridercorr.tex					   *
		************************************************************************

		do "${do_tables}/mappingridercorr.do"

		************************************************************************
		* Table A4: Response to platform survey and IAT						   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/platform_survey_constructed.dta	  		   *
		* 	CREATES:  ${out_tables}/response.tex							   *
		************************************************************************

		do "${do_tables}/response.do"

		************************************************************************
		* Table A5: IAT: Robustness check for priming with survey questions	   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/platform_survey_constructed.dta		 	   *
		*	CREATES:  ${out_tables}/priming.tex							  	   *
		************************************************************************

		do "${do_tables}/priming.do"

		************************************************************************
		* Table A6: Test for order effects in on screen presentation of 	   *
		* public / reserved space											   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta	 	   *
		*	CREATES:  ${out_tables}/order.tex							  	   *
		************************************************************************

		do "${do_tables}/order.do"

		************************************************************************
		* Table A7: Adjustment on other margins								   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta		   *
		*	CREATES:  ${out_tables}/adjustment.tex							   *
		************************************************************************

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

		************************************************************************
		* Table A9: Social norms survey										   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/platform_survey_constructed.dta			   *
		* 	CREATES:  ${out_tables}/genderdescriptives.tex					   *
		************************************************************************

		do "${do_tables}/genderdescriptives.do"

		************************************************************************
		* Table A10: IAT results											   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/platform_survey_constructed.dta	  		   *
		*	CREATES:  ${out_tables}/mainiat.tex								   *
		*			  ${out_graphs}/presentation_iat_coef.png				   *
		************************************************************************

		do "${do_tables}/mainiat.do"


* Not mentioned in main text ===================================================

		************************************************************************
		* Table D1: Correlates of attrition across phases					   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed_full.dta  	   *
		*	CREATES:  ${out_tables}/attrition.tex							   *
		************************************************************************

		do "${do_tables}/attrition.do"

		************************************************************************
		* Figure D1: Take-up of reserved space by opportunity cost level - 	   *
		* lower bounds for attrition										   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_rider_audit_constructed.dta	       *
		*	CREATES:  ${out_graphs}/takeup_person_bound.png					   *
		************************************************************************

		do "${do_graphs}/takeup_person_bound.do"

		************************************************************************
		* Table D2: Effect of random assignment on participation			   *
		*----------------------------------------------------------------------*
		*	REQUIRES: ${dt_final}/pooled_rider_audit_phase3_offers.dta	   	   *
		*	CREATES:  ${out_tables}/phase3participation.tex					   *
		************************************************************************

		do "${do_tables}/phase3participation.do"

	}
  
/*******************************************************************************
	Congratulations, you've made it to the end of the do files!
	(Actually, there are a lot more that didn't make the final cut)
*******************************************************************************/
