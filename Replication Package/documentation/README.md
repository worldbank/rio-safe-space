# Project data map

## Data linkage table

| Data source | Dataset name | Unit of observation | ID variable | External keys | Notes |
|-------------|--------------|---------------------|-------------| --------------|-------|
| Rider audits <br> First wave | baseline_raw_deidentified.dta | rider <br> ride <br> task |  `obs_uid` | `user_uuid` <br> `spectranslated` <br> `campaign_id` <br> `user_line` <br> `user_station` |
| Platform observations <br> First wave | baseline_mapping.dta | observer <br> data <br> time bin <br> station bin | `obs_uuid` | `station_bin` <br> `time_bin` |
| Rider audits <br> Second wave | compliance_pilot_deidentified.dta | rider <br> ride <br> task | `obs_uuid` | `user_uuid` <br> `spectranslated` <br> `campaign_id` <br> `user_line` <br> `user_station` |
| Platform observations - second wave | compliance_pilot_mapping.dta |  observer - data - time bin - station bin |
| Supervia congestion data | congestion_raw.dta | year - month - hour - line - start station - end station |
| [Instituto de Segurança Pública do Rio de Janeiro](https://www.ispdados.rj.gov.br:4432/) | crime_rates_bystation.dta | station |
| Platform survey | platform_survey_raw.dta | respondent |
| Implicit association test | iat_career_alldata.txt <br> iat_security_alldata.txt <br> iat_reputation_alldata.txt | respondent | 
| Implicit association test | iat_career_scoresonly.txt <br> iat_security_scoresonly.txt <br> iat_reputation_scoresonly.txt | respondent - block - sitmulus |
