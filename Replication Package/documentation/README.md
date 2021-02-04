# Project data map

## Data linkage table

| Data source | Dataset name | Unit of observation (ID var) | Parent unit (parent ID) |
|-------------|--------------|------------------------------|-------------------------|
| Rider audits <br> First wave | baseline_raw_deidentified.dta | task (`obs_uid`) | rider (`user_uuid`) <br> ride (`session_id`) |
| Platform observations <br> First wave | baseline_mapping.dta | task (`obs_uuid`) | station `station_bin` <br> time (`time_bin`) |
| Rider audits <br> Second wave | compliance_pilot_deidentified.dta | task (`obs_uuid`) | rider (`user_uuid`) <br> ride (`session_id`) |
| Platform observations <br> second wave | compliance_pilot_mapping.dta |  observer - data - time bin - station bin |
| Platform survey | platform_survey_raw_deidentified.dta | respondent (`id`) | |
| Implicit association test | iat_career_alldata.txt <br> iat_security_alldata.txt <br> iat_reputation_alldata.txt | stimulus | respondent (`id`) <br> block | 
| Implicit association test | iat_career_scoresonly.txt <br> iat_security_scoresonly.txt <br> iat_reputation_scoresonly.txt | respondent (`id`) | |
