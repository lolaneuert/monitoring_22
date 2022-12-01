# this script is on the topic of copernicus remote imaging data and how to analyse it in R

Copernicus set:
# https://land.copernicus.vgt.vito.be/PDF/portal/Application.html
# Register and Login
# Download data from Cryosphere (Snow Cover Extent 1km v1- 21.12.2020)
# The arrow should be blue
# Info: https://land.copernicus.eu/global/content/sce-nhemi-product-s-npp-viirs-data-affected

# install and load necessary packages
install.packages("ncdf4")
library(ncdf4) # to read .nc files (nc files are )
library(raster)
library(ggplot2)
library(RStoolbox)
library(viridis) # to visualize (color gamut)
library(patchwork) # to create easy multiframes of ggplots

# load the image (downloaded from copernicus: cryosphere data, Snow Cover Extent 1km v1, 21.12.2020)
# the function ~raster() imports a RasterLayer (other than ~brick(), this only imports single layers at a time, instead of the whole image)
snow <- raster("C:/RStudio/monitoring/c_gls_SCE_202012210000_NHEMI_VIIRS_V1.0.1.nc")

