/*******************************************************************************
*								Rio Pink Car								   *
*			  	   		IMPORT REPUTATION IAT DATA						  	   *
********************************************************************************

	
	** OUTLINE:		PART 1: Generate ID variables
					Part 1.1: Create ID variables
					Part 1.2: Carry forward ID variables to other observations
					Part 1.3: Delete lines that contained only ID and no stimulus data
					PART 2: Correct issues from field observations
					PART 3: Parse stimulus data
					PART 4: Make data long per stimulus
					PART 5: Clean incorrectly imported characters
					PART 6: Save intermediate file
					
	** REQUIRES:	${dt_platform_raw}/iat_security_alldata.txt
																			
	** CREATES:	  	${dt_platform_fin}/iat_security.dta
							
	** WRITEN BY:   Luiza Andrade [lcardosodeandrad@worldbank.org]

		
*******************************************************************************/

	* Load data
	import 	delimited "${encrypt}/Platform survey/iat_security_alldata.txt", delimiter(space) clear

********************************************************************************
* 						PART 1: Generate ID variables
********************************************************************************

* ------------------------------------------------------------------------------
* 						Part 1.1: Create ID variables
* ------------------------------------------------------------------------------

	* Create variables in the line they are when imported
	gen time_block = v4					if v3 == "Time:"
	gen id = v2 						if regex(v1,"Participant")
	gen block = subinstr(v2, ":","", .) if v1 == "Block"
	
	* Destring
	destring id time_block block, replace

* ------------------------------------------------------------------------------
* 			Part 1.2: Carry forward ID variables to other observations
* ------------------------------------------------------------------------------

	qui count
	local totalObs = r(N)
	
	* ID and block: are the first two lines in the data, copy them to next lines
	foreach var of varlist id block {
		forvalues line = 2/`totalObs' {

			qui sum `var' in `line'
			
			if r(N) == 0 {
				local prevLine = `line' - 1
				qui sum `var' in `prevLine'
				local prevVal = r(mean)
			
				replace `var' = `prevVal' in `line'
			}
		}
	}

	* Time: is the last line of each block, copy to previous lines
	forvalues line = `totalObs'(-1)2 {

		qui sum time_block in `line'

		if r(N) == 0 {
			local nextLine = `line' + 1
			qui sum time_block in `nextLine'
			local nextVal = r(mean)
		
			replace time_block = `nextVal' in `line'
		}
	}

* ------------------------------------------------------------------------------
* 		Part 1.3: Delete lines that contained only ID and no stimulus data
* ------------------------------------------------------------------------------
	
	* Keep only stimulus lines
	drop if regexm(v1, "Participant") | regexm(v3, "Time:") | regexm(v1, "/") | missing(v4)

	replace v2 = "" if regexm(v2,":")

	
********************************************************************************
*				PART 2: Correct issues from field observations
********************************************************************************
	
	* Drop IDs that responded to IAT randomly or incorrectly
	drop if inlist(id, 2060, 2091, 2136, 2152, 2269, 2344, 2348, 6151, 6174)

	* Fix issues incorrectly entered id
	replace id = 1505 if id == 2505 & block == 1 & time_block == 18133
	replace id = 1505 if id == 2505 & block == 2 & time_block == 34358
	replace id = 1505 if id == 2505 & block == 3 & time_block == 39288
	replace id = 1505 if id == 2505 & block == 4 & time_block == 16781
	replace id = 1505 if id == 2505 & block == 5 & time_block == 47659
	
	* Participant took IAT twice, keeping only first time
	drop if id == 2103 & block == 1 & time_block == 23966
	drop if id == 2103 & block == 2 & time_block == 32652
	drop if id == 2103 & block == 3 & time_block == 50598
	drop if id == 2103 & block == 4 & time_block == 24459
	drop if id == 2103 & block == 5 & time_block == 52141

	
********************************************************************************
*						PART 3: Parse stimulus data
********************************************************************************
* Stimuli data was imported broken into multiple lines. The next few lines 
* will parse them so that each line is one block and each columns is one piece 
* of stimuli data 
********************************************************************************
	
	* Variable v1 only contained block info
	drop v1
	
	* Collapse all line info to one variable
	egen line = concat(v*), punct(,)
	drop v*

	* Create a single line per ID and block with all lines of stimuli data
	bys id block: gen count = _n
	reshape wide line, i(id block) j(count)										// 1 column = 1 line
	egen line = concat(line*), punct(",")										// "line" column == all lines
	drop line1-line4															// Dropped redundant columns

	* Clean up strings
	replace line = substr(line,2,.) if substr(line,1,1) == ","
	replace line = subinstr(line,",.","",.)
	replace line = subinstr(line,",,,",",",.)
	replace line = subinstr(line,",,",",",.)
	replace line = subinstr(line,",,,,",",",.)
	replace line = subinstr(line,",,",",",.)

	* Parse line into columns
	split line, parse(",")														// 1 column = 1 piece of stimuli data
	drop line

********************************************************************************
*					PART 4: Make data long per stimulus
********************************************************************************

	* Destring data (for time var and correct dummy)
	foreach var of varlist line* {
		destring `var', replace
	}

	* Each stimulus' data includes (1) the stimulus, (2) the dummy, (3) a dummy
	* for correct/incorrect. This will identify all information about the same
	* stimulus
	forvalues iteration = 1/40 {
		
		local stimulus 	= 3 * (`iteration' - 1) + 1
		local correct 	= 3 * (`iteration' - 1) + 2
		local time	 	= 3 * (`iteration' - 1) + 3
		
		rename line`stimulus' 	stimulus`iteration'
		rename line`correct' 	correct`iteration'
		rename line`time' 		time`iteration'
		
	}
	
	* Reshape so that each stimulus is in one line
	reshape long stimulus correct time, i(id block time_block) j(iteration)

********************************************************************************
*				PART 5: Clean incorrectly imported characters
********************************************************************************
	
	replace stimulus = "Distraida" if stimulus== "DistraÃ­da"
	
********************************************************************************
*						PART 6: Save intermediate file
********************************************************************************
	
	gen version = "Security"
	drop if stimulus == ""
	drop iteration
	
	compress
	
	save				"${dt_raw}/iat_security.dta", replace
	iemetasave using 	"${dt_raw}/iat_security.txt", replace

*============================================================= That's all, folks!
