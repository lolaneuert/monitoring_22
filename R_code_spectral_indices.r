# This script shows the basics of vegetiation indices calculation from remote sensing data

# activate necessary libraries
library(raster)
library(RStoolbox)
library(ggplot2)
install.packages("patchwork")
library(patchwork)
install.packages("gridExtra")
library(gridExtra)
install.packages("viridis")
library(viridis)

# images from https://earthobservatory.nasa.gov/images/35891/deforestation-in-mato-grosso-brazil
# load images
l1992 <- brick("defor1.png") # load the image using the function ~brick()
l1992 # for a quick look at image-information (here bands: 1 NIR, 2 red, 3 green)
plotRGB(l1992, r = 1, g = 2, b = 3, stretch = "lin") # create a different stack of bands: so NIR displayed in red, red in green and green in blue channel)

l2006 <- brick("defor2.png") # load the image using the function ~brick()
l2006 # for a quick look at image-information (here bands: 1 NIR, 2 red, 3 green)
plotRGB(l1992, r = 1, g = 2, b = 3, stretch = "lin") # create a different stack of bands: so NIR displayed in red, red in green and green in blue channel)

# NIR 
par(mfrow = c(2,1)) # use function ~par(mfrow = c()) to add frames one on top of each other
plotRGB(l1992, r = 1, g = 2, b = 3, stretch = "lin")
plotRGB(l2006, r = 1, g = 2, b = 3, stretch = "lin")

# NDVI
dvi1992 <- l1992[[1]] - l1992[[2]] # create the ndvi for the 1992 image by subtracting band 2 from band 1
cl <- colorRampPalette(c("darkblue", "yellow", "red", "black"))(100)  # create a color palette         
plot(dvi1992, col = cl)

dvi2006 <- l2006[[1]] - l2006[[2]] # create the ndvi for the 2006 image in the same way

# plot both ndvis one above each other
par(mfrow = c(2,1))  
plot(dvi1992, col = cl
plot(dvi2006, col = cl)



# classification of spectral images: see how many trees have been cut down in the amazon rainforest
# classification 1992 (deforestation period d1)
# unsupervised classification  = ...

# threshold for trees in the 1992 image
d1c <- unsuperClass(l1992, nClasses = 2) # use function ~unsuperClass() to do an unsupervised clustering of Raster* data using kmeans clustering
plot(d1c$map)

# calculate the frequencies of pixels belonging to the two classes forest and human impact in 1992
freq(d1c$map)
# class 1: forest: 307886 pixels
# class 2: human impact: 33406  pixels
f1992 <- 307886/(307886+33406) # forest ratio ~ 90%
h1992 <- 33406/(307886+33406) # human impact ratio ~ 10%


# classification 2006 (deforestation period d2)
# threshold for trees in the 2006 image
d2c <- unsuperClass(l2006, nClasses = 2) # use function ~unsuperClass() to...
plot(d2c$map)

# calculate the frequencies of pixels belonging to the two classes forest and human impact in 2006
freq(d2c$map) # using function ~freq()
# this time the two classes have switched
# class 1: human impact: 164219
# class 2: forest: 178507
f2006 <- 178507/(178507+164219) # forest ratio ~ 52% : decreased by 40% in less than 15 years
h2006 <- 164219/(178507+164219) # human impact ratio ~ 48%

# now compare change over time from 1992 to 2006: use function ~data.frame() to create a table containing all frequencies of forest and human impact pixels
landcover <- c("Forest", "Humans") # first create the object columns: these are the two types
percent_1992 <- c(90.21, 9.79) # then the percentages for the 1992 image
percent_2006 <- c(52.08, 47.92) # and the percentages for the 2006 image

proportions <- data.frame(landcover, percent_1992, percent_2006) # create a data frame containing these columns 
proportions

        
# create a histogram plot using the ggplot2 library for the 1992 image
hist_1992 <- ggplot(proportions, aes(x = landcover, y = percent_1992, color = landcover)) + geom_bar(stat = "identity", fill = "darkseagreen")
hist_1992 # plot it 
# start with function ~ggplot(), then add the name of the object that is to be used as a basis table
# aes = aesthetics: used to specify x, y, and the colors, here x is the landcover, so either forest or human, and y is the percentage of the different covers in the 1992 image, for the color we again use the landcover variable
# use + to add additional elements into the graph: here for histograms we need geom_bar (here specify the type of statistics, here we use "identity" so it is identical to the data in the table (not means, SE etc.), and specify the fill color
      
# repeat the histogram plot for the 2006 image
hist_2006 <-  ggplot(proportions, aes(x = landcover, y = percent_2006, color = landcover)) + geom_bar(stat = "identity", fill = "darkseagreen")
hist_2006

# create a frame with both histograms together without using the function ~mfrow (multiframe) simply by using a + after activating the patchwork package
hist_1992 + hist_2006 # shows you the two plots next to each other
hist_1992 / hist_2006 # shows you the first plot on top of the second one

# for this we could also use the function ~grid.arrange from the gridExtra package, specifying the two plots as well as the number of rows
grid.arrange(hist_1992, hist_2006, nrow=1)
       
# look at different bands using ggplot
l1992
plotRGB(l1992, r = 1, g = 2 , b = 3, stretch = "lin") # plot it in RGB, band 1 is the NIR
ggRGB(l1992, 1, 2, 3) # this function does the same as function ~plotRGB without specifying as many details

# you can also plot the DVI 
plot(dvi1992) # this one we calculated above
ggplot() + geom_raster(dvi1992, mapping = aes(x = x, y = y, fill = layer))
# this time we use a new geometry: geom_raster, specify which raster, in this case the dvi and specify the aes, but we need to type mapping in front
# for fill we specify the layer name, which is however called layer (check in dvi1992)

# using the package viridis we use color palettes that are suitable for people with daltonism (the palette turbo is not good for them)
dvi_gg_1992 <- ggplot() + geom_raster(dvi1992, mapping = aes(x = x, y = y, fill = layer)) + scale_fill_viridis(option = "inferno") + ggtitle ("Multispectral DVI 1992")
# the function ~scale_fill_viridis allows you to choose the palette, this time we choose viridis

# repeat for the 2006 image
dvi_gg_2006 <- ggplot() + geom_raster(dvi2006, mapping = aes(x = x, y = y, fill = layer)) + scale_fill_viridis(option = "magma") + ggtitle ("Multispectral DVI 2006")

# use the package patchwork to stack them one beside the other
dvi_gg_1992 + dvi_gg_2006

        
        
        
        
