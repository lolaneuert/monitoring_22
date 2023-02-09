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

# load data: EU-forest dataset as csv file
tree_occ <- read.table("EUForestgenus.csv", header = TRUE, sep = ",")

# look at the dataset first
head(tree_occ)
tail(tree_occ)
summary(tree_occ)

# filter one specific genus, pine 
tree_occ_pinus <- filter(tree_occ, Genus.name == "Pinus")
ggplot(tree_occ_pinus, aes(x = X, y = Y)) + geom_point() # plot pine for a first look
dat_pinus <- tree_occ_pinus
coordinates(dat_pinus) <- ~X+Y # create a spatial object df

# inform R about the used CRS and project it to a new one, in this case WGS 84
proj4string(dat_pinus) <- crs("+init=epsg:3035") # original CRS of the dataset
dat_pinus <- spTransform(dat_pinus, crs("+proj=longlat +datum=WGS84")) # WGS 84

# now plot the newly projected pine data and add the european coastlines as a spatial reference
plot(dat_pinus, pch = 20, axes = TRUE)
plot(coastlines_eu, add = TRUE) 
ext <- c(-65.07555, 32.5132, 30.20569, 74.03175)
coastlines_eu <- crop(coastlines, ext)

