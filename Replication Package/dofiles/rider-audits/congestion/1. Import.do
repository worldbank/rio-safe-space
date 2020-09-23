/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*		 				 Import admin congestion data			 		 	   *
********************************************************************************

	REQUIRES:	${encrypt}/Congestion
	CREATES:	${encrypt}/congestion_raw.dta
				
	WRITEN BY:  Luiza Andrade [lcardoso@worldbank.org]
	
	NOTES:		Access to encrypted, identified data is required to run this file
	
********************************************************************************
*						Import and merge raw data							   *
********************************************************************************/


	foreach year in 2015 2016 {
	
	
		if `year' == 2015 	local months 09 10 11 12
		if `year' == 2016 	local months 01 02 03 04 05 06 07 08 09 10 11 
		
		foreach month of local months {
		
	
			import excel "${encrypt}/Congestion/Resultados_Simulacao_EMME_`year'-`month'_DETALHADO.XLSX", sheet("RESULT-ITINERARIES") firstrow clear
			
			gen month_merge = `month'
			gen year = `year'
			
			if !(`year' == 2015 & `month' == 09) {
				merge 1:1 month_merge year hora linha labeli using `congestion', nogen
			}
			
			tempfile	congestion
			save		`congestion'	
		}
	}
	
********************************************************************************
*							Save raw dataset								   *
********************************************************************************/
	
	save 				"${encrypt}/congestion_raw.dta", replace
	iemetasave using	"${dt_raw}/congestion_raw.txt", replace

********************************************************************************
