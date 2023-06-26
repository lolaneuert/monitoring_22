### remote sensing with landsat data ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# this file is a first exploration of working with landsat data (30m spatial resolution, using data from 2011 in the amazon forest) 
# image is called p224r63_2011: path 224 and row 63 from 2011

library(raster)

# load image into R using the function ~brick which creates a Rasterbrick object that contains several bands of a satellite image, 
# formed by a pixelmatrix
p224r63_2011 <- brick("p224r63_2011_masked.grd") # use <- to assign the object to a name

# now plot the image using the function ~plot
plot(p224r63_2011)

# create a colorpalette using function ~colorRampPalette(c("")) over a gradient of 100 steps
color <- colorRampPalette(c("grey1", "grey40", "grey80"))(100) 

# now plot in the colors specified above
plot(p224r63_2011, col=color)

# use function ~par() to plot multiple graphs in one raster, specify the size with ~mfrow=(,) to 2 deep and 2 wide
par(mfrow=c(2,2))

# to display the different bands in different colors we create multiple color palettes and plot each one
# start with band 1 in blue
clb <- colorRampPalette(c("blue4", "royalblue2", "skyblue"))(100) 
plot(p224r63_2011$B1_sre, col=clb) # band 1 = B1_sre

# repeat for band 2 in green
clg <- colorRampPalette(c("dark green", "palegreen4", "darkseagreen1"))(100) 
plot(p224r63_2011$B2_sre, col=clg) # band 2 = B2_sre

# repeat for band 3 in red
clr <- colorRampPalette(c("brown4", "red3", "indianred1"))(100) 
plot(p224r63_2011$B3_sre, col=clr) # band 3 = B3_sre

# plot the final band, the NearInfraRed, which is band number 4 using a new color palette
clnir <- colorRampPalette(c("firebrick4", "darkorange2", "lightgoldenrod"))(100) 
plot(p224r63_2011$B4_sre, col=clnir) # band 4 = B4_sre 

# use function ~plotRGB to layer/stack the different bands on top of each other, 
# it is used to assign the different bands the different colours: red to red, blue to blue and green to green
par(mfrow = c(2,2)) # use function ~par(mfrow = c(,)) to create a frame with 4 images
plotRGB(p224r63_2011, r = 3, g = 2, b = 1, stretch = "Lin") # function ~stretch stretches the values in order to see 
# the difference between the colours, here it is lin for a linear stretch

plotRGB(p224r63_2011, r = 4, g = 3, b = 2, stretch = "Lin") # this stack shows the near infrared band on top, vegetation will be red, 
# this makes it great to observe the forest

plotRGB(p224r63_2011, r = 3, g = 4, b = 2, stretch = "Lin") # in this stack red and green are inverted, 
# in this colour scheme all the bare soil will be violet (called false colouring, as it is different from what human eyes see)

plotRGB(p224r63_2011, r = 3, g = 2, b = 4, stretch = "Lin") # band 4 is displayed in the blue channel, 
# here everything reflects nir in blue, this is powerful for detecting areas without vegetation 
# displayed in yellow, for ex. agricultural areas

# note: rectangular shapes always show human interventions!

# to stretch the histogram, instead of specifying lin use hist in the function ~stretch, this stretches the values 
# so you can look inside the forest better, for ex. detect better openings in the forest and bare soil
par(mfrow=c(2,1))
plotRGB(p224r63_2011, r=4, g=3, b=2, stretch="Lin")
plotRGB(p224r63_2011, r=4, g=3, b=2, stretch="hist")

### time series: comparison of images from 2011 and 1988 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

# load image from 2011 into R using the function ~brick which creates a Rasterbrick object that contains several bands 
p224r63_2011 <- brick("p224r63_2011_masked.grd")

# load image from 1988 in the same way in order to then compare the to images and see changes over time
p224r63_1988 <- brick("P224r63_1988_masked.grd")
 
# use function ~plot to have a quick look at the two images
plot(p224r63_1988)
plot(p224r63_2011)

# now use function ~plotRGB to stack the different bands (this time using the beds for their real assigned colours, 
# red for red band, green for green band and blue for the blue band)
plotRGB(p224r63_1988, r = 3, g = 2, b = 1, stretch = "Lin")

# put near infrared on top to detect vegetation (reflects in red)
plotRGB(p224r63_1988, r = 4, g = 3, b = 2, stretch = "Lin")

# now plot with red and green inverted
plotRGB(p224r63_1988, r = 3, g = 4, b = 2, stretch = "Lin")

# use function ~par(mfrow = c(,)) to show the timeseries of the same image in 1988 and in 2011
par(mfrow = c(2,1))
plotRGB(p224r63_1988, r = 3, g = 2, b = 1, stretch = "Lin")
plotRGB(p224r63_2011, r = 3, g = 2, b = 1, stretch = "Lin")

### multi-temporal analysis: calculate the differences between images '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# look at the same pixel in the same image to see the change over time 
# subtract value of one pixel in one image from the other image and assign it to the name difnir: 
# this shows differences in the near infrared which shows us for ex. deforestation
difnir <- p224r63_1988[[4]] - p224r63_2011[[4]]

# create a colorpalette using function ~colorRampPalette(c(""))
color <- colorRampPalette(c("black", "lightblue", "red"))(100) # small difference = black, medium dif = lightblue, high dif = red

# plot difnir
plot(difnir, col = color) # shows difference between 1988 to 2011: cut trees are shown in red, these are now agricultural areas 
# (as in tropical forests trees can extend multiple meters, one pixel (30m resolution) might even refer to a single cut tree)

# to highlight changes in vegetation there is the NDifferenceVegetationIndex NDVI (vegetation reflects a lot in the near infrared 
# (pixelvalue close to 1), but it reflects very little in the red band as it likes doing photosynthesis (very low value per pixel)
# the NDVI subtracts the RED from the NIR (for ex. 1-0.1 = 0.9), therefore high NDVI values show healthy vegetation
# sick plants have lower NIR values and higher RED values (no photosynthesis) 
# therefore for ex. 0.7-0.6 = 0.1 -> low NDVI values: no or sick plants

# calculate the NDVI for 2011
dvi2011 <- p224r63_2011[[4]]-p224r63_2011[[3]] # subtract RED band from NIR band
# plot the dvi
plot(dvi2011) # the higher the value the healthier the vegetation, the veins inside the forest that are less green are waterways

# show the difference over time between the NDVI values
difdvi <- dvi1988 - dvi2011
cl <- colorRampPalette(c("blue", "white", "red"))(100)
plot(difdvi, col = cl) # red points show loss in healthy vegetation over the time period
# blue points show additional vegetation, this is most likely new agricultural land on previous bare soil, for ex. palm oil plants
