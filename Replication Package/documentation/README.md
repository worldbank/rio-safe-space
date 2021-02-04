# Project data map

## Rides data

### List of data sets

| Data source | Dataset name | Unit of observation (ID var) | Parent unit (parent ID) |
|-------------|--------------|------------------------------|-------------------------|
| Rider audits <br> First wave | baseline_raw_deidentified.dta | task (`obs_uid`) | rider (`user_uuid`) <br> ride (`session_id`) |
| Platform observations <br> First wave | baseline_mapping.dta | task (`obs_uuid`) | station (`station_bin`) <br> time (`time_bin`) |
| Rider audits <br> Second wave | compliance_pilot_deidentified.dta | task (`obs_uuid`) | rider (`user_uuid`) <br> ride (`session_id`) |
| Platform observations <br> second wave | compliance_pilot_mapping.dta |   task (`obs_uuid`) | station (`station_bin`) <br> time (`time_bin`) |

### Master datasets

| Name | Level | ID var | List of vars |
|------|-------|--------|--------------|
| rider-master.dta | Rider | `user_uuid` | `in_baseline` `in_pilot` |
| stations-master.dta | Station | `station` | `station` `line` `station_bin` |

### Data flowchart

## Platform survey

### List of data sets

| Data source | Dataset name | Unit of observation (ID var) | Parent unit (parent ID) |
|-------------|--------------|------------------------------|-------------------------|
| Platform survey | platform_survey_raw_deidentified.dta | respondent (`id`) | |
| Implicit association test | icareer_stimuli.dta <br> security_stimuli.dta <br> reputation_stimuli.dta | stimulus | respondent (`id`) <br> block | 
| Implicit association test | career_score.dta <br> security_score.dta <br> reputation_score.dta | respondent (`id`) | |

### Data flowchart
