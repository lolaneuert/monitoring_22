### Lola Neuert
### Exam Project - Monitoring Ecosystem Change and Function
### with Prof. Rocchini in the winter term 2022/23


# load useful packages
library(raster)
library(RStoolbox)
library(ggplot2)
library(patchwork)
library(gridExtra)
library(viridis)
library(rgdal)
library(dplyr)
library(spatstat)
library(sp)

# set the working directory
# setwd("C:/Rstudio/monitoring/exam_project2")

### the used ecological data EU-forest data '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
### information on the dataset from the authors
# "EU-Forest greatly extends the publicly available information on the distribution of European tree species 
# by adding almost half a million of tree occurrences derived from National Forest Inventories for 21 countries in Europe. 
# The improvement is not only concerning the number of occurrences but also the taxonomy including more than 200 tree species. 
# The reliability of the dataset is ensured by the fact that all surveys have been carried out by trained professional 
# staff using standard protocols. Nevertheless, we performed a technical validation aimed at detecting potential outliers, 
# and we evaluated the overall biogeographical consistency with well established knowledge. 
# Although, this dataset was originally designed to provide European decision-makers with high-quality forest data, 
# we believe that the great improvement in forest occurrences, taxonomy and spatial coverage will most likely benefit several disciplines 
# including forestry, biodiversity conservation, palaeoecology, plant ecology, the bioeconomy, and pest management."

### Strona, Giovanni; MAURI, ACHILLE; San-Miguel-Ayanz, Jesús (2016): 
### A high-resolution pan-European tree occurrence dataset. figshare. Collection. 
### https://doi.org/10.6084/m9.figshare.c.3288407.v1  

# load data: EU-forest dataset of tree species distribution as csv file
tree_occ_species <- read.table("EUForestspecies.csv", header = TRUE, sep = ",")

# look at the dataset first
head(tree_occ_species)
tail(tree_occ_species)
summary(tree_occ_species)

# filter one specific species: pinus cembra = Zirbelkiefer or Swiss stone pine
tree_occ_pinus_cembra <- filter(tree_occ_species, SPECIES.NAME == "Pinus cembra")
ggplot(tree_occ_pinus_cembra, aes(x = X, y = Y)) + geom_point() # plot pine for a first look
# create a spatial object df
dat_pinus_cembra <- tree_occ_pinus_cembra 
coordinates(dat_pinus_cembra) <- ~X+Y # tell R which columns contain coordinates
proj4string(dat_pinus_cembra) <- crs("+init=epsg:3035") # inform R about the original CRS of the dataset

# load shapefile containing the european coastlines and transform projection to EPSG:3035
coastlines <- readOGR("ne_10m_coastline.shp")
coastlines_st <- st_as_sf(coastlines, crs = "+proj=longlat +datum=WGS84 +no_defs") # to change the projection we first need to transform it to an sf object
coastlines_3035 <- st_transform(coastlines_st, crs = crs(dem_alps)@projargs) # now align the projection to the pine dataset
coastlines_3035_st <- as_Spatial(coastlines_3035) # tranform it back to a spatial lines df
plot(coastlines_3035_st) # plot it to have a look

# now plot the transformed spatial object containing the species distribution & add the european coastlines around it for visuals 
plot_pinus_cembra <- plot(dat_pinus_cembra, pch = 20, axes = TRUE)
plot(coastlines_3035_st, add = TRUE) # we can see the species is mainly distributed in the alps

# we want to underlay the species distribution with a digital elevation model, this is derived from copernicus data
dem_alps <- raster("dem.tif")

# let's plot it to get a first glimpse at the data
ggplot() + 
  geom_raster(dem_alps, mapping = aes(x = x, y = y, fill = dem)) + scale_fill_viridis(option = "mako", direction = -1) + 
  ggtitle("Digital Elevation Model-Alps") # we can see there are a few smaller areas of missing data in the southwestern part of the raster
# as these areas only contain water anyway, we do not mind this 
  
# now add the species distribution data and consecutively the coastlines
ggplot() + 
  geom_raster(dem_alps, mapping = aes(x = x, y = y, fill = dem)) + scale_fill_viridis(option = "mako", direction = -1) + 
  ggtitle("Digital Elevation Model-Alps") +
  layer_spatial(dat_pinus_cembra, aes()) +
  layer_spatial(coastlines_3035_st, aes())
# we can see that adding the coastlines has forced ggplot to zoom out, displaying the global coastlines







# dat_pinus_cembra_wgs <- spTransform(dat_pinus_cembra, crs("+proj=longlat +datum=WGS84"))# WGS 84

