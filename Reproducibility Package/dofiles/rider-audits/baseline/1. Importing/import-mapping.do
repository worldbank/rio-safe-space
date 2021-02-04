/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
* 			  	 	Clean baseline platform observations			 		   *
********************************************************************************

	* REQUIRES:		${encrypt}/Baseline/07112016/Mapping 07112016
					${encrypt}/Baseline/mapping_task_key
					${doc_rider}/baseline-study/codebooks/mapping.xlsx
																			
	* CREATES:	 	${encrypt}/baseline_mapping_raw.dta
				    ${dt_raw}/baseline_mapping_raw_deidentified.dta
					
	* NOTES:		This data is considered identified because it contains
					station and line NAMES

********************************************************************************
	Load mapping data (requires access to identified data)
********************************************************************************/
	

	import 	delimited using "${encrypt}/Baseline/07112016/Mapping 07112016", ///
			delim (",") ///
			varnames(1) ///
			clear
			
	isid obs_uid, sort 
	compress
	
	save 			 "${encrypt}/baseline_mapping_raw.dta", replace
	iemetasave using "${dt_raw}/baseline_mapping_raw.txt", replace short

	
/********************************************************************************
	Prepare identifying variables
 	item_uid is an encode variable that does not correspond to the project ID 
	variables for this data set (which are time and station bins). 
	The meaning of the item_uid variable was shared in a separate file, and
	is necessary to merge mapping and ride observations. The code below
	adds merges this file so the project ID is present in the dataset
********************************************************************************/

	* Load time and station bin identifiers
	import 	delimited using "${encrypt}/Baseline/mapping_task_key", ///
			delim (",")  ///
			varnames(1) ///
			clear				

	* Clean dataset key so it can be merged back to mapping observations
	split 	item_uid, p(":")
	replace item_uid = item_uid2

	* Merge to observers data
	merge 1:m item_uid using "${encrypt}/baseline_mapping_raw.dta", ///
		assert(1 3) /// 4 station bins were never observed at a few time bins, creating a total of 9 missing time-station bin combinations (_merge == 1)
		keep(3) /// 	We keep only the combinations we have data for
		nogen 	

/********************************************************************************
	Basic cleaning for more efficient data storage
********************************************************************************/

	* Recode station bin from alphabetical order to line order
	encode  station_bin, gen(stationbin)
	recode 	stationbin  (1 = 8)  (2 = 19) (3 = 20)  (4 = 10)  (6 = 14)  (7 = 18) ///
						(8 = 1)  (9 = 15) (10 = 11) (11 = 21) (13 = 3)  (14 = 6) ///
						(15 = 4) (16 = 7) (17 = 16) (18 = 2)  (19 = 17)
	
	* Time bin
	encode 	timerestriction_id, gen(time_bin)

	* Date of obsevation 
	split 		created_at, p("")
	split 		created_at1, p("-")
	destring 	created_at11 created_at12 created_at13, replace
	split 		created_at2, p(":")
	
	
		
	gen double 	MA_date = mdy(created_at12, created_at13, created_at11)
	format 		MA_date 	%td
	

	* Categorical variables for congestion and compliance
	foreach var in 	regular_car_compliance pink_car_compliance ///
					regular_car_congestion pink_car_congestion {
			
		encode `var', gen(`var'_)
		drop `var'
	}

/********************************************************************************
	Annotate and save
********************************************************************************/
	
	iecodebook apply using "${doc_rider}/baseline-study/codebooks/mapping.xlsx", drop
	
	sort station_bin time_bin obs_uuid
	compress
	
	save 			 "${dt_raw}/baseline_mapping_raw_deidentified.dta", replace
	iemetasave using "${dt_raw}/baseline_mapping_raw_deidentified.txt", replace

	
**************************************************************** End of do-file!

