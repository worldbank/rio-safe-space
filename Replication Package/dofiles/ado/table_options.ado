
cap program drop tableprep
	program		 tableprep, rclass
	
	syntax anything, panel(string) [depvar(string) linebreak posthead(string) prehead(string) title(string) prefoot(string)] 
	
	local nmodels		: word count `anything'
	local ncols			= `nmodels' + 1	
	local formatting	label f tex se ///
						star	(* .1 ** .05 *** .01) ///
						b		(%9.3f) ///
						se		(%9.3f) ///
						sfmt	(%9.3f) 
	local prefoot		"\\[-1.8ex] \hline \\[-1.8ex] `prefoot' "

	if "`panel'" == "A" {
	
		local save			replace
	
		local prehead_pre		"\begin{tabular}{l*{`nmodels'}{c}} \hline\hline \\[-1.8ex] & \multicolumn{`nmodels'}{c}{"
		
		if "`linebreak'" == ""	{
			local prehead_suf	"Dependent variable: `depvar'} \\ "
		}
		else {
			local prehead_suf	"\begin{tabular}{@{}c@{}}Dependent variable: \\ `depvar' \end{tabular}} \\ "
		}
		
		
		local	posthead 	"`posthead' \hline \\[-1ex]"
			
		if "`title'" != "" {
			local	posthead 	"`posthead' \multicolumn{`ncols'}{c}{\textit{Panel A: `title'}} \\\\[-1ex]"
		}
	}
	else if "`panel'" == "B" {
	
		local save				append
		local prehead 			""
		local posthead			"\hline \\[-1ex] \multicolumn{`ncols'}{c}{\textit{Panel B: `title'}} \\\\[-1ex]"
		local postfoot			postfoot("\hline\hline \end{tabular}")
	}
	
	return local table_options `"`save' `formatting' prehead("`prehead_pre'`prehead_suf'`prehead'") posthead("`posthead'") prefoot("`prefoot'") `postfoot'"'
	return local ncols			`ncols'
	return local footer_title 	"\hline \\[-1ex]  \multicolumn{`ncols'}{c}{\textit{Post-estimate tests for heterogeneous effects}} \\\\[-1ex]"
	
end
