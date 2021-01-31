# Project data map

## Data linkage table

| Data source | Dataset name | Unit of observation | ID variable | One to many ID | Many to one ID | Notes |
|-------------|--------------|---------------------|-------------|----------------|----------------|-------|
| Rider audits - first wave | baseline_raw_deidentified.dta | rider - ride - task |  obs_uid |
| Platform observations - first wave | baseline_mapping.dta | observer - data - time bin - station bin |
| Rider audits - second wave | compliance_pilot_deidentified.dta | rider - ride - task |
| Platform observations - second wave | compliance_pilot_mapping.dta |  observer - data - time bin - station bin |
| Supervia congestion data | congestion_raw.dta | year - month - hour - line - start station - end station |
| [Instituto de Segurança Pública do Rio de Janeiro](https://www.ispdados.rj.gov.br:4432/) | crime_rates_bystation.dta | station |
| Platform survey | platform_survey_raw.dta | respondent |
| Implicit association test | iat_career_alldata.txt <br> iat_security_alldata.txt <br> iat_reputation_alldata.txt | respondent | 
| Implicit association test | iat_career_scoresonly.txt <br> iat_security_scoresonly.txt <br> iat_reputation_scoresonly.txt | respondent - block - sitmulus |
