/*******************************************************************************
* 			Demand for "Safe Spaces": Avoiding Harassment and Stigma		   *
*	 				 Append baseline and pilot exit surveys			 		   *
********************************************************************************
	
	* REQUIRES: 	${dt_int}/compliance_pilot_exit
					${dt_int}/baseline_exit
					${doc_rider}/pooled/pooled_exit.xlsx						  
	* CREATES:		${dt_final}/pooled_rider_audit_exit.dta 	  
				  
	* WRITEN BY:   Astrid Zwager

********************************************************************************
*						STEP 1: MERGE ALL PREMISE DATA		 				   *
*******************************************************************************/

	use 	"${dt_int}/compliance_pilot_exit", clear
	gen 	stage =	1
	
	tempfile pilot
	save	 `pilot'

	use 	"${dt_int}/baseline_exit", clear
	gen stage = 0 
	
	merge 1:1 stage user_uuid using `pilot', assert(1 2) nogen
	order user_uuid stage

********************************************************************************
*							STEP 2: ENCODE OPEN ANSWERS		 				   *
********************************************************************************

* -----------------------------------------------------------------------------*
* 							Advantages pink car
* -----------------------------------------------------------------------------*

	forvalues opCode = 0/5 {
		gen advantage_pink_`opCode' = 0 if !missing(advantage_pink)
	}

	replace advantage_pink = trim(advantage_pink)
	replace advantage_pink = lower(advantage_pink)
	
	* Option 0: none
	foreach exp in "nenhuma" "nao ha" "nao vej" "preferencia" {
	
		replace advantage_pink_0 = 1 if regexm(advantage_pink, "`exp'") 
	}

	
	* Option 1: more comfort
	foreach exp in "confort" "fedem" "comodidade" "vontade" "cheiro" "liberdade" {
	
		replace advantage_pink_1 = 1 if regexm(advantage_pink, "`exp'") 
	}
	
	
	* Option 2: less harassment
	foreach exp in 	"home" "abus" "assédio" "respeit" "assedi" "toca" "encost" ///
					"físic" "sarra" "mechendo" "constrangimento" "cantadas" ///
					"abordagens" "coment" "incomodada" {
					
		replace advantage_pink_2 = 1 if regexm(advantage_pink, "`exp'") 
	}
	
	
	gen advantage_pink_2_physical = 0 	if advantage_pink_2 == 1
	foreach exp in 	"encostando" "abus" "fisic" "sarra" "toca" "encost" "agarr" ///
					"físic" "trás" "atras" "abus" "contato" "tens" "proveit" ///
					"encontrando" "molest" "toque" "tocada" "esfreg" "rocando" {
					
		replace advantage_pink_2_physical = 1 if regexm(advantage_pink, "`exp'") 
	}

	gen advantage_pink_2_verbal = 0 	if advantage_pink_2 == 1
	foreach exp in 	"mechendo" "verbal" "moral" "cantadas" "abordagens"  ///
					"comentários" "comentario" "ouvir" {
					
		replace advantage_pink_2_verbal = 1 if regexm(advantage_pink, "`exp'") 
	} 
	
	* Option 3: less crowded
	foreach exp in 	"espaço" "vazio" "cheio" "lugar" "disponíve" "sent" {
					
		replace advantage_pink_3 = 1 if regexm(advantage_pink, "`exp'") 
	} 
	


	* Option 4: more safety
	foreach exp in 	"segur" "assalto" "medo" {
					
		replace advantage_pink_4 = 1 if regexm(advantage_pink, "`exp'") 
	} 
	
	
	* Adjustments
	replace advantage_pink_4 = 0 if inlist(advantage_pink, 	"a seguranca de ter menos homens  no horario de rush", ///
															"a segurança de só ter mulheres", ///
															"maior seguranca sobre o assedio de homens no trem.", ///
															"os homens nao podem sentar mas isso so acontece nas estacoes que tem seguranca")
	replace advantage_pink_2 = 1 if inlist(advantage_pink, 	"a segurança de só ter mulheres", ///
															"menos comtrangimento quando trem lotado semdo toadas mulheres", ///
															"mais segurança e conforto quanto ao estar muito próximas.", ///
															"quando ha apenas mulheres e mais confortável e adequado", ///
															"total vantagem mais tranquilidade e menos medo")
	replace advantage_pink_2 = 0 if inlist(advantage_pink, 	"homem nao entra pra disputar lugar para sentar", ///
															"nao acho que seja vantagem nenhuma. nao acho certo para as mulheres serem respeitadas nas viajem ter a necessidade de um vagão so para mulheres. levando em consideracão que em nosso pais o índice de mortaliade de homens e maior doque as mulheres ha muito mais mulheres. com isso 2 vagãos apenas nunca daria vazão pra todas viajarem de maneira confortável.", ///
															"nao existe vantagem... so funciona na estacao de partida.....nas demais estações essa regra não e respeitada!!!", ///
															"nao tem muita porque sempre tem homens", ///
															"nenhuma pq sempre esta cheio de homem", ///
															"nenhuma,pois não é respeitado", ///
															"porque na maioria das vezes os vagões femininos estão com mais homens do que mulheres.")
	replace advantage_pink_3 = 0 if inlist(advantage_pink, 	"nenhuma pq sempre esta cheio de homem", ///
															"nenhuma. e tao cheio quanto", ///
															"o fato de nao ter homens evita ser assediada no horario de rush que os vagoes estao muito cheios.", ///
															"quando esta cheio, nao tem nenhum homem estranho rocando em mim", ///
															"quando o trem esta cheio as mulheres dao ao vagao feminino para que não sejam assediado por alguns homens abusados")
	replace advantage_pink_1 = 0 if inlist(advantage_pink, 	"diminuição de comentários e situações desconfortáveis.", ///
															"nao acho que seja vantagem nenhuma. nao acho certo para as mulheres serem respeitadas nas viajem ter a necessidade de um vagão so para mulheres. levando em consideracão que em nosso pais o índice de mortaliade de homens e maior doque as mulheres ha muito mais mulheres. com isso 2 vagãos apenas nunca daria vazão pra todas viajarem de maneira confortável.")
	replace advantage_pink_0 = 1 if inlist(advantage_pink,	"nao acho que seja vantagem nenhuma. nao acho certo para as mulheres serem respeitadas nas viajem ter a necessidade de um vagão so para mulheres. levando em consideracão que em nosso pais o índice de mortaliade de homens e maior doque as mulheres ha muito mais mulheres. com isso 2 vagãos apenas nunca daria vazão pra todas viajarem de maneira confortável.", ///
															"nao existe vantagem... so funciona na estacao de partida.....nas demais estações essa regra não e respeitada!!!", ///
															"nao tem muita porque sempre tem homens", ///
															"nenhum", ///
															"nao ha preferencia", ///
															"nao vejo vantagem nenguma", ///
															"não tem")
	replace advantage_pink_2_physical = 0 if advantage_pink == "quando o trem esta cheio as mulheres dao ao vagao feminino para que não sejam assediado por alguns homens abusados"
	replace advantage_pink_2_physical = . if advantage_pink_2 == 0 
	replace advantage_pink_2_verbal = .   if advantage_pink_2 == 0 
	
	* Option 5: other
	replace advantage_pink_5 = 1 if !missing(advantage_pink) & ///
									!inlist(1,advantage_pink_0,advantage_pink_1,advantage_pink_2,advantage_pink_3,advantage_pink_4)
	

* -----------------------------------------------------------------------------*
* 							Disadvantages pink car
* -----------------------------------------------------------------------------*

	replace disadvantage_pink = trim(disadvantage_pink)
	replace disadvantage_pink = lower(disadvantage_pink)
	
	forvalues opCode = 0/8 {
		gen disadvantage_pink_`opCode' = 0 if !missing(disadvantage_pink)
	}
	
		
	* Option 0: None
	foreach exp in 	"nenhuma" "nao vej" "vantag" "nao ha" "nao teria" "nao existe" ///
					"enhma" "nao tem" {
	
		replace disadvantage_pink_0 = 1 if regexm(disadvantage_pink, "`exp'") 
	}
	
	* Option 1: Partner/male friend can not enter
	foreach exp in "namorado" "amigo" "marido" "pai" "conhecidos" "senhor" "esposo" "filho" {
	
		replace disadvantage_pink_1 = 1 if regexm(disadvantage_pink, "`exp'") 
	}
	
	* Option 2: Commotion between women
	foreach exp in 	"inimigas" "confus" "brig" "barulh" "barra" "bagun" "fala" ///
					"fofoca" "tumult" "mulher" "discu" "conversa" "descursoes" {
	
		replace disadvantage_pink_2 = 1 if regexm(disadvantage_pink, "`exp'") 
	}
	
	* Option 3: Male presence
	foreach exp in 	"home" "omens" "respeit" "lei" "100%" {
	
		replace disadvantage_pink_3 = 1 if regexm(disadvantage_pink, "`exp'") 
	}
	
	* Option 4: Less safe
	foreach exp in 	"assalt" "furt" "ajudar" {
	
		replace disadvantage_pink_4 = 1 if regexm(disadvantage_pink, "`exp'") 
	}
	
	* Option 5: Very crowded
	foreach exp in 	"lota" "cheio" "espaco" "lugar" "senta" "qtde" "suporta" ///
					"excesso" "cabe" {
	
		replace disadvantage_pink_5 = 1 if regexm(disadvantage_pink, "`exp'") 
	}
	
	* Option 6: Segregation
	foreach exp in 	"segreg" "iguai" "extremistas" "temporária" {
	
		replace disadvantage_pink_6 = 1 if regexm(disadvantage_pink, "`exp'") 
	}
	
	
	* Option 7: Too few cars
	foreach exp in 	"pouc" "50%" "apenas" {
	
		replace disadvantage_pink_7 = 1 if regexm(disadvantage_pink, "`exp'") 
	}
	
	* Option 8: Other
	foreach exp in 	"odor" "todas" "machismo" "revoltar" "repudio" "piadas" ///
					"preço" {
	
		replace disadvantage_pink_8 = 1 if regexm(disadvantage_pink, "`exp'") 
	}
	
	
	replace disadvantage_pink_3 = 1 if disadvantage_pink ==  "h"
	replace disadvantage_pink_8 = 1 if inlist(disadvantage_pink, "maioria dos outros ficaram super lotados", ///
																 "não poderá em outro vagão", ///
																 "ps homens acharem que os outros vagões sao exclusivamente deles." ///
																 "falta de organização e tranquilidade")
	replace disadvantage_pink_3 = 0 if inlist(disadvantage_pink, "os homens acharem que os outros vagões sao exclusivamente deles.", ///
																 "quando estivéssemos viajando com amigos homens", ///
																 "ser apenas um, tendo em vista que a populacao de mulheres sao maiores que os homens", ///
																 "acontecer alguma coisa no meio e precisar de homem para ajudar , ou ate mesmo alguém querer se aproveitar de se ter mulher e entrar para fazer alguma maldade durante a viagem .")
	replace disadvantage_pink_2 = 0 if inlist(disadvantage_pink, "apenas um vagão não comporta a qtde de mulheres", ///
																 "nao suporta tantas mulheres na hora do pico.", ///
																 "talvez mais assaltos por sere.m so mulheres no vagao", ///
																 "excesso de mulheres", ///
																 "acontecer alguma coisa no meio e precisar de homem para ajudar , ou ate mesmo alguém querer se aproveitar de se ter mulher e entrar para fazer alguma maldade durante a viagem .")
	replace disadvantage_pink_5 = 0 if inlist(disadvantage_pink, "maioria dos outros ficaram super lotados")
	replace disadvantage_pink_7 = 1 if inlist(disadvantage_pink, "a quantidade de vagões estritamente femininos é pequena em relação ao número total de vagões")
	replace disadvantage_pink_7 = 0 if inlist(disadvantage_pink, "quando os poucos homens desrespeitam o nosso vagão")
	replace disadvantage_pink_0 = 0 if inlist(1,disadvantage_pink_1,disadvantage_pink_2,disadvantage_pink_3,disadvantage_pink_4, ////
												disadvantage_pink_5,disadvantage_pink_6,disadvantage_pink_7,disadvantage_pink_8)
	replace disadvantage_pink_0 = 0 if inlist(disadvantage_pink, "nenhuma, uma vez que alguns homens nao conseguem respeitar.", ///
																 "desvantagens e por que varias v zes entram homens", ///
																 "muito falatorio, muitas briguinhas por lugar, empurra empurra p entrar no vagao, nao existe a diferenca assim como a prioridade.")

********************************************************************************
*						STEP 3: CLEAN MULTIPLE ENTRIES						   *
********************************************************************************

	*** check which contributors submitted the survey twice
	duplicates tag user_uuid, gen(dup)

	* rule: we keep pilot stage data if two surveys were done. If questions only present in baseline study survey -> copy to pilot survey entry 
	
	preserve
	
		keep if stage == 0 & dup == 1
		keep user_uuid nocomp_pref0 nocomp_pref5 nocomp_pref10 nocomp_pref15 nocomp_pref20 nocomp_pref30 nocomp_pref35 nocomp_pref65 nocomp_pref70 nocomp_pref180 ///
					fullcomp_pref0 fullcomp_pref5 fullcomp_pref10 fullcomp_pref20 fullcomp_pref30 fullcomp_pref35 fullcomp_pref65 fullcomp_pref70 fullcomp_pref180 ///
					comments_mixed grope_mixed comments_mixed_central comments_pink_central grope_mixed_central grope_pink_central
					
		tempfile baseline
		save	`baseline'
		
	restore
	
	* check which variables only have values for stage 0

	
	* Replace variables that were only present in basline
	merge m:1 user_uuid using `baseline', update
	
	* Only in pilot
	qui count if _merge == 1
	assert r(N) == 174
	
	* Same answer in both
	qui count if _merge == 3
	assert r(N) == 56
	
	* Updated missings
	qui count if _merge == 4
	assert r(N) == 2

	* Different answers across rounds
	qui count if _merge == 5
	assert r(N) == 54

	
	* drop baseline entry if two entries
	drop if stage == 0 & dup == 1
	drop dup _merge

	
********************************************************************************
*								STEP 5: SAVE DATA							   *
********************************************************************************

	iecodebook apply using "${doc_rider}/pooled/codebooks/pooled_exit.xlsx"

	compress
	
	save 				"${dt_final}/pooled_rider_audit_exit.dta", replace
	iemetasave using 	"${dt_final}/pooled_rider_audit_exit.txt", replace
	
*************************** End of do file *************************************
