
# PART 1: Load data ============================================================================================

  # Load data frame of stations
  ramais.df <-  readRDS(file.path(dt_final, 
                                  "maps_data.rds"))
  
  # Lines display
  map_lines <- geom_path(data = ramais.df,                       
                         aes(x = long, 
                             y = lat,
                             group = group),
                         col = "black",
                         lwd = 3)
  
  # Stations display
  map_stations <- geom_point(data = ramais.df,
                             aes(x = long, 
                                 y = lat),
                             col = "black",
                             size = 4)
  
  # Compliance colors
  compliance_colors <-  scale_color_manual(name = "",
                                           values = c("#e0f2f1", 
                                                      "#a7ffeb", 
                                                      "#1de9b6", 
                                                      "#26a69a", 
                                                      "#00796b"),
                                           na.value = "black")

# PART 2: Compliance =========================================================================================
  
# PART 2.1: Pink car ---------------------------------------------------------------------------------------
  
    rio_box +                                            # Base map
      maps_crop +                                        # Manually crop map
      maps_theme +                                       # Legend options
      map_lines +                                        # Display lines first
      map_stations + 
      compliance_colors +                                # Use compliance color palette
      geom_point(data = ramais.df,                       # Now display the variable we want
                 aes(x = long, 
                     y = lat, 
                     col = compliance_pink_scaled),
                 size = 3) +
      guides(color = guide_legend(nrow=1))
  
    ggsave(file.path(out_maps, "compliance.pdf"),
           device = "pdf",
           dpi = 2000)
    