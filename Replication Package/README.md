# Demand for "Safe Spaces": Avoiding Harassment and Stigma

This folder contains the replication package for the Working Paper "Demand for 'Safe Spaces': Avoiding Harassment and Stigma" by Florence Kondylis, Arianna Legovini, Kate Vyborny, Astrid Zwager, and Luiza Andrade.

If you run into any troubles running this code or reproducing results, please [create an `Issue`](https://github.com/worldbank/rio-safe-space/issues/new) in this repository.

### License for Code

The code is licensed under a Creative Commons license. See [LICENSE](https://github.com/worldbank/rio-safe-space/blob/master/Replication%20Package/LICENSE) for details.


Computational requirements
---------------------------

### Software Requirements

- Stata (code was last run with version 16)
  - `estout` (3.23)
  - `iefieldkit` (2.0)
  - `ietoolkit` (6.3)
  - `unique` (1.2.4)
  - `coefplot` (1.8.3)
  - the program "`MASTER.do`" will install all dependencies locally if the local `packages` in line 30 is set to 1.

### Memory and Runtime Requirements

- The code was last run on a **Windows 10 laptop with 16GB of RAM**. 
- Stata analysis code takes apprixmately 5 minutes to run.

Instructions to Replicators
---------------------------

The code to reproduce the results included in the working paper. To recreate the outputs, follow the steps below
1. Click on the green button `Clone or download` shown above the list of files in this folder to download a local copy of this repository
1. Open the downloaded folder and navigate to `rio-safe-space/Replication Package`.
1. The data used for this paper is available in the [Microdata Catalogue, under the survey ID number BRA_2015-2016_DSS_v01_M](https://microdatalib.worldbank.org/index.php/catalog/11600). Copy this data to the `data` folder.
1. On the folder `rio-safe-space/Replication Package`, you will see two scripts called `MASTER`: one in R, one in Stata.
1. To run the Stata `MASTER`, open it and edit line 23 to reflect the path of the repository copy in your computer. This do-file creates all the non-map tables and graphs included in the working paper. You may need to install some of the user-written packages the code uses before it runs. To do so, modify line 29 by replacing `0` with `1`. This only needs to be done once in every computer.
1. To run the R `MASTER`, open it and edit line 52. The only package needed to run the code is `pacman`. If you don't have this package installed, uncomment line 29. As before, running this line once in a new computer is enough. This code will recreate the maps included in the paper
1. The outputs will be recreated in `rio-safe-space/Replication Package/outputs` folder. The only output that cannot be reproduced is figure A1. Personally identifying information is necessary to recreate this graph, so the package contains only the code for transparency.

List of analysis codes and outputs
-------------------------------

The provided code reproduces all numbers provided in text in the paper and all tables and figures in the paper, with the exception of Figure A1. Reproducing figure A1 requires access to identified data on riders home location (bolded dataset below.

All analysis code is stored in `dofiles/analysis/paper`. All outputs are saved to `outputs`. All the code can be run from the `Master.do` script, but the code to recreate each exhibit can also be run independently, as long as the folder globals and custom programs are set using the master.

| Exhibit    | Input dataset | Program | Output file |
|------------|---------------|---------|-------------|
| Numbers in text | pooled_rider_audit_constructed.dta <br> platform_survey_constructed.dta | Numbers in main text.do |  |
| Figure 2 | pooled_rider_audit_constructed.dta | graphs/eventstudy_bypremium.do | graphs/eventstudy_bypremium.png |
| Figure 3 | pooled_rider_audit_constructed.dta | graphs/takeup.do | graphs/takeup_fe.png <br> graphs/takeup_person.png |
| Figure 4 | pooled_rider_audit_constructed.dta | graphs/wtp_harass.do | graphs/wtp_harass.png |
| Figure 5 | platform_survey_constructed.dta | graphs/iatscores.do | graphs/IAT_safety.png	 <br> graphs/IAT_advances.png <br> graphs/IAT_men.png <br> graphs/IAT_women.png |
| Table 1 | pooled_rider_audit_constructed.dta | tables/balance_table.do | tables/balance_table.tex |
| Table 3 | pooled_rider_audit_constructed.dta | tables/carimpactharassment.do | tables/paper_carimpactharassment_main.tex |
| Table 4 | pooled_rider_audit_constructed.dta | tables/wtprisk.do | tables/paper_wtprisk.tex  |
| Table 5 | pooled_rider_audit_constructed_full.dta |  tables/pooled_rider_audit_constructed_full.dta | tables/back_envelope_costs_full.tex  |
| Figure A1 | **users_homes.csv** <br> supervia_stations.shp <br> supervia-lines-and-stations.csv | maps/ramais-and-homes.R | maps/ramais-and-homes.pdf |
| Figure A2 | pooled_mapping.dta <br> congestion_station_level.dta | graphs/loadfactor.do | graphs/loadfactor.png |
| Figure A3 | pooled_mapping.dta | graphs/mappingcompliancebycar.do  | graphs/mappingcompliancebycar.png <br> graphs/mappingcompliancebycar.png |
| Figure A4 | maps_data.rds | maps/compliance.R | maps/compliance.pdf |
| Figure A5 | pooled_mapping.dta | graphs/diffcompliance.do | graphs/diffcompliance.png |
| Figure A6 | pooled_rider_audit_constructed.dta | graphs/takeupandcongestion.do | graphs/takeupandcongestion.png |
| Figure A7 | pooled_rider_audit_constructed.dta | graphs/eventstudy.do | graphs/eventstudy.png <br> eventstudy_hist.png |
| Figure A8 | pooled_rider_audit_constructed.dta | graphs/advantagespinkcar.do | graphs/advantages_pink_car.png |
| Figure A9 | pooled_rider_audit_constructed.dta | graphs/statedrevealed3.do | graphs/statedrevealed3.png |
| Figure A10 | pooled_rider_audit_constructed.dta | graphs/selection.do | graphs/paper_selection.png |
| Figure A11 | platform_survey_constructed.dta | graphs/beliefs.do | graphs/beliefs.png |
| Table A1 | pooled_rider_audit_constructed.dta <br> platform_survey_constructed.dta | tables/sample_table.do | tables/sample_table.tex |
| Table A3 | pooled_rider_audit_constructed.dta | tables/mappingridercorr.do | tables/mappingridercorr.tex |
| Table A4 | platform_survey_constructed.dta | tables/response.do | tables/response.tex  |
| Table A5 | platform_survey_constructed.dta | tables/priming.do | tables/priming.tex |
| Table A6 | platform_survey_constructed.dta | tables/order.do | tables/order.tex |
| Table A7 | pooled_rider_audit_constructed.dta | tables/adjustment.do | tables/adjustment.tex |
| Table A8 | pooled_rider_audit_constructed.dta | tables/wellbeing.do | tables/paper_wellbeing_main.tex |
| Table A9 | platform_survey_constructed.dta | tables/genderdescriptives.do | tables/genderdescriptives.tex |
| Table A10 | platform_survey_constructed.dta | tables/mainiat.do | tables/mainiat.tex <br> graphs/presentation_iat_coef.png |
| Table D1 | pooled_rider_audit_constructed_full.dta | tables/attrition.do | tables/attrition.tex |
| Figure D1 | pooled_rider_audit_constructed.dta | graphs/takeup_person_bound.do | graphs/takeup_person_bound.png |
| Table D2 | pooled_rider_audit_phase3_offers.dta | tables/phase3participation.do | tables/phase3participation.tex |

---
##
<div class = "row">
  <div class = "column" style = "width:30%">
    <img src="https://github.com/worldbank/rio-safe-space/blob/master/img/wb.png" align = "left">
  </div>
  <div class = "column" style = "width:30%">
    <img src="https://github.com/worldbank/rio-safe-space/blob/master/img/i2i.png" align = "right">
  </div>
</div>
