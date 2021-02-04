#------------------------------------------------------------------------------#
#         Demand for "Safe Spaces": Avoiding Harassment and Stigma             #
#                    R reproducibility master script                           #
#                                                                              #
#    NOTE: Running this script will instal the packages listed under PART 2    #
#------------------------------------------------------------------------------#

# PART 1: User input ----------------------------------------------------------

  # PART 1.1: root folder ----------------------------------------------------
  github  <- "C:/Users/wb501238/Documents/GitHub" # Replace with the root folder the repository was cloned

  # PART 1.2: root folder ----------------------------------------------------
  
  # Figure A1: SuperVia lines and riders home location (requires access to
  # confidential data to run)
  map_supervia    <- 0

  # Figure A4: Presence of male riders in reserved space over stations
  map_rides       <- 1  
  
# PART 2: Load packages   -----------------------------------------------------
    
  packages  <- c(
   "readstata13",
   "sp", 
   "rgdal", 
   "rgeos", 
   "tidyverse", 
   "ggmap", 
   "maptools",
   "raster",
   "qdap"
  )

  pacman::p_load(packages, 
                 character.only = TRUE) # Load all packages -- run line 33 if pacman is not installed  

# PART 3: Set folder folder paths --------------------------------------------

  # Root folder 
  github  <- file.path(github, "rio-safe-space/Replication Package")
 
  # Project subfolders
  dt_final    <- file.path(github, "data", "final")
  out_maps    <- file.path(github, "outputs", "maps")
  code        <- file.path(github, "dofiles", "analysis", "paper", "maps")
  
# PART 4: Run selected sections -----------------------------------------------
  
  # Set map options
  if (map_supervia | map_rides) {source(file.path(code, "settings.R"))}
  if (map_supervia)             {source(file.path(code, "ramais-and-homes.R"))}
  if (map_rides)                {source(file.path(code, "compliance.R"))}
  
