
  # PART 1: Load data ============================================================================================
  
  # GPS location of users homes from premise
  users_homes <- read.csv(file.path(dt_raw, "users_homes.csv"))
  
  # Station coordinates
  stations_coords <- readOGR(file.path(dt_final, "supervia_stations.shp"))
  
  # Load data frame of stations
  ramais.df <- read.csv(file.path(dt_final, "supervia-lines-and-stations.csv"))
  
  lines_colors <- scale_color_manual(values = c("purple",
                                                "red",
                                                "steelblue1",
                                                "chartreuse3",
                                                "darkorange3"))
 
  # PART 2: Adjust data ===========================================================================================
  # Some of the lines overlap on some stations. This part of the code modifies the positions of the stations so
  # that the plot looks prettier. This was done in a completely ad hoc and messy manner.
  
  # Select factor to dislocate the points
  desloc <- 0.005  
  
  # These two stations look too close to each other in the map because of the points dimensions
  ramais.df[ramais.df$line == "Ramal Belford Roxo" & ramais.df$order == 9,
            c("long", "lat")] <-
    ramais.df[ramais.df$line == "Ramal Belford Roxo" & ramais.df$order == 9,
              c("long", "lat")] + cbind(rep(0,1), rep(desloc,1))
  
  # Dislocate lines so that they are shown parallel to each other
  ramais.df$desloc_long <- ramais.df$long
  ramais.df$desloc_lat  <- ramais.df$lat
  
  ramais.df[ramais.df$line == "Ramal Saracuruna" & ramais.df$order <= 4,
            c("desloc_long", "desloc_lat")] <-
    ramais.df[ramais.df$line == "Ramal Saracuruna" & ramais.df$order <= 4,
              c("desloc_long", "desloc_lat")] + cbind(rep(0,4), rep((desloc * 2),4))
  ramais.df[ramais.df$line == "Ramal Belford Roxo" & ramais.df$order <= 4,
            c("desloc_long", "desloc_lat")] <-
    ramais.df[ramais.df$line == "Ramal Belford Roxo" & ramais.df$order <= 4,
              c("desloc_long", "desloc_lat")] + cbind(rep(0,4), rep(desloc,4))
  ramais.df[ramais.df$line == "Ramal Saracuruna" & ramais.df$order %in% c(4,5),
            c("desloc_long", "desloc_lat")] <-
    ramais.df[ramais.df$line == "Ramal Saracuruna" & ramais.df$order %in% c(4,5),
              c("desloc_long", "desloc_lat")] + cbind(rep(desloc,2), rep(0,2))
  ramais.df[ramais.df$line == "Ramal Santa Cruz" & ramais.df$order <= 19,
            c("desloc_long", "desloc_lat")] <-
    ramais.df[ramais.df$line == "Ramal Santa Cruz" & ramais.df$order<= 19,
              c("desloc_long", "desloc_lat")] - cbind(rep(0,19), rep((desloc * 2),19))
  ramais.df[ramais.df$line == "Ramal Japeri" & ramais.df$order <= 19,
            c("desloc_long", "desloc_lat")] <-
    ramais.df[ramais.df$line == "Ramal Japeri" & ramais.df$order<= 19,
              c("desloc_long", "desloc_lat")] - cbind(rep(0,19), rep(desloc,19))
  
  
  # PART 4: Create map of lines and stations and homes ==========================================================
    
  pdf(file = file.path(out_maps, 
                       "ramais-and-homes.pdf"),
      width = 14)

    rio_box +                                            # Base map
      maps_crop +                                        # Manually crop map
      maps_theme +                                       # Legend options
      theme(legend.title = element_blank()) +
      lines_colors +
      geom_path(data = ramais.df,                        # Long lines
                aes(x = long,
                    y = lat,
                    group = group,
                    col = line),
                lwd = 2) +
      geom_path(data = ramais.df[ramais.df$id == 0, ],   ## Deodoro needs to go on top,
                aes(x = long,                            #  otherwise it's overwritten
                    y = lat,
                    group = group),
                col = "red",
                lwd = 2) +
      geom_point(data = users_homes,                     # Users's homes
             aes(x = home_long,
                 y = home_lat),
             col = "yellow",
             size = 1)
    
  dev.off()
  