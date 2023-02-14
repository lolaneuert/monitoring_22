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

# save the plot as a pdf
pdf("Species_distr.pdf",
  width = 8, height = 7, # Width and height in inches
  bg = "white",          # Background color
  paper = "A4")
plot_pinus_cembra <- plot(dat_pinus_cembra, pch = 20, axes = TRUE,  main = "Species distribution: Pinus Cembra")
plot(coastlines_3035_st, add = TRUE) # we can see the species is mainly distributed in the alps
dev.off()

# we want to underlay the species distribution with a digital elevation model, this is derived from copernicus data
dem_alps <- raster("dem.tif")

# create a color palette using the viridis color generator
colors <- colorRampPalette(c("#fde725", "#b5de2b", "#6ece58", "#35b779", "#1f9e89", "#26828e", "#31688e", "#3e4989", "#482878", "#440154"))(4000)

# plot the dem to get a first look at it
plot(dem_alps, col = colors, main = "Digital Elevation Model - Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") 

plot(dat_pinus_cembra, pch = 20, add = TRUE) # add on the species distribution data
plot(coastlines_3035_st, add = TRUE) # add on the coastlines
# we can see there are a few smaller areas of missing data in the southwestern part of the raster
# as these areas only contain water anyway, we do not mind this 
# further we see that some species occurrences lay outside of the dem raster

# save the plot as pdf
pdf("DEM.pdf",
        width = 8, height = 7, # Width and height in inches
        bg = "white",          # Background color
        paper = "A4")      
plot(dem_alps, col = colors, main = "Digital Elevation Model - Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude")
plot(dat_pinus_cembra, pch = 20, add = TRUE) # add on the species distribution data
plot(coastlines_3035_st, add = TRUE) # add on the coastlines
dev.off() # closes the window with the map

# now we add a soil water index raster from copernicus, derived on the 01-02.07.2015
swi_010715 <- brick("swi_010715.nc", varname = "SWI_002")# brick creates a raster object
# looking at the dataset we see that it uses WGS84 as a projection, we need to change it to EPSG:3035, for to be compatible with the other sets
ext_alps <- c(5, 22, 39, 52)
swi_crop <- crop(swi_010715, ext_alps) # first we crop it to an approximate extent of the same region as the dem
swi_3035 <- projectRaster(swi_crop, crs = "+init=epsg:3035") # now we transform the projection
swi_crop_alps <- crop(swi_3035, dem_alps) # we can now crop it to the exact extent of the dem

# let's plot it to get an impression of the data
plot(swi_crop_alps, col = colors, main = "Soil Water Index - Alps", xlab = "latitude", ylab = "longitude")

plot(dat_pinus_cembra, pch = 20, add = TRUE) # add on the species distribution data
plot(coastlines_3035_st, add = TRUE) # add on the coastlines



# dat_pinus_cembra_wgs <- spTransform(dat_pinus_cembra, crs("+proj=longlat +datum=WGS84"))# WGS 84

