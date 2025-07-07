# Code to pull data for geospatial assignment

library(terra)
library(sf)
library(tidyverse)
library(rnaturalearth)


#China boundary
china <- st_read("geospatial/data_update/china.shp") %>% 
  select(AREA, FENAME, FCNAME)

# save with new selected column names
st_write(china, "geospatial/data_update/china.shp", append = FALSE)

# Worldclim Data ----------------


# historic --------------------

## Temp -----------------
dir <- tempdir()

# Unzip the file
unzip("geospatial/data_update/wc2.1_2.5m_tavg.zip", exdir = dir)

# Find and read raster files
raster_files <- list.files(dir, pattern = "\\.tif$", 
                           full.names = TRUE, recursive = TRUE)

rasters <- terra::rast(raster_files)

# clip to china and average
china_temp_hist <- rasters %>% 
  terra::crop(vect(st_transform(china, crs(rasters))), mask = TRUE) %>% 
  terra::mean(na.rm = TRUE)


tm_shape(china_temp_hist) +
  tm_raster(palette = "viridis", style = "cont")

names(china_temp_hist) <- "China_historic_temp"

# save
writeRaster(china_temp_hist, "geospatial/data_update/china_historic_temp.tiff", overwrite = TRUE)

unlink(dir, recursive = TRUE)

## Precip ---------------------------

dir <- tempdir()

# Unzip the file
unzip("geospatial/data_update/wc2.1_2.5m_prec.zip", exdir = dir)

# Find and read raster files
raster_files <- list.files(dir, pattern = "\\.tif$", 
                           full.names = TRUE, recursive = TRUE)

rasters <- terra::rast(raster_files)

# clip to china and average
china_precip_hist <- rasters %>% 
  terra::crop(vect(st_transform(china, crs(rasters))), mask = TRUE) %>% 
  sum(na.rm = TRUE)


tm_shape(china_precip_hist) +
  tm_raster(palette = "viridis", style = "cont")

names(china_precip_hist) <- "China_historic_precip"

# save
writeRaster(china_precip_hist, "geospatial/data_update/china_historic_precip.tiff", overwrite = TRUE)

unlink(dir, recursive = TRUE)


# FUTURE -------------------------------

### 2050 -----------------------------
bioclim_2050 <- terra::rast("geospatial/data_update/wc2.1_2.5m_bioc_BCC-CSM2-MR_ssp585_2041-2060.tif")

# clip to china

#mean temp
temp_2050 <- bioclim_2050[[1]] %>% 
  terra::crop(vect(st_transform(china, crs(bioclim_2050))), mask = TRUE) 
  
tm_shape(temp_2050) +
  tm_raster(palette = "viridis", style = "cont")


names(temp_2050) <- "China_2050_temp"


# save
writeRaster(temp_2050, "geospatial/data_update/china_2050_temp.tiff", overwrite = TRUE)



#annual precip
precip_2050 <- bioclim_2050[[12]] %>% 
  terra::crop(vect(st_transform(china, crs(bioclim_2050))), mask = TRUE) 

tm_shape(precip_2050) +
  tm_raster(palette = "viridis", style = "cont")

names(precip_2050) <- "China_2050_precip"

# save
writeRaster(precip_2050, "geospatial/data_update/china_2050_precip.tiff", overwrite = TRUE)


## 2090

### 2090 -----------------------------
bioclim_2090 <- terra::rast("geospatial/data/wc2.1_2.5m_bioc_BCC-CSM2-MR_ssp585_2081-2100.tif")

# clip to china

#mean temp
temp_2090 <- bioclim_2090[[1]] %>% 
  terra::crop(vect(st_transform(china_country, crs(bioclim_2090))), mask = TRUE) 

tm_shape(temp_2090) +
  tm_raster(palette = "viridis", style = "cont")

names(temp_2090) <- "China_2090_temp"

# save
writeRaster(temp_2090, "geospatial/data/china_2090_temp.tiff", overwrite = TRUE)



#annual precip
precip_2090 <- bioclim_2090[[12]] %>% 
  terra::crop(vect(st_transform(china_country, crs(bioclim_2090))), mask = TRUE) 

tm_shape(precip_2090) +
  tm_raster(palette = "viridis", style = "cont")

names(precip_2090) <- "China_2090_precip"

# save
writeRaster(precip_2090, "geospatial/data/china_2090_precip.tiff", overwrite = TRUE)



# Change calculations ----------------

temp_hist <- rast("geospatial/data/china_historic_temp.tiff")
temp_205

test <- temp_2090 - temp_hist

