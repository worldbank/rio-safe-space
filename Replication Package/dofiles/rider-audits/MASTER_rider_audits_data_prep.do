
/*******************************************************************************
	First wave of data collection
*******************************************************************************/
	
	if ${encrypted} do "${do}/rider-audits/baseline/1. Import raw.do" 
	
	* Cleaning tasks
	do "${do}/rider-audits/baseline/2. Cleaning/demo.do" 
	do "${do}/rider-audits/baseline/2. Cleaning/check-in.do" 
	do "${do}/rider-audits/baseline/2. Cleaning/check-out.do" 
	do "${do}/rider-audits/baseline/2. Cleaning/ride.do" 
	do "${do}/rider-audits/baseline/2. Cleaning/exit.do" 
	do "${do}/rider-audits/baseline/2. Cleaning/mapping.do" 

	* Merge tasks
	do "${do}/rider-audits/baseline/3. Merge.do" 
	
/*******************************************************************************
	Second wave of data collection
*******************************************************************************/

	* Import and de-identify data
	if ${encrypted} do "${do}/rider-audits/compliance-pilot/1. Import raw.do" 
	
	* Cleaning tasks
	do "${do}/rider-audits/compliance-pilot/2. Cleaning/demo.do" 
	do "${do}/rider-audits/compliance-pilot/2. Cleaning/check-in.do" 
	do "${do}/rider-audits/compliance-pilot/2. Cleaning/check-out.do" 
	do "${do}/rider-audits/compliance-pilot/2. Cleaning/ride.do" 
	do "${do}/rider-audits/compliance-pilot/2. Cleaning/exit.do" 
	do "${do}/rider-audits/compliance-pilot/2. Cleaning/mapping.do" 

	* Merge tasks
	do "${do}/rider-audits/compliance-pilot/3. Merge.do" 
	
/*******************************************************************************
	Merge waves
*******************************************************************************/

	do "${do}/rider-audits/pooled/pool_exit.do" 
	do "${do}/rider-audits/pooled/pool_mapping.do" 
	do "${do}/rider-audits/pooled/pool_rides.do" 
	
************************************************************************ The end.
