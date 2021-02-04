
	* Encode line to create factor variable
	* -----------------------------------------
		
		gen 	lineCode = .

		replace lineCode = 1 if lineVar == "Ramal Deodoro"
		replace lineCode = 2 if lineVar == "Ramal Santa Cruz"
		replace lineCode = 3 if lineVar == "Ramal Japeri"
		replace lineCode = 4 if lineVar == "Ramal Belford Roxo"
		replace lineCode = 5 if lineVar == "Ramal Saracuruna"
		replace	lineCode = 6 if lineVar == "Ramal Paracambi"
		replace	lineCode = 7 if lineVar == "Teleférico"
		replace	lineCode = 8 if lineVar == "Ramal Guapimirim"
		replace	lineCode = 9 if lineVar == "Ramal Vila Inhomirim"
		
		lab def line 		1 "Ramal Deodoro" ///
							2 "Ramal Santa Cruz" ///
							3 "Ramal Japeri" ///
							4 "Ramal Belford Roxo" ///
							5 "Ramal Saracuruna" ///
							6 "Ramal Paracambi" ///
							7 "Teleférico" ///
							8 "Ramal Guapimirim" ///
							9 "Ramal Vila Inhomirim", replace
						
		lab val	lineCode	line
		
		
	* Encode stations to create factor variable
	* -----------------------------------------
	
		gen stationCode = .
	
	* Ramal Deodoro 
					
		replace stationCode = 101 if stationVar == "Central do Brasil" & lineVar == "Ramal Deodoro"
		replace stationCode = 102 if stationVar == "Praca da Bandeira" & lineVar == "Ramal Deodoro"
		replace stationCode = 102 if stationVar == "Praça da Bandeira" & lineVar == "Ramal Deodoro"
		replace stationCode = 103 if stationVar == "Sao Cristovao" & lineVar == "Ramal Deodoro"
		replace stationCode = 103 if stationVar == "São Cristóvão" & lineVar == "Ramal Deodoro"
		replace stationCode = 104 if stationVar == "Maracana" & lineVar == "Ramal Deodoro"
		replace stationCode = 104 if stationVar == "Maracanã" & lineVar == "Ramal Deodoro"
		replace stationCode = 105 if stationVar == "Mangueira" & lineVar == "Ramal Deodoro"
		replace stationCode = 106 if stationVar == "Sao Francisco Xavier" & lineVar == "Ramal Deodoro"
		replace stationCode = 106 if stationVar == "São Francisco Xavier" & lineVar == "Ramal Deodoro"
		replace stationCode = 107 if stationVar == "Riachuelo" & lineVar == "Ramal Deodoro"
		replace stationCode = 108 if stationVar == "Sampaio" & lineVar == "Ramal Deodoro"
		replace stationCode = 109 if stationVar == "Engenho Novo" & lineVar == "Ramal Deodoro"
		replace stationCode = 110 if stationVar == "Meier" & lineVar == "Ramal Deodoro"
		replace stationCode = 110 if stationVar == "Méier" & lineVar == "Ramal Deodoro"
		replace stationCode = 111 if stationVar == "Estacao Olimpica de Engenho de Dentro" & lineVar == "Ramal Deodoro"
		replace stationCode = 111 if stationVar == "Estação Olímpica de Engenho de Dentro" & lineVar == "Ramal Deodoro"
		replace stationCode = 112 if stationVar == "Piedade" & lineVar == "Ramal Deodoro"
		replace stationCode = 113 if stationVar == "Quintino" & lineVar == "Ramal Deodoro"
		replace stationCode = 114 if stationVar == "Cascadura" & lineVar == "Ramal Deodoro"
		replace stationCode = 115 if stationVar == "Madureira" & lineVar == "Ramal Deodoro"
		replace stationCode = 116 if stationVar == "Oswaldo Cruz" & lineVar == "Ramal Deodoro"
		replace stationCode = 117 if stationVar == "Bento Ribeiro" & lineVar == "Ramal Deodoro"
		replace stationCode = 118 if stationVar == "Marechal Hermes" & lineVar == "Ramal Deodoro"
		replace stationCode = 119 if stationVar == "Deodoro" & lineVar == "Ramal Deodoro"	

		
	* Ramal Santa Cruz

		replace stationCode = 201  if stationVar == "Central do Brasil" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 202  if stationVar == "Sao Cristovao" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 202  if stationVar == "São Cristóvão" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 203  if stationVar == "Maracana" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 203  if stationVar == "Maracanã" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 204  if stationVar == "Sao Francisco Xavier" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 204  if stationVar == "São Francisco Xavier" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 205  if stationVar == "Silva Freire" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 206  if stationVar == "Estacao Olimpica de Engenho de Dentro" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 207  if stationVar == "Madureira" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 208  if stationVar == "Deodoro" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 209  if stationVar == "Vila Militar" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 210  if stationVar == "Magalhaes Bastos" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 210  if stationVar == "Magalhães Bastos" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 211  if stationVar == "Realengo" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 212  if stationVar == "Padre Miguel" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 213  if stationVar == "Guilherme da Silveira" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 214  if stationVar == "Bangu" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 215  if stationVar == "Senador Camara" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 215  if stationVar == "Senador Camará" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 216  if stationVar == "Santissimo" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 216  if stationVar == "Santíssimo" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 217  if stationVar == "Augusto Vasconcelos" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 218  if stationVar == "Campo Grande" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 219  if stationVar == "Benjamin do Monte" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 219  if stationVar == "Benjamim do Monte" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 220  if stationVar == "Inhoaiba" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 220  if stationVar == "Inhoaíba" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 221  if stationVar == "Cosmos" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 222  if stationVar == "Paciencia" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 222  if stationVar == "Paciência" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 223  if stationVar == "Tancredo Neves" & lineVar == "Ramal Santa Cruz"
		replace stationCode = 224  if stationVar == "Santa Cruz" & lineVar == "Ramal Santa Cruz"	
	
	* Ramal Japeri
	
		replace stationCode = 301  if stationVar == "Central do Brasil" & lineVar == "Ramal Japeri"
		replace stationCode = 302  if stationVar == "Sao Cristovao" & lineVar == "Ramal Japeri"
		replace stationCode = 302  if stationVar == "São Cristóvão" & lineVar == "Ramal Japeri"
		replace stationCode = 303  if stationVar == "Maracana" & lineVar == "Ramal Japeri"
		replace stationCode = 303  if stationVar == "Maracanã" & lineVar == "Ramal Japeri"
		replace stationCode = 304  if stationVar == "Silva Freire" & lineVar == "Ramal Japeri"
		replace stationCode = 305  if stationVar == "Estacao Olimpica de Engenho de Dentro" & lineVar == "Ramal Japeri"
		replace stationCode = 306  if stationVar == "Madureira" & lineVar == "Ramal Japeri"
		replace stationCode = 307  if stationVar == "Deodoro" & lineVar == "Ramal Japeri"
		replace stationCode = 308  if stationVar == "Ricardo de Albuquerque" & lineVar == "Ramal Japeri"
		replace stationCode = 309  if stationVar == "Anchieta" & lineVar == "Ramal Japeri"
		replace stationCode = 310  if stationVar == "Olinda" & lineVar == "Ramal Japeri"
		replace stationCode = 311  if stationVar == "Nilopolis" & lineVar == "Ramal Japeri"
		replace stationCode = 311  if stationVar == "Nilópolis" & lineVar == "Ramal Japeri"
		replace stationCode = 312  if stationVar == "Edson Passos" & lineVar == "Ramal Japeri"
		replace stationCode = 313  if stationVar == "Mesquita" & lineVar == "Ramal Japeri"
		replace stationCode = 314  if stationVar == "Presidente Juscelino" & lineVar == "Ramal Japeri"
		replace stationCode = 315  if stationVar == "Nova Iguacu" & lineVar == "Ramal Japeri"
		replace stationCode = 315  if stationVar == "Nova Iguaçu" & lineVar == "Ramal Japeri"
		replace stationCode = 316  if stationVar == "Comendador Soares" & lineVar == "Ramal Japeri"
		replace stationCode = 317  if stationVar == "Austin" & lineVar == "Ramal Japeri"
		replace stationCode = 318  if stationVar == "Queimados" & lineVar == "Ramal Japeri"
		replace stationCode = 319  if stationVar == "Engenheiro Pedreira" & lineVar == "Ramal Japeri"
		replace stationCode = 320  if stationVar == "Japeri" & lineVar == "Ramal Japeri"
	
	
	* Ramal Belford Roxo
	
		replace stationCode = 401  if stationVar == "Central do Brasil" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 402  if stationVar == "Sao Cristovao" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 402  if stationVar == "São Cristóvão" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 403  if stationVar == "Maracana" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 403  if stationVar == "Maracanã" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 404  if stationVar == "Triagem" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 405  if stationVar == "Jacarezinho" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 406  if stationVar == "Del Castilho" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 407  if stationVar == "Pilares" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 408  if stationVar == "Tomas Coelho" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 408  if stationVar == "Tomás Coelho" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 408  if stationVar == "TomⳠCoelho" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 409  if stationVar == "Cavalcanti" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 410  if stationVar == "Mercadao de Madureira" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 410  if stationVar == "Mercadão de Madureira" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 411  if stationVar == "Rocha Miranda" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 412  if stationVar == "Honorio Gurgel" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 412  if stationVar == "Honório Gurgel" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 413  if stationVar == "Barros Filho" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 414  if stationVar == "Costa Barros" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 415  if stationVar == "S.J de Meriti / Pavuna" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 416  if stationVar == "Vila Rosali" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 417  if stationVar == "Agostinho Porto" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 418  if stationVar == "Coelho da Rocha" & lineVar == "Ramal Belford Roxo"
		replace stationCode = 419  if stationVar == "Belford Roxo" & lineVar == "Ramal Belford Roxo"
		

	* Ramal Saracuruna
				
		replace stationCode = 501  if stationVar == "Central do Brasil" & lineVar == "Ramal Saracuruna"
		replace stationCode = 502  if stationVar == "Sao Cristovao" & lineVar == "Ramal Saracuruna"
		replace stationCode = 502  if stationVar == "São Cristóvão" & lineVar == "Ramal Saracuruna"
		replace stationCode = 503  if stationVar == "Maracanã" & lineVar == "Ramal Saracuruna"
		replace stationCode = 503  if stationVar == "Maracana" & lineVar == "Ramal Saracuruna"
		replace stationCode = 504  if stationVar == "Triagem" & lineVar == "Ramal Saracuruna"
		replace stationCode = 505  if stationVar == "Manguinhos" & lineVar == "Ramal Saracuruna"
		replace stationCode = 506  if stationVar == "Bonsucesso" & lineVar == "Ramal Saracuruna"
		replace stationCode = 507  if stationVar == "Ramos" & lineVar == "Ramal Saracuruna"
		replace stationCode = 508  if stationVar == "Olaria" & lineVar == "Ramal Saracuruna"
		replace stationCode = 509  if stationVar == "Penha" & lineVar == "Ramal Saracuruna"
		replace stationCode = 510  if stationVar == "Penha Circular" & lineVar == "Ramal Saracuruna"
		replace stationCode = 511  if stationVar == "Bras de Pina" & lineVar == "Ramal Saracuruna"
		replace stationCode = 511  if stationVar == "Brás de Pina" & lineVar == "Ramal Saracuruna"
		replace stationCode = 512  if stationVar == "Cordovil" & lineVar == "Ramal Saracuruna"
		replace stationCode = 513  if stationVar == "Parada de Lucas" & lineVar == "Ramal Saracuruna"
		replace stationCode = 514  if stationVar == "Vigario Geral" & lineVar == "Ramal Saracuruna"
		replace stationCode = 514  if stationVar == "Vigário Geral" & lineVar == "Ramal Saracuruna"
		replace stationCode = 515  if stationVar == "Duque de Caxias" & lineVar == "Ramal Saracuruna"
		replace stationCode = 516  if stationVar == "Corte 8" & lineVar == "Ramal Saracuruna"
		replace stationCode = 517  if stationVar == "Gramacho" & lineVar == "Ramal Saracuruna"
		replace stationCode = 518  if stationVar == "Campos Eliseos" & lineVar == "Ramal Saracuruna"
		replace stationCode = 519  if stationVar == "Jardim Primavera" & lineVar == "Ramal Saracuruna"
		replace stationCode = 520  if stationVar == "Saracuruna" & lineVar == "Ramal Saracuruna"

	* Ramal Paracambi
				
		replace stationCode = 601  if stationVar == "Central do Brasil" & lineVar == "Ramal Paracambi"
		replace stationCode = 602  if stationVar == "Sao Cristovao" & lineVar == "Ramal Paracambi"
		replace stationCode = 602  if stationVar == "São Cristóvão" & lineVar == "Ramal Paracambi"
		replace stationCode = 603  if stationVar == "Maracana" & lineVar == "Ramal Paracambi"
		replace stationCode = 603  if stationVar == "Maracanã" & lineVar == "Ramal Paracambi"
		replace stationCode = 604  if stationVar == "Silva Freire" & lineVar == "Ramal Paracambi"
		replace stationCode = 605  if stationVar == "Madureira" & lineVar == "Ramal Paracambi"
		replace stationCode = 606  if stationVar == "Deodoro" & lineVar == "Ramal Paracambi"
		replace stationCode = 607  if stationVar == "Ricardo de Albuquerque" & lineVar == "Ramal Paracambi"
		replace stationCode = 608  if stationVar == "Anchieta" & lineVar == "Ramal Paracambi"
		replace stationCode = 609  if stationVar == "Olinda" & lineVar == "Ramal Paracambi"
		replace stationCode = 610  if stationVar == "Nilopolis" & lineVar == "Ramal Paracambi"
		replace stationCode = 611  if stationVar == "Edson Passos" & lineVar == "Ramal Paracambi"
		replace stationCode = 612  if stationVar == "Mesquita" & lineVar == "Ramal Paracambi"
		replace stationCode = 613  if stationVar == "Presidente Juscelino" & lineVar == "Ramal Paracambi"
		replace stationCode = 614  if stationVar == "Nova Iguacu" & lineVar == "Ramal Paracambi"
		replace stationCode = 614  if stationVar == "Nova Iguaçu" & lineVar == "Ramal Paracambi"
		replace stationCode = 615  if stationVar == "Comendador Soares" & lineVar == "Ramal Paracambi"
		replace stationCode = 616  if stationVar == "Austin" & lineVar == "Ramal Paracambi"
		replace stationCode = 617  if stationVar == "Queimados" & lineVar == "Ramal Paracambi"
		replace stationCode = 618  if stationVar == "Engenheiro Pedreira" & lineVar == "Ramal Paracambi"
		replace stationCode = 619  if stationVar == "Japeri" & lineVar == "Ramal Paracambi"
		replace stationCode = 620  if stationVar == "Lages" & lineVar == "Ramal Paracambi"
		replace stationCode = 621  if stationVar == "Paracambi" & lineVar == "Ramal Paracambi"
		
	
	* Teleferico
	
		replace stationCode = 701  if stationVar == "Bonsucesso" & inlist(lineVar,"Teleférico","Teleferico")
		replace stationCode = 702  if stationVar == "Adeus" & inlist(lineVar,"Teleférico","Teleferico")
		replace stationCode = 703  if stationVar == "Baiana" & inlist(lineVar,"Teleférico","Teleferico")
		replace stationCode = 704  if stationVar == "Alemao" & inlist(lineVar,"Teleférico","Teleferico")
		replace stationCode = 704  if stationVar == "Alemão" & inlist(lineVar,"Teleférico","Teleferico")
		replace stationCode = 705  if stationVar == "Itarare" & inlist(lineVar,"Teleférico","Teleferico")
		replace stationCode = 706  if stationVar == "Palmeiras" & inlist(lineVar,"Teleférico","Teleferico")
		
		
	* Ramal Vila Inhomirim
	
		replace stationCode = 901  if stationVar == "Central do Brasil" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 902  if stationVar == "Sao Cristovao" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 902  if stationVar == "São Cristóvão" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 903  if stationVar == "Maracana" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 903  if stationVar == "Maracanã" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 904  if stationVar == "Triagem" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 905  if stationVar == "Manguinhos" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 906  if stationVar == "Bonsucesso" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 907  if stationVar == "Ramos" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 908  if stationVar == "Olaria" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 909  if stationVar == "Penha" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 910  if stationVar == "Penha Circular" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 911  if stationVar == "Bras de Pina" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 911  if stationVar == "Brás de Pina" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 912  if stationVar == "Cordovil" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 913  if stationVar == "Parada de Lucas" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 914  if stationVar == "Vigario Geral" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 914  if stationVar == "Vigário Geral" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 915  if stationVar == "Duque de Caxias" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 916  if stationVar == "Corte 8" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 917  if stationVar == "Gramacho" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 918  if stationVar == "Campos Eliseos" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 919  if stationVar == "Jardim Primavera" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 920  if stationVar == "Saracuruna" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 921  if stationVar == "Morabi" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 922  if stationVar == "Imbarie" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 922  if stationVar == "Imbariê" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 923  if stationVar == "Manoel Belo" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 924  if stationVar == "Parada Angelica" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 924  if stationVar == "Parada Angélica" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 925  if stationVar == "Piabetá" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 926  if stationVar == "Fragoso" & lineVar == "Ramal Vila Inhomirim"
		replace stationCode = 927  if stationVar == "Vila Inhomirim" & lineVar == "Ramal Vila Inhomirim"
