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
library(maps)

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

# filter one specific species: pinus cembra = Zirbelkiefer or Swiss stone pine and remove all occurrences that lay outside of our study area, the alps
tree_occ_pinus_cembra <- filter(tree_occ_species, SPECIES.NAME == "Pinus cembra", X < 5000000, Y < 2900000)
ggplot(tree_occ_pinus_cembra, aes(x = X, y = Y)) + geom_point() # plot pine for a first look

# create a spatial object df
dat_pinus_cembra <- tree_occ_pinus_cembra 
coordinates(dat_pinus_cembra) <- ~X+Y # tell R which columns contain coordinates
proj4string(dat_pinus_cembra) <- crs("+init=epsg:3035") # inform R about the original CRS of the dataset




### COASTLINE DATA ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# load shapefile containing the european coastlines (from course data, Monitoring of Ecosystem Changes and Functioning)
coastlines <- readOGR("ne_10m_coastline.shp") # since it is not in the same projection as the tree point data we need to transform the projection to EPSG:3035
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
# in the following two environmental parameters (digital elevation and land surface temperature, in summer and winter) are collected, adjusted/cleaned and plotted with the pine occurrences




### DEM-DATA ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# we want to underlay the species distribution with a digital elevation model, this is derived from copernicus data 
# https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1-0-and-derived-products/eu-dem-v1.0?tab=download
dem_alps_brick <- brick("dem.tif") # the data is given as elevation in meters above sea level, and it is already in the same projection as the tree data (EPSG 3035)
# this dem contains the study area of the alps as well as the surrounding areas

# now crop the coastlines to the same extent as the dem
coastlines_crop <- crop (coastlines_3035_st, dem_alps_brick)
# ggplot is not working well with these layer combinations (requires a lot of back and forth of data formats)
# so we use simple plot function for which viridis is not directly available, so we create a color palette using the viridis color generator
colors <- colorRampPalette(c("#fde725", "#b5de2b", "#6ece58", "#35b779", "#1f9e89", "#26828e", "#31688e", "#3e4989", "#482878", "#440154"))(4000)
plot(dem_alps_brick, col = colors, main = "Digital Elevation Model - Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") # plot the dem to get a first look at it
plot(dat_pinus_cembra, pch = 20, add = TRUE) # add on the species distribution data
plot(coastlines_crop, add = TRUE) # add on the coastlines

# we can see there are a few smaller areas of missing data in the southwestern part of the dem raster
# as these areas only contain water anyway, we do not mind this 
# further we see that all species occurrences lay inside of the dem raster, since we removed any other observations (outside the study area-alps) already in line 52

# save the plot as pdf
pdf("DEM.pdf",
    width = 8, height = 7, # Width and height in inches
    bg = "white",          # Background color
    paper = "A4")      
plot(dem_alps_brick, col = colors, main = "Digital Elevation Model - Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") # plot the dem to get a first look at it
plot(dat_pinus_cembra, pch = 20, add = TRUE) # add on the species distribution data
plot(coastlines_crop, add = TRUE) # add on the coastlines
dev.off() # closes the window with the map




### LAND SURFACE TEMPERATURE DATA'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# we import land surface temperature from copernicus, the data is from the 01.07.2015
# https://land.copernicus.vgt.vito.be/PDF/portal/Application.html#Browse;Root=520752;Time=NORMAL,NORMAL,-1,,,-1,,
lst_010715 <- brick("LST_201507011300.nc", varname = "LST") # brick function creates a raster object
plot(lst_010715) # looking at the raster we see that it covers the whole planet, therefore we need to crop it to the study area-alps
ext_alps <- c(5, 22, 39, 52) # for this we first create a rough extent of the study area
lst_crop_jul <- crop(lst_010715, ext_alps) # we crop it to this extent
lst_3035_jul <- projectRaster(lst_crop_jul, crs = "+init=epsg:3035") # we transform the projection, since it does not yet coincide with the other rasters
# if we had done this step before cropping the raster it would have consumed much larger computational powers, as it would have had to apply the mathematical transformation to many more pixels
lst_crop_alps_jul <- crop(lst_3035_jul, dem_alps_brick) # we crop the lst raster to the exact same extent as the dem 

# to compare the upper and lower temperature boundaries in the observed pine locations, in addition to the summer picture we load a january picture of the same area and year
# import lst from copernicus, deridata is from the 01.01.2015
lst_010115 <- brick("LST_201501011300.nc", varname = "LST") # brick function creates a raster object
lst_crop_jan <- crop(lst_010115, ext_alps) # again preliminary crop
lst_3035_jan <- projectRaster(lst_crop_jan, crs = "+init=epsg:3035") # we transform the projection
lst_crop_alps_jan <- crop(lst_3035_jan, dem_alps_brick) # we crop this raster to the extent of the others


# to get a better look at the data we plot the two land surface temperatures, it is given in °K, 
# unfortunately we can see that many areas in the alps show no data, particularly in the summer picture
par(mfrow=c(1,2)) # create a double frame to display them next to each other
plot(lst_crop_alps_jan, col = colors, main = "Land Surface Temperature - Alps, January 2015", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude")
plot(dat_pinus_cembra, pch = 20, add = TRUE) # add on the species distribution data
plot(coastlines_crop, add = TRUE) # add on the coastlines
plot(lst_crop_alps_jul, col = colors, main = "Land Surface Temperature - Alps, July 2015", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") 
plot(dat_pinus_cembra, pch = 20, add = TRUE) # add on the species distribution data
plot(coastlines_crop, add = TRUE) # add on the coastlines

# when comparing the two, we see that the coverage is very different in the two pictures, whilst the January image shows a better coverage of the Alps,
# the July picture shows a better coverage of landmasses in general, but many blank areas in the alpine region

# wwe download these as pdfs
pdf("LST_jan.pdf",
    width = 8, height = 7, # Width and height in inches
    bg = "white",          # Background color
    paper = "A4") 
plot_lst <- plot(lst_crop_alps_jan, col = colors, main = "Land Surface Temperature - Alps, January 2015", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") # plot the dem to get a first look at it
plot(dat_pinus_cembra, pch = 20, add = TRUE) # add on the species distribution data
plot(coastlines_crop, add = TRUE)
dev.off()

pdf("LST_jul.pdf",
    width = 8, height = 7, 
    bg = "white",          
    paper = "A4") 
plot_lst <- plot(lst_crop_alps_jan, col = colors, main = "Land Surface Temperature - Alps, July 2015", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") # plot the dem to get a first look at it
plot(dat_pinus_cembra, pch = 20, add = TRUE) # add on the species distribution data
plot(coastlines_crop, add = TRUE)
dev.off()


# we plot all 4 images next to each other
pdf("all_graphs.pdf",
    width = 7, height = 10,
    bg = "white",
    paper = "A4")
par(mfrow=c(2,2))
plot(dat_pinus_cembra, pch = 20, axes = TRUE,  main = "Species distribution: Pinus Cembra", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude")
plot(coastlines_crop, add = TRUE)
plot(dem_alps_brick, col = colors, main = "Digital Elevation Model-Alps", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") 
plot(dat_pinus_cembra, pch = 20, add = TRUE)
plot(coastlines_crop, add = TRUE) 
plot(lst_crop_alps_jan, col = colors, main = "Land Surface Temperature-Jan 2015", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude") 
plot(dat_pinus_cembra, pch = 20, add = TRUE)
plot(coastlines_crop, add = TRUE) 
plot(lst_crop_alps_jul, col = colors, main = "Land Surface Temperature-July 2015", sub = "Showing species distribution and coastlines", xlab = "latitude", ylab = "longitude")
plot(dat_pinus_cembra, pch = 20, add = TRUE) 
plot(coastlines_crop, add = TRUE)
dev.off()




### CORRELATION AND ANALYSIS''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# to correlate the different data sets we extract the values for each at the location where a pine is found
# we want to extract the exact elevation data for the points where the pine is found
DEM_pinus <- extract (dem_alps_brick, dat_pinus_cembra)
# as well as the exact land surface temperature data
LST_pinus_summer <- extract (lst_crop_alps_jul, dat_pinus_cembra) # both for the summer
LST_pinus_winter <- extract(lst_crop_alps_jan, dat_pinus_cembra) # and winter data


# we create a new list, containing the coordinates of the point tree data
Pinus_point_data <- tree_occ_pinus_cembra[c(1,2,4)]
# to have some orientation we create a sequence of numbers 1:337
nr <- seq(from = 1, to = 337)
# we bind together the point data of the pine with the extracted DEM and LST data
Pinus <- cbind(nr, Pinus_point_data, DEM_pinus, LST_pinus_summer, LST_pinus_winter)

##### for some reason the layer DEM_pinus lost his name whilst being integrated to the df, so it is now called layer??


# one can see that several columns contain NA data, especially in the LST data
# to be able to compute statistically with these values, the NA columns need to be removed
Pinus_clean <- na.omit(Pinus) # remove all columns which contain NAs, we are left with 138 of originally 337 pine observations

####### return to the correlations!!
# for the actual correlation a pearson test is conducted
# it is assumed that summer land surface temperature is negatively correlated with digital elevation (the lower down, the warmer)
# whilst winter land surface temperature is positively correlated with the elevation (the further up, the colder)
cor.test(Pinus_clean$LST_pinus_summer, Pinus_clean$DEM_pinus, alternative = "less")
cor.test(Pinus_clean$LST_pinus_winter, Pinus_clean$DEM_pinus, alternative = "greater")

# the first two of the above tests of correlation did not show a p-value below 0.05 so there are doubts concerning there relevancy
# the last test however showed a p-value clearly below 0.05, thereby giving rise to the assumption that the parameter soil water is indeed positively dependent on elevation at the observed locations
# regarding the results, not much can be said, it would be necessary to compare them to random points around the occurrences

# scatterplots to visualize the correlations

scatter_hyp1 <- ggplot(data = Pinus_clean) + 
  geom_point(aes(x = LST_pinus_summer, y = DEM_pinus), alpha = 0.3) + 
  geom_smooth(aes(x = LST_pinus_summer, y = DEM_pinus), method = "lm") +
  labs(title = "Summer temperature and elevation correlation", 
       subtitle = "at observed Pinus locations", 
       x = "Land surface temperature in °K", y = "Elevation in m a.s.l.") +
  theme(panel.background = element_rect(fill = "white"))

scatter_hyp2 <- ggplot(data = Pinus_clean) + 
  geom_point(aes(x = LST_pinus_winter, y = DEM_pinus), alpha = 0.3) + 
  geom_smooth(aes(x = LST_pinus_Winter, y = DEM_pinus), method = "lm") +
  labs(title = "Winter temperature and elevation correlation", 
       subtitle = "at observed Pinus locations", 
       x = "Land surface temperature in °K", y = "Elevation in m a.s.l.") +
  theme(panel.background = element_rect(fill = "white"))

# the two scatterplots show very unclear results, and do not seem to show a correlation between either of the parameters

# the first scatterplot however shows a cloud of temperatures that do not seem to lay in any regard to the measured elevation,
## also they seem rather high varying around 300°K at around 26°C, but since it is summer this could be explained? (also in ground rather constant temperatures)



# which of the parameters shows larger range, more precise vales at points? in total/in points of pine occurrence?
# this could lead to assumptions about which of them is more relevant for the occurrence of pine
# boxplots of what values are available, and what values are shown at pine points
DEM_box <- ggplot(data = Pinus_clean) +
  geom_boxplot(aes(y = layer)) + 
  labs(title = "DEM",
       y = "DEM") + 
  theme(panel.background = element_rect(fill = "white"))

LST_summer_box <- ggplot(data = Pinus_clean) +
  geom_boxplot(aes(y = LST_pinus_summer)) + 
  labs(title = "LST_summer",
       y = "LST") + 
  theme(panel.background = element_rect(fill = "white"))

LST_winter_box <- ggplot(data = Pinus_clean) +
  geom_boxplot(aes(y = LST_pinus_winter)) + 
  labs(title = "LST_winter",
       y = "LST") + 
  theme(panel.background = element_rect(fill = "white"))

# display all of them next to each other
boxplots <- DEM_box + LST_winter_box + LST_summer_box 
# save them as a pdf 
ggsave(filename = "boxplots.pdf", plot = boxplots, width = 15, height = 10)

# from the boxplots one can clearly see that the majority of observed Pinus cembra observations
# lie within 1750-2000m of elevation, at a soil water index of 126% (???) and at a land surface temperature of over 300°K (or 26°C) in july, 
# showing that places with higher summer temperatures are probably less optimal for this pine species because of the heat conditions
# it seems as if elevation and surface temperature might be two conditions limiting the pine in colonizing further habitats

