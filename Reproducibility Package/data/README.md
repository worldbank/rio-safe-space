# Demand for "Safe Spaces": Avoiding Harassment and Stigma - Data

In this folder, you will find *metadata* on the raw, intermediate and analysis datasets used in the paper. The data files used are available in the [Microdata Catalogue, under the survey ID number BRA_2015-2016_DSS_v01_M](https://microdatalib.worldbank.org/index.php/catalog/11600). 
# Project data map

## Data Linkage Table

### Rides data

#### List of data sets

| Data source | Dataset name | Unit of observation (ID var) | Parent unit (parent ID) |
|-------------|--------------|------------------------------|-------------------------|
| Rider audits <br> First wave | baseline_raw_deidentified.dta | task (`obs_uid`) | rider (`user_uuid`) <br> ride (`session_id`) |
| Platform observations <br> First wave | baseline_mapping.dta | task (`obs_uuid`) | station (`station_bin`) <br> time (`time_bin`) |
| Rider audits <br> Second wave | compliance_pilot_deidentified.dta | task (`obs_uuid`) | rider (`user_uuid`) <br> ride (`session_id`) |
| Platform observations <br> second wave | compliance_pilot_mapping.dta |   task (`obs_uuid`) | station (`station_bin`) <br> time (`time_bin`) |

### Platform survey

#### List of data sets

The main unit of observation in the datasets is the survey respondent, which is identified by the variable id. The raw data is imported as 7 different datasets from two different sources. The first source is the platform survey, which was collected through an ODK platform. These are downloaded in CSV format and imported into a single Stata dataset with one row per respondent.

The implicit association tests were collected through an online platform specializing in IATs. It outputs two datasets for each IAT instrument: one dataset at respondent level, containing the time and score for each block plus the overall time and score; and one dataset that lists the respondent ID, the block, the response time for each stimulus, and whether the respondent made the correct association for each stimulus. Both datasets are exported from the IAT platform in txt format, and need to be parsed in the statistical software.

| Data source | Dataset name | Unit of observation (ID var) | Parent unit (parent ID) |
|-------------|--------------|------------------------------|-------------------------|
| Platform survey | platform_survey_raw_deidentified.dta | respondent (`id`) | |
| Implicit association test | career_stimuli.dta <br> security_stimuli.dta <br> reputation_stimuli.dta | stimulus | respondent (`id`) <br> block | 
| Implicit association test | career_score.dta <br> security_score.dta <br> reputation_score.dta | respondent (`id`) | |

## Data flow chart

![Data flow chart](https://user-images.githubusercontent.com/15911801/114495791-b834fe80-9bec-11eb-8d92-6ca6c2bfc79c.png)

##
<div class = "row">
  <div class = "column" style = "width:30%">
    <img src="https://github.com/worldbank/rio-safe-space/blob/master/img/wb.png" align = "left">
  </div>
  <div class = "column" style = "width:30%">
    <img src="https://github.com/worldbank/rio-safe-space/blob/master/img/i2i.png" align = "right">
  </div>
</div>
