### LST greenland data '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' 
# this script shows the land surface temperature (ice melt) in greenland using remote sensing data

# activate necessary packages
install.packages("rasterVis")
install.packages("colorist")
library(raster)
library(ggplot2)
library(RStoolbox)
library(viridis)
library(patchwork)
library(rasterVis)
library(rgdal)
library(colorist)

# import data using the function ~raster() (single images of land surface temperature)
lst_2000 <- raster("lst_2000.tif")
lst_2005 <- raster("lst_2005.tif")
lst_2010 <- raster("lst_2010.tif")
lst_2015 <- raster("lst_2015.tif")

# plot the images using ggplot and the viridis color palette 
# the ~direction = parameter in viridis allows us to switch the legend color gradient when setting it to -1: here necessary, 
# because the lower the temp, the more ice
gg_lst_2000 <- ggplot() + geom_raster(lst_2000, mapping = aes(x = x, y = y, fill = lst_2000)) + scale_fill_viridis(option = "mako") 
            + ggtitle("LST Greenland 2000")
gg_lst_2005 <- ggplot() + geom_raster(lst_2005, mapping = aes(x = x, y = y, fill = lst_2005)) + scale_fill_viridis(option = "mako") 
            + ggtitle("LST Greenland 2005")
gg_lst_2010 <- ggplot() + geom_raster(lst_2010, mapping = aes(x = x, y = y, fill = lst_2010)) + scale_fill_viridis(option = "mako") 
            + ggtitle("LST Greenland 2010")
gg_lst_2015 <- ggplot() + geom_raster(lst_2015, mapping = aes(x = x, y = y, fill = lst_2015)) + scale_fill_viridis(option = "mako") 
            + ggtitle("LST Greenland 2015")
 
# the ~alpha = parameter in viridis allows us to set transparency, the closer to 0, the more transparent
ggplot() + geom_raster(lst_2000, mapping = aes(x = x, y = y, fill = lst_2000)) 
         + scale_fill_viridis(option = "mako", direction = 1, alpha = 0.8) + ggtitle("LST Greenland 2000")

# create a multiframe with the patchwork package( or using par(mfrow = c(2,2), adding all 4 images together
(gg_lst_2000 + gg_lst_2005) / (gg_lst_2010 + gg_lst_2015)
 
# how to import/manipulate multiple images in an automated way using a loop with the function ~lapply, 
# that applies a function over a list or vector
# lapply returns a list of the same length as X, each element of which is the result of applying the function ~FUN 
# to the corresponding element of X.
# but first create a list of files using the function ~list.files(), selecting the wanted files using the parameter pattern =, 
# which looks for elements, the wanted files have in common
rlist <- list.files(pattern = "lst") # this creates a list of the 4 files containing the element "lst" inside their title inside the wd

# the function ~lapply() can now be used on this list, specifying the list in place of x and then the wanted function for lapply 
imported_lst <- lapply(rlist, raster)

# use the function ~stack() to create a stacked set of raster layers
Temp_Gr <- stack(imported_lst)
Temp_Gr
plot(Temp_Gr)

# we can also use the stacked data to create individual layers if we specify them in squared brackets and the fill parameter
temp2000 <- ggplot() + geom_raster(Temp_Gr[[1]], mapping = aes(x = x, y = y, fill = lst_2000)) 
         + scale_fill_viridis(option = "inferno", direction = -1) + ggtitle("LST Greenland 2000")
temp2015 <- ggplot() + geom_raster(Temp_Gr[[4]], mapping = aes(x = x, y = y, fill = lst_2015)) 
         + scale_fill_viridis(option = "inferno", direction = -1) + ggtitle("LST Greenland 2015")

# add them together in one plot
temp2000 + temp2015

# let's calculate the temp difference between these two images by subtracting the older from the more recent layer 
# (specify inside the Temp_Gr stack)
dif_Temp <- Temp_Gr[[4]] - Temp_Gr[[1]]
# and plot it like before
dif_gg <- ggplot() + geom_raster(dif_Temp, mapping = aes(x = x, y = y, fill = layer)) 
       + scale_fill_viridis(option = "plasma", direction = -1) + ggtitle("Difference in LST Greenland 2000-2015")
dif_gg

# plot 2000, 2015 and their difference next to each other
temp2000 + temp2015 + dif_gg

# one could use package ~colorist to display this data
