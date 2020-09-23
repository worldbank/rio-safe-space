# Demand for "Safe Spaces": Avoiding Harassment and Stigma

This folder contains the replication package for the Working Paper "Demand for 'Safe Spaces': Avoiding Harassment and Stigma" by Florence Kondylis, Arianna Legovini, Kate Vyborny, Astrid Zwager, and Luiza Andrade.

## Replication package
The code to reproduce the results included in the working paper. To recreate the outputs, follow the steps below
1. Click on the green button `Clone or download` shown above the list of files in this folder to download a local copy of this repository
1. Open the downloaded folder and navigate to `rio-safe-space/Replication Package`.
1. The data used for this paper is available in the [Microdata Catalogue, under the survey ID number BRA_2015-2016_DSS_v01_M](https://microdatalib.worldbank.org/index.php/catalog/11600). Copy this data to the `data` folder.
1. On the folder `rio-safe-space/Replication Package`, you will see two scripts called `MASTER`: one in R, one in Stata.
1. To run the Stata `MASTER`, open it and edit line 23 to reflect the path of the repository copy in your computer. This do-file creates all the non-map tables and graphs included in the working paper. You may need to install some of the user-written packages the code uses before it runs. To do so, modify line 29 by replacing `0` with `1`. This only needs to be done once in every computer.
1. To run the R `MASTER`, open it and edit line 52. The only package needed to run the code is `pacman`. If you don't have this package installed, uncomment line 29. As before, running this line once in a new computer is enough. This code will recreate the maps included in the paper
1. The outputs will be recreated in `rio-safe-space/Replication Package/outputs` folder. The only output that cannot be reproduced is figure A1. Personally identifying information is necessary to recreate this graph, so the package contains only the code for transparency.

If you run into any troubles running this code or reproducing results, please create an `Issue` in this repository.


##
<div class = "row">
  <div class = "column" style = "width:30%">
    <img src="https://github.com/worldbank/rio-safe-space/blob/master/img/wb.png" align = "left">
  </div>
  <div class = "column" style = "width:30%">
    <img src="https://github.com/worldbank/rio-safe-space/blob/master/img/i2i.png" align = "right">
  </div>
</div>
