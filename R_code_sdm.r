# this script is used to look at the SDM package (species distribution modeling)

setwd("C:/Rstudio/monitoring")

# install necessary packages and activate them 
install.packages("sdm")
install.packages("rgdal", dependencies = TRUE)
library(sdm)
library(raster)
library(rgdal)

# the function ~system.file lets you search for a specific file without its path
# in this case data that was downloaded as part of sdm, in a folder called external
file <- system.file("external/species.shp", package = "sdm")
species <- shapefile(file)
plot(species)
