#------------------------------------------------------------------------------#
#                                                                              #
#                                     DIME                                     #
#                                                                              #                                     
#                               MASTER DO_FILE                                 #                           
#                                                                              #
#------------------------------------------------------------------------------#

# PURPOSE:    

# NOTES:  
  
# WRITTEN BY: Luiza Cardoso de Andrade, 

#                                                    Last modified in July 2018

# PART 0: Clear memory --------------------------------------------------------
  
  rm(list=ls())

# PART 1: Select sections to run ----------------------------------------------

  map_supervia    <- 0
  map_rides       <- 1
  
  
# PART 2: Load packages   -----------------------------------------------------
  
  # install.packages("pacman")
  
  packages  <- c("readstata13",
                 "sp", 
                 "rgdal", 
                 "rgeos", 
                 "ggplot2", 
                 "ggmap", 
                 "maptools",
                 "raster",
                 "qdap",
                 "plyr")

  
  pacman::p_load(packages, character.only = TRUE) # Load all packages -- run line 33 if pacman is not installed
  

# PART 3: Set folder folder paths --------------------------------------------

  #-------------#
  # Root folder #
  #-------------#
 
    github  <- "rio-safe-space/Replication Package"
 
  
  #--------------------#
  # Project subfolders #
  #--------------------#

  # Data sets
  
  dt_final    <- file.path(github, "data", "final")
  out_maps    <- file.path(github, "outputs", "maps")
  code        <- file.path(github, "dofiles", "analysis", "maps")
  
# PART 5: Run selected sections -----------------------------------------------
  
  # Set map options
  if (map_supervia | map_rides) {source(file.path(code, "settings.R"))}
  
  # Figure A1: SuperVia lines and riders home location
  # The data used to create this figure contains confidential information and will only replicate for people 
  # who have access to the raw data
  if (map_supervia)             {source(file.path(code, "ramais-and-homes.R"))}
  
  # Figure A4: Presence of male riders in reserved space over stations
  if (map_rides)                {source(file.path(code, "compliance.R"))}
  