# This script shows the basics of vegetiation indices calculation from remote sensing data

# activate necessary libraries
library(raster
library(RStoolbox)

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
plotRGB(l1992, r = 1, g = 2, b = 3, stretch = "lin")

# NDVI
dvi1992 <- l1992[[1]] - l1992[[2]] # create the ndvi for the 1992 image by subtracting band 2 from band 1
cl <- colorRampPalette(c("darkblue", "yellow", "red", "black"))(100)  # create a color palette         
plot(dvi1992, col = cl)

dvi2006 <- l2006[[1]] - l1992[[2]] # create the ndvi for the 2006 image in the same way

# plot both ndvis one above each other
par(mfrow = c(2,1))  
plot(dvi1992, col = cl)
plot(dvi2006, col = cl)



# classification 1992 (deforestation period d1)
# unsupervised classification  = ...

# threshold for trees in the 1992 image
d1c <- unsuperClass(l1992, nClasses = 2) # use function ~unsuperClass() to...
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
f2006 <- 178507/(178507+164219) # forest ratio ~ 52%
h2006 <- 164219/(178507+164219) # human impact ratio ~ 48%
