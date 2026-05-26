# Code to pull data for geospatial assignment
# Region: Colorado, USA
# Sub-national unit: Colorado counties

library(terra)
library(sf)
library(tidyverse)
library(rnaturalearth)
library(rnaturalearthdata)
library(mapview)
library(tigris)


# Colorado county boundaries --------------------------------------------------
# Pull US states, filter to Colorado, then get counties

colorado <- rnaturalearth::ne_states(country = "United States of America", returnclass = "sf") %>%
  filter(name == "Colorado") %>%
  select(name, region, geometry)

# Pull county-level data for Colorado
co_counties <- tigris::counties(state = "CO", cb = TRUE, class = "sf") %>%
  select(NAME, geometry)

# US states for background context
us_states <- rnaturalearth::ne_states(country = "United States of America", returnclass = "sf") %>% 
  # keep just conus
  filter(!name %in% c("Alaska", "Hawaii"))

# Save boundaries
st_write(colorado, "geospatial/data/colorado.shp", append = FALSE)
st_write(co_counties, "geospatial/data/co_counties.shp", append = FALSE)
st_write(us_states, "geospatial/data/us_states.shp", append = FALSE)


# WorldClim Data --------------------------------------------------------------

# Historic --------------------

## Temperature -----------------
dir <- tempdir()

# Unzip the file (download wc2.1_2.5m_tavg.zip from https://worldclim.org/data/worldclim21.html)
unzip("geospatial/data/wc2.1_2.5m_tavg.zip", exdir = dir)

# Find and read raster files
raster_files <- list.files(dir, pattern = "\\.tif$",
                           full.names = TRUE, recursive = TRUE)

rasters <- terra::rast(raster_files)

# Clip to Colorado and calculate mean annual temperature
co_temp_hist <- rasters %>%
  terra::crop(vect(st_transform(colorado, crs(rasters))), mask = TRUE) %>%
  terra::mean(na.rm = TRUE)

names(co_temp_hist) <- "CO_historic_temp"

# Save
writeRaster(co_temp_hist, "geospatial/data/co_historic_temp.tiff", overwrite = TRUE)

unlink(dir, recursive = TRUE)


## Precipitation ---------------
dir <- tempdir()

# Unzip the file (download wc2.1_2.5m_prec.zip from https://worldclim.org/data/worldclim21.html)
unzip("geospatial/data/wc2.1_2.5m_prec.zip", exdir = dir)

# Find and read raster files
raster_files <- list.files(dir, pattern = "\\.tif$",
                           full.names = TRUE, recursive = TRUE)

rasters <- terra::rast(raster_files)

# Clip to Colorado and calculate total annual precipitation
co_precip_hist <- rasters %>%
  terra::crop(vect(st_transform(colorado, crs(rasters))), mask = TRUE) %>%
  sum(na.rm = TRUE)

names(co_precip_hist) <- "CO_historic_precip"

# Save
writeRaster(co_precip_hist, "geospatial/data/co_historic_precip.tiff", overwrite = TRUE)

unlink(dir, recursive = TRUE)


# Future (2050) ---------------------------------------------------------------
# Download wc2.1_2.5m_bioc_BCC-CSM2-MR_ssp585_2041-2060.tif from:
# https://worldclim.org/data/cmip6/cmip6_clim2.5m.html

bioclim_2050 <- terra::rast("geospatial/data/wc2.1_2.5m_bioc_BCC-CSM2-MR_ssp585_2041-2060.tif")

# Mean annual temperature (BIO1 = layer 1)
temp_2050 <- bioclim_2050[[1]] %>%
  terra::crop(vect(st_transform(colorado, crs(bioclim_2050))), mask = TRUE)

names(temp_2050) <- "CO_2050_temp"

writeRaster(temp_2050, "geospatial/data/co_2050_temp.tiff", overwrite = TRUE)


# Annual precipitation (BIO12 = layer 12)
precip_2050 <- bioclim_2050[[12]] %>%
  terra::crop(vect(st_transform(colorado, crs(bioclim_2050))), mask = TRUE)

names(precip_2050) <- "CO_2050_precip"

writeRaster(precip_2050, "geospatial/data/co_2050_precip.tiff", overwrite = TRUE)
