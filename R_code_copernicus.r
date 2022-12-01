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
snow # >200 million pixels in one layer called Snow.Cover.Extent

# plot the data using ggplot and viridis # add a title
ggplot() + geom_raster(snow, mapping = aes(x = x, y = y, fill = Snow.Cover.Extent)) + scale_fill_viridis(option = "mako") + ggtitle("Snow Cover Extent 21.12.2020")# look at different bands using ggplot
  
# to have a closer look we cut the image down to a specific extention: in this case only europe should be covered
# for this we have to specify the minimum and maximum extent to cover the specified area as elements of an array: min x~-20, max x ~70, min y ~20, max y ~75 -> this are the coordinates at the corners of our subset 
ext <- c(-20, 70, 20, 75)
# now use function ~crop() to cut down the image into a geographical subset
snow_eu <- crop(snow, ext)

# now plot this
pic_snow_eu <- ggplot() + geom_raster(snow_eu, mapping = aes(x = x, y = y, fill = Snow.Cover.Extent)) + scale_fill_viridis(option = "mako") + ggtitle("Snow Cover Extent Europe 21.12.2020") 

# use the + from the patchwork package to plot both images next to each other
pic_snow + pic_snow_eu

