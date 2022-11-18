# this file is a first exploration of working with landsat data (30m spatial resolution, using data from 2011 in the amazon forest) 
# image is called p224r63_2011: path 224 and row 63 from 2011

library(raster)

# load image into R using the function ~brick which creates a Rasterbrick object that contains several bands of a satellite image, formed by a pixelmatrix
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

# use function ~plotRGB to layer/stack the different bands on top of each other, it is used to assign the different bands the different colours: red to red, blue to blue and green to green
par(mfrow = c(2,2)) # use function ~par(mfrow = c(,)) to create a frame with 4 images
plotRGB(p224r63_2011, r = 3, g = 2, b = 1, stretch = "Lin") # function ~stretch stretches the values in order to see the difference between the colours, here it is lin for a linear stretch
plotRGB(p224r63_2011, r = 4, g = 3, b = 2, stretch = "Lin") # this stack shows the near infrared band on top, vegetation will be red, this makes it great to observe the forest
plotRGB(p224r63_2011, r = 3, g = 4, b = 2, stretch = "Lin") # in this stack red and green are inverted, in this colour scheme all the bare soil will be violet (called false colouring, as it is different from what human eyes see)
plotRGB(p224r63_2011, r = 3, g = 2, b = 4, stretch = "Lin") # band 4 is displayed in the blue channel, here everything reflects nir in blue, this is powerful for detecting areas without vegetation (displayed in yellow, for ex. agricultural areas)

# note: rectangular shapes always show human interventions!

#to stretch the histogram instead of specifying lin use hist in the function ~stretch
par(mfrow=c(2,1))
plotRGB(p224r63_2011, r=4, g=3, b=2, stretch="Lin")
plotRGB(p224r63_2011, r=4, g=3, b=2, stretch="hist") # stretches the values so you can look inside the forest better, for ex. detect better openings in the forest and bare soil



# load image from 2011 into R using the function ~brick which creates a Rasterbrick object that contains several bands of a satellite image, formed by a pixelmatrix
p224r63_2011 <- brick("p224r63_2011_masked.grd")

# load image from 1988 in the same way in order to then compare the to images and see changes over time
p224r63_1988 <- brick("P224r63_1988_masked.grd")
 
# use function ~plot to have a quick look at the two images
plot(p224r63_1988)
plot(p224r63_2011)

# now use function ~plotRGB to stack the different bands (this time using the beds for their real assigned colours, red for red band, green for green band and blue for the blue band)
plotRGB(p224r63_1988, r = 3, g = 2, b = 1, stretch = "Lin")

# put near infrared on top to detect vegetation (reflects in red)
plotRGB(p224r63_1988, r = 4, g = 3, b = 2, stretch = "Lin")

# now plot with red and green inverted
plotRGB(p224r63_1988, r = 3, g = 4, b = 2, stretch = "Lin")

# use function ~par(mfrow = c(,)) to show the timeseries of the same image in 1988 and in 2011
par(mfrow = c(2,1))
plotRGB(p224r63_1988, r = 3, g = 2, b = 1, stretch = "Lin")
plotRGB(p224r63_2011, r = 3, g = 2, b = 1, stretch = "Lin")
