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

# use function ~plotRGB to layer the different bands on top of each other??
plotRGB(p224r63_2011, r=3, g=2, b=1, stretch="Lin")
plotRGB(p224r63_2011, r=4, g=3, b=2, stretch="Lin")
plotRGB(p224r63_2011, r=3, g=4, b=2, stretch="Lin")
plotRGB(p224r63_2011, r=3, g=2, b=4, stretch="Lin")
