# Demand for "Safe Spaces": Avoiding Harassment and Stigma

This folder contains the replication package for the Working Paper "Demand for 'Safe Spaces': Avoiding Harassment and Stigma" by Florence Kondylis, Arianna Legovini, Kate Vyborny, Astrid Zwager, and Luiza Andrade.

## Data
In this folder, you will find *metadata* on the raw, intermediate and analysis datasets used in the paper. The data files used area available in the [Microdata Catalogue, under the survey ID number BRA_2015-2016_DSS_v01_M](https://microdatalib.worldbank.org/index.php/catalog/11600). 
# Project data map

## Data Map

### Rides data

#### List of data sets

| Data source | Dataset name | Unit of observation (ID var) | Parent unit (parent ID) |
|-------------|--------------|------------------------------|-------------------------|
| Rider audits <br> First wave | baseline_raw_deidentified.dta | task (`obs_uid`) | rider (`user_uuid`) <br> ride (`session_id`) |
| Platform observations <br> First wave | baseline_mapping.dta | task (`obs_uuid`) | station (`station_bin`) <br> time (`time_bin`) |
| Rider audits <br> Second wave | compliance_pilot_deidentified.dta | task (`obs_uuid`) | rider (`user_uuid`) <br> ride (`session_id`) |
| Platform observations <br> second wave | compliance_pilot_mapping.dta |   task (`obs_uuid`) | station (`station_bin`) <br> time (`time_bin`) |

#### Master datasets

| Name | Level | ID var | List of vars |
|------|-------|--------|--------------|
| rider-master.dta | Rider | `user_uuid` | `in_baseline` `in_pilot` |
| stations-master.dta | Station | `station` | `station` `line` `station_bin` |

### Platform survey

#### List of data sets

| Data source | Dataset name | Unit of observation (ID var) | Parent unit (parent ID) |
|-------------|--------------|------------------------------|-------------------------|
| Platform survey | platform_survey_raw_deidentified.dta | respondent (`id`) | |
| Implicit association test | icareer_stimuli.dta <br> security_stimuli.dta <br> reputation_stimuli.dta | stimulus | respondent (`id`) <br> block | 
| Implicit association test | career_score.dta <br> security_score.dta <br> reputation_score.dta | respondent (`id`) | |

##
<div class = "row">
  <div class = "column" style = "width:30%">
    <img src="https://github.com/worldbank/rio-safe-space/blob/master/img/wb.png" align = "left">
  </div>
  <div class = "column" style = "width:30%">
    <img src="https://github.com/worldbank/rio-safe-space/blob/master/img/i2i.png" align = "right">
  </div>
</div>
