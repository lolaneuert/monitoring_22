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
library(sf)
library(ggspatial)
# set the working directory
setwd("C:/Rstudio/monitoring/exam_project2")




### EU-FOREST DATA '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
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

## Strona, Giovanni; MAURI, ACHILLE; San-Miguel-Ayanz, Jesús (2016): 
## A high-resolution pan-European tree occurrence dataset. figshare. Collection. 
## https://doi.org/10.6084/m9.figshare.c.3288407.v1  

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




### COASTLINE DATA ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# load shapefile containing the european coastlines and transform projection to EPSG:3035
coastlines <- readOGR("ne_10m_coastline.shp")
coastlines_st <- st_as_sf(coastlines, crs = "+proj=longlat +datum=WGS84 +no_defs") # to change the projection we first need to transform it to an sf object
coastlines_3035 <- st_transform(coastlines_st, crs = crs("+init=epsg:3035")@projargs) # now align the projection to the pine dataset
coastlines_3035_st <- as_Spatial(coastlines_3035) # tranform it back to a spatial lines df
plot(coastlines_3035_st) # plot it to have a look

# now plot the transformed spatial object containing the species distribution & add the european coastlines around it for visuals 
plot_pinus_cembra <- plot(dat_pinus_cembra, pch = 20, axes = TRUE,  main = "Species distribution: Pinus Cembra")
plot(coastlines_3035_st, add = TRUE) # we can see the species is mainly distributed in the alps

# save the plot as a pdf
pdf("Species_distr.pdf",
  width = 8, height = 7, # Width and height in inches
  bg = "white",          # Background color
  paper = "A4")
plot_pinus_cembra <- plot(dat_pinus_cembra, pch = 20, axes = TRUE,  main = "Species distribution: Pinus Cembra")
plot(coastlines_3035_st, add = TRUE) # we can see the species is mainly distributed in the alps
dev.off()



# as the simple distribution does not yield much information about the position of pinus cembra occurrence one needs to look at further environmental data sets
# in the following three environmental parameters (digital elevation, soil water, land surface temperature) are collected, adjusted/cleaned and plotted with the pine occurrences

### DEM-DATA''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# we want to underlay the species distribution with a digital elevation model, this is derived from copernicus data
dem_alps <- raster("dem.tif")

# create a color palette using the viridis color generator
colors <- colorRampPalette(c("#fde725", "#b5de2b", "#6ece58", "#35b779", "#1f9e89", "#26828e", "#31688e", "#3e4989", "#482878", "#440154"))(4000)
plot_dem <- plot(dem_alps, col = colors, main = "Digital Elevation Model - Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") # plot the dem to get a first look at it
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
plot(dem_alps, col = colors, main = "Digital Elevation Model - Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") # plot the dem to get a first look at it
plot(dat_pinus_cembra, pch = 20, add = TRUE) # add on the species distribution data
plot(coastlines_3035_st, add = TRUE) 
dev.off() # closes the window with the map




### SOIL WATER INDEX DATA'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# image from https://land.copernicus.vgt.vito.be/PDF/portal/Application.html#Browse;Root=514690;Collection=1000281;DoSearch=true;Time=NORMAL,NORMAL,1,JANUARY,2015,5,JANUARY,2015;ROI=-10,36,-5,40;isReserved=false
# load image for soil water index (resolution 1km): derived on the 01-02.07.2015
swi_010715 <- brick("swi_010715.nc", varname = "SWI_002")# brick creates a raster object
# looking at the dataset we see that it uses WGS84 as a projection, we need to change it to EPSG:3035, for to be compatible with the other sets
ext_alps <- c(5, 22, 39, 52)
swi_crop <- crop(swi_010715, ext_alps) # first we crop it to an approximate extent of the same region as the dem
swi_3035 <- projectRaster(swi_crop, crs = "+init=epsg:3035") # now we transform the projection
swi_crop_alps <- crop(swi_3035, dem_alps) # we can now crop it to the exact extent of the dem

# let's plot it to get an impression of the data
plot_swi <- plot(swi_crop_alps, col = colors, main = "Soil Water Index - Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") # plot the dem to get a first look at it
plot(dat_pinus_cembra, cex = 0.5, col="white", add = TRUE) # add on the species distribution data
plot(coastlines_3035_st, col = "white", add = TRUE) # add on the coastlines

# download this as a pdf
pdf("SWI.pdf",
    width = 8, height = 7, # Width and height in inches
    bg = "white",          # Background color
    paper = "A4") 
plot_swi <- plot(swi_crop_alps, col = colors, main = "Soil Water Index - Alps",  sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude")
plot(dat_pinus_cembra, cex = 0.5, col="white", add = TRUE) # add on the species distribution data
plot(coastlines_3035_st, col = "white", add = TRUE) # add on the coastlines
dev.off()

# we plot the dem and the swi images next to each other
pdf("DEM_SWI.pdf",
    width = 7, height = 10,
    bg = "white",
    paper = "A4")
par(mfrow=c(2,1))
plot(dem_alps, col = colors, main = "Digital Elevation Model - Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") # plot the dem to get a first look at it
plot(dat_pinus_cembra, pch = 20, add = TRUE) # add on the species distribution data
plot(coastlines_3035_st, add = TRUE) 
plot(swi_crop_alps, col = colors, main = "Soil Water Index - Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") # plot the dem to get a first look at it
plot(dat_pinus_cembra, cex = 0.5, col="white", add = TRUE) # add on the species distribution data
plot(coastlines_3035_st, col = "white", add = TRUE) # add on the coastlines
dev.off()




### LAND SURFACE TEMPERATURE DATA''''''''''''''''''''''''''''''''''''''''''''''''''
# import land surface temperature from copernicus, derived on the 01.07.2015
lst_010715 <- brick("LST_201507011300.nc", varname = "LST") # brick function creates a raster object
plot(lst_010715) # looking at the raster we see that it covers the whole planet, therefore we need to crop it
lst_crop <- crop(lst_010715, ext_alps)
lst_3035 <- projectRaster(lst_crop, crs = "+init=epsg:3035") # now we transform the projection, since it does not yet coincide with the other rasters
lst_crop_alps <- crop(lst_3035, dem_alps)# now we crop the lst raster to the same extent as the others

# to get a better look at the data we plot the and surface temperature
plot_lst <- plot(lst_crop_alps, col = colors, main = "Land Surface Temperature - Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") # plot the dem to get a first look at it
plot(dat_pinus_cembra, pch = 20, add = TRUE) # add on the species distribution data
plot(coastlines_3035_st, add = TRUE) # add on the coastlines

# download this as a pdf
pdf("LST.pdf",
    width = 8, height = 7, # Width and height in inches
    bg = "white",          # Background color
    paper = "A4") 
plot_lst <- plot(lst_crop_alps, col = colors, main = "Land Surface Temperature - Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") # plot the dem to get a first look at it
plot(dat_pinus_cembra, pch = 20, add = TRUE) # add on the species distribution data
plot(coastlines_3035_st, add = TRUE)
dev.off()



# we plot all the images next to each other
pdf("graphs.pdf",
    width = 7, height = 10,
    bg = "white",
    paper = "A4")
par(mfrow=c(2,2))
plot_pinus_cembra <- plot(dat_pinus_cembra, pch = 20, axes = TRUE,  main = "Species distribution: Pinus Cembra")
plot(coastlines_3035_st, add = TRUE)
plot(dem_alps, col = colors, main = "Digital Elevation Model - Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") # plot the dem to get a first look at it
plot(dat_pinus_cembra, pch = 20, add = TRUE)
plot(coastlines_3035_st, add = TRUE) 
plot(swi_crop_alps, col = colors, main = "Soil Water Index - Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") # plot the dem to get a first look at it
plot(dat_pinus_cembra, cex = 0.5, col="white", add = TRUE)
plot(coastlines_3035_st, col = "white", add = TRUE)
plot_lst <- plot(lst_crop_alps, col = colors, main = "Land Surface Temperature - Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") # plot the dem to get a first look at it
plot(dat_pinus_cembra, pch = 20, add = TRUE)
plot(coastlines_3035_st, add = TRUE)
dev.off()

### CORRELATION''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# to correlate the different data sets we extract the values for each at the location where a pine is found
# we want to extract the exact elevation data for the points where the pine is found
DEM_pinus <- extract (dem_alps, dat_pinus_cembra)
# we want to extract the exact soil water data for the points where the pine is found
SWI_pinus <- extract (swi_crop_alps, dat_pinus_cembra)
# we want to extract the exact land surface temperature data for the points where the pine is found
LST_pinus <- extract (lst_crop_alps, dat_pinus_cembra)

# we create a new list, containing the coordinates of the point tree data
Pinus_point_data <- tree_occ_pinus_cembra[c(1,2,4)]
# to have some orientation we create a sequence of numbers 1:346
nr <- seq(from = 1, to = 346)
# we bind together the point data of the pine with the extracted DEM, SWI and LST data
Pinus <- cbind(nr, Pinus_point_data, DEM_pinus, SWI_pinus, LST_pinus)

# one can see that several columns contain NA data, especially in the LST data
# to be able to compute statistically with these values, the NA columns need to be removed
Pinus_clean <- na.omit(Pinus) # remove all columns which contain NAs, we are left with 149 of originally 346 pine observations
# some of the omissions were due to pine observations outside of the alpine region, whist most were due to missing data in one or more of the environmental rasters

# for the actual correlation a pearson test is conducted
# it is assumed that land surface temperature is negatively correlated with digital elevation 
# whilst land surface temperature is positively correlated with soil water index
# lastly it is assumed that digital elevation is negatively correlated with soil water index
cor.test(Pinus_clean$LST_pinus, Pinus_clean$DEM_pinus, alternative = "less")
cor.test(Pinus_clean$LST_pinus, Pinus_clean$SWI_pinus, alternative = "greater")
cor.test(Pinus_clean$DEM_pinus, Pinus_clean$SWI_pinus, alternative = "less")

# none of the above tests of correlation showed a p-value below 0.05 so there are doubts concerning there relevancy
# ... results?? scatterplots??

# which of the parameters shows larger range, more precise vales at points? in total/in points of pine occurrence?
# this could lead to assumptions about which of them is more relevant for the occurrence of pine
# boxplots of what values are available, and what values are shown at pine points


