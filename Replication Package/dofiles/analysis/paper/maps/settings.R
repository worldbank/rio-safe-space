#header-start###########################################################################
#                                                                                      #
#                                                                                      #
# PURPOSE:  This script creates the inputs necessary to generate the maps in           #
#           Maps/Code/Maps/Ramais and users homes.R and Maps/Code/Maps/Rides data.R    #
#                                                                                      #
# WRITTEN BY: Luiza Andrade (lcardosodeandrad@worldbank.org)                           #
#                                                                                      #                                                                                     #
#header-end#############################################################################


# PART 1: Get station coordinates ======================================================
  
  # Load data set
  stations_coords <- 
    readOGR(file.path(dt_final, 
                      "supervia_stations.shp"))

  # Get base map centering on the stations coordinates -- first is just to have an idea,
  # then we adjust
  stations_box <- bbox(stations_coords)
  stations_box[1,] <- c(-44,-43)
  stations_box[2,] <- c(-23.5,-22.5)
  
# PART 2: Load basemap ================================================================

  rio_box <- ggmap(get_stamenmap(bbox = stations_box,
                                 source = "stamen",
                                 maptype = "toner-background",
                                 color="bw"),
                   darken = c(.4, "white"))

# PART 3: Set options for maps ========================================================
  
  # Manually crop map (ggmap always creates square plots)
  maps_crop  <- 
    coord_fixed(xlim = c(-43.75, -43.1),               # Manually crop map
                ylim = c(-23.1, -22.6))
  
  # Map theme
  maps_theme <- 
    theme(axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          legend.position = "bottom",
          legend.direction = "horizontal",
          legend.key = element_rect(fill = "white"),
          legend.spacing.x = unit(0.5, 'cm')) 
  
