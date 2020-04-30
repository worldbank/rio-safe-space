
	global	do_analysis			"${github}/Analysis"
	global	do_rider			"${github}/Rider audit"
	global	do_rider_bl			"${do_rider}/Premise - Baseline study/Do-files"
	global	do_rider_pilot		"${do_rider}/Premise - Compliance pilot/Do-files"
	global	do_rider_cong		"${do_rider}/Supervia - congestion/Do-files"
	global	do_rider_pool		"${do_rider}/Data - Pooled/Do-files"
	global	do_platform			"${github}/Platform Survey"

	global	dt_rider			"${dropbox}/Data/Rider audits/Data"
	global	dt_rider_raw		"${dt_rider}/Raw"
	global	dt_rider_int		"${dt_rider}/Intermediate"
	global	dt_rider_fin		"${dt_rider}/Final"
	global	dt_rider_fin_gh		"${github}/data/rider-audit"
	
	global	dt_platform			"${dropbox}/Data/Platform survey/Data"
	global	dt_platform_raw		"${dt_platform}/Raw"
	global	dt_platform_int		"${dt_platform}/Intermediate"
	global	dt_platform_fin		"${dt_platform}/Final"
	
	global 	dt_congestion		"${dropbox}/Data/Supervia - congestion/Data"
	global 	dt_crime			"${dropbox}/Data/Crime data/Data"
	
	global	output 				"${dropbox}/Outputs/Inputs"
	global 	out_platform		"${dropbox}/Data/Platform survey/Outputs"
	global	out_graphs			"${output}/Graphs"
	global 	out_github			"${github}/Outputs/Tables"
	global	out_tables			"${output}/Tables"
	
	global 	doc_platform		"${dropbox}/Data/Platform survey/Documentation"
	global 	doc_pooled			"${dropbox}/Data/Rider audits/Documentation/Pooled"

	
	
	global grlabsize 		4
	global col_womencar		purple
	global col_mixedcar 	`" "18 148 144" "'
	global col_1			`" "18 148 144" "'
	global col_2			purple //`" "102 51 153" "'
	global col_aux_bold		gs6
	global col_aux_light	gs12
	global col_highlight	cranberry
	global col_box			gs15
	global plot_options		graphregion(color(white)) ///
							bgcolor(white) ///
							ylab(, glcolor(${col_box}) labsize(${grlabsize})) ///
							xlab(, labsize(${grlabsize}) noticks)			
	global interactionvars pink_highcompliance mixed_highcompliance pink_lowcompliance mixed_lowcompliance 
		
	global lab_womencar		Reserved space
	global lab_mixedcar		Public space
