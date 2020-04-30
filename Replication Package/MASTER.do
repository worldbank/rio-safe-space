/*******************************************************************************
*								Rio Pink Car								   *
*   					  CLEANING MASTER DO-FILE							   *
*   							   2017										   *
********************************************************************************

	** PURPOSE:  	Clean compliance pilot data
	
	** OUTLINE:		PART 1:  Set standard settings
					PART 2:  Set directories
					PART 3:  Merging
					PART 4:  Analysis
				  
	** WRITEN BY:   Astrid Zwager and Luiza Andrade


********************************************************************************
*						   SELECT PARTS TO RUN   							   *
********************************************************************************/

	* Luiza's folder
	* --------------
	global github		"C:\Users\wb501238\Documents\GitHub\rio-safe-space\Replication Package"
	global dropbox 		"C:\Users\wb501238\Dropbox\WB\RJ - Pink car study"

	
********************************************************************************
*			PART 1:  Set standard settings and install packages				   *
********************************************************************************/
	
	local packages	ietoolkit estout ivreg2
	
	ieboilstart, v(14.0)  matsize(10000)
	`r(version)'

	
********************************************************************************
*			PART 2:  Prepare folder paths and define programms				   *
********************************************************************************

	do 		"${github}/dofiles/settings.do"
	
	* Balance table
	do 		"${do_analysis}/ado/table_options.ado"
	
	if `mainresults' {			
		
		* Main figures ------------------------------------------
		
		* Rides sequence and take-up of reserved space - Take up of reserved space over common ride sequence
		do "$do_analysis/f1_eventstudy_bypremium.do"
		
		* Take-up of women's car by opportunity cost
		do "$do_analysis/f2_takeup.do"

		* IAT D-Score distribution by test type and gender
		do "$do_analysis/f4_iatscores.do"
		
		* Sample size description
		do "$do_analysis/t1_sample_table.do"
	}
