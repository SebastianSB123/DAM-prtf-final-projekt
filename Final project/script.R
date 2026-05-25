# 1. Install packages (only run this line the first time)
install.packages(c("leaflet", "readxl", "dplyr"))

#---------------------------------------------------------

# 2. Activate packages 
# These are the packages needed:
# leaflet = For the interactive map
# readxl = To read the excel file with data
# dplyr = To "clean" the data and make it ready for the map
library(leaflet)
library(readxl)
library(dplyr)

#---------------------------------------------------------

# 3. Download the data and read it into R.
# Period 1: 1609-1616 (from Finalproject data2)
witch_data_early <- read_excel("data/Finalproject data2.xlsx")

# Period 2: 1620-1626 (from Finalproject data1, sheet 2)
witch_data_late <- read_excel("data/Finalproject data1.xlsx", sheet = 2)

# ---------------------------------------------------------

# 4. "Clean" the data
# We clean both datasets individually so R understands the coordinates

# Clean the early period (1609-1616)
witch_data_early_clean <- witch_data_early %>%
  mutate(
    Latitude = as.numeric(gsub(",", ".", Latitude)),
    Longitude = as.numeric(gsub(",", ".", Longitude))
  ) %>%
  filter(!is.na(Latitude) & !is.na(Longitude))

# Clean the late period (1620-1626)
witch_data_late_clean <- witch_data_late %>%
  mutate(
    Latitude = as.numeric(gsub(",", ".", Latitude)),
    Longitude = as.numeric(gsub(",", ".", Longitude))
  ) %>%
  filter(!is.na(Latitude) & !is.na(Longitude))

# ---------------------------------------------------------

# 5. Build the interactive map with layers

# Notice that leaflet() is empty here. We assign the data directly to the markers below.
interactive_map <- leaflet() %>%
  
  # --- Add different types of maps  ---
  addTiles(group = "Standard Map") %>% 
  addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>% 
  addProviderTiles(providers$CartoDB.Positron, group = "Light Map") %>%
  
  # Set the view over Denmark (longitude, latitude, zoom level)
  setView(lng = 9.5, lat = 56.1, zoom = 6) %>% 
  
  # --- Add the data for Period 1 (1609-1616) ---
  addMarkers(
    data = witch_data_early_clean,
    lng = ~Longitude,  
    lat = ~Latitude,   
    popup = ~paste("<b>Name:</b>", Navn, "<br>", "<b>City:</b>", By),
    label = ~Navn,
    group = "1609-1616 Trials", # This is the name that will show up in the menu
    clusterOptions = markerClusterOptions() 
  ) %>%
  
  # --- Add the data for Period 2 (1620-1626) ---
  addMarkers(
    data = witch_data_late_clean,
    lng = ~Longitude,  
    lat = ~Latitude,   
    popup = ~paste("<b>Name:</b>", Navn, "<br>", "<b>City:</b>", By),
    label = ~Navn,
    group = "1620-1626 Trials", # This is the name that will show up in the menu
    clusterOptions = markerClusterOptions() 
  ) %>%
  
  # --- Add menu to switch between maps and toggle data ---
  addLayersControl(
    # baseGroups are radio buttons (you can only select ONE background map at a time)
    baseGroups = c("Standard Map", "Satellite", "Light Map"),
    
    # overlayGroups are checkboxes (you can toggle BOTH data periods on and off)
    overlayGroups = c("1609-1616 Trials", "1620-1626 Trials"),
    
    options = layersControlOptions(collapsed = FALSE)
  )

# ---------------------------------------------------------

# 6. Show the map
interactive_map