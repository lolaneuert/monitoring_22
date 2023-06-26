
# ggplot2 and interpolation of case data ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# this file is used to analyse the initial spatial spread of the coronavirus using graphs from the package ggplot2
# 1st getting started with the package ggplot2

# download and load necessary package
install.packages("ggplot2")
library(ggplot2)

# create a dataframe (table), using invented coronavirus values (case numbers = virus, death numbers = death)
virus <- c(10, 30, 40, 50, 60, 80) # use function ~c() to collect values in a list and assign a name to the list using <-
death <- c(100, 240, 310, 470, 580, 690)

# to simply plot the two variables use function ~plot()
plot(virus, death)

# however, to connect the two arrays (virus and death) in the form of a dataframe use function ~data.frame()
data.frame(virus, death) # creates table with two columns, virus & death

# to assign the dataframe to an object that can then be used use <- the assignment operator
corona <- data.frame(virus, death)

# use function ~summary() to get basic statistical parameters about object
summary(corona)

# use ggplot2 to create visual representations of the spread: use function ~ggplot to create graph
ggplot(corona, aes(x = virus, y = death)) + geom_point() 
# data = corona (dataframe), aes = aesthetics: view of the graph, which variables?
# use function ~geom_point() to add a geometrical reference to the data, in this case geometric point format 
# this makes sense for this data, as points were measured in space

# to change the look of the graph we add arguments in the geom_point function
ggplot(corona, aes(x = virus, y = death)) + geom_point(size = 4,  col = "cornflowerblue", pch = 11) 
# pch changes the size and color and symbol of the point

# if instead we wanted to visualize lines (doesn't make sense with this data) use function ~geom_line
ggplot(corona, aes(x = virus, y = death)) + geom_line()

# to create a polygon use function ~geom_polygon()
ggplot(corona, aes(x = virus, y = death)) + geom_polygon()

# you can use ggplot2 to connect multiple geometric shapes simply by adding more functions with + 
ggplot(corona, aes(x = virus, y = death)) + geom_point + geom_line + geom_polygon()

# 2nd now on to real data: case numbers by country from the beginning of the covid-19 pandemic (load data from external source)

# recall the relevant packages using function ~library()
library(ggplot2)
library(spatstat) # spatial statistics

# set a working directory using function ~setwd() for R to save all documents, files, objects etc in: 
# in this case it is in the folder monitoring (see path below)
setwd("C:/RStudio/monitoring")

# now we can import the datafolder (downloaded from virtuale into wd set above) 
# using the function ~read.table() to import data directly from the wd
covid <- read.table("covid_agg.csv", header = TRUE)  # to import the head of the doc as a head, 
# which doesn't contain data in R aswell, set the header = TRUE

# get a first look at the data we just imported
covid # prints the whole dataset in the console
head(covid) # prints the first few lines of the dataset in the console
summary(covid) # calculates the basic statistic parameters for the dataset

# use function ~ggplot() to visualize the data from the set, we are using lon and lat as x and y 
ggplot(covid, aes(x = lon, y = lat)) + geom_point()
# set the size of the points to cases so the symbol increases with case number at the different locations
ggplot(covid, aes(x = lon, y = lat, size = cases)) + geom_point()

### let's see the density of the coronavirus cases - Point pattern analysis
# use function ~ppp() from the spatstat package to create a planar point pattern, which explains to R that we are working 
# on a geographical lattice (lat and lon) as well as explain the extent  
attach(covid) # let's first attach the dataset to make sepcification easier (don't need $ to specify column names lat, lon etc.)
covid_planar <- ppp(lon, lat, c(-180, 180), c(-90, 90)) # lon and lat are x and y, 
# function ~c() is used to tell R the range to be used in the form of an array
plot(covid_planar) # take a look at the ppp object created 

# to now print a density map of the case numbers by country use function ~density()
density_map <- density(covid_planar)

plot(density_map) # simply plot the density of cases calculated above (plot overrides previous function/map)
points(covid_planar, pch = 19) # add the points of the cases for each country (points adds object to the previous function/map)

# to visually change the map create a list/legend of colors using function ~colorRampPalette(c()) over a 100 step gradient (?)
colors <- colorRampPalette(c('blue4', 'cadetblue4', 'darkgoldenrod2', 'tan2', 'sienna3', 'firebrick4', 'violetred4', 'purple4'))(100)
plot(density_map, col = colors) # now specify the color by setting col = the list created above
points(covid_planar, pch = 5, ) # add the points of cases for each country

# next we want to add the countries to the map
# install and activate necessary packages
install.packages("rgdal")
library(rgdal)

# after downloading the folder ne 10m coastline, open it using function ~readOGR, which reads a vector map into a spatial object
coastlines <- readOGR("ne_10m_coastline.shp")

# now to combine the density map and the country borders we create a new color gradient, plot the density map and 
# insert the points from covid_planar as well as the coastlines
cl <- colorRampPalette(c('lightskyblue4','chartreuse4','goldenrod3','lightsalmon3','sienna4'))(100) # 
plot(density_map, col = cl)  # plot the density map
points(covid_planar, pch = 1, col = 'blue', cex = 0.8) # add the points
plot(coastlines, add = TRUE) # add the coastline

# if we want to download this map we can for example do it in png as well as pdf format by using function ~png("") or pdf("")
png("cov_density_countries.png")
c2 <- colorRampPalette(c('steelblue','slategray','seashell2','rosybrown','navajowhite4'))(100)
plot(density_map, col = c2) 
points(covid_planar, pch = 16, col = 'black', cex = 1)
plot(coastlines, add = TRUE) 
dev.off() # closes the window with the map

pdf("cov_density_countries.pdf")
c3 <- colorRampPalette(c('mistyrose3','pink4','violetred','red4','indianred'))(100)  
plot(density_map, col = c3) 
points(covid_planar, pch = 4, col = 'black', cex = 1)
plot(coastlines, add = TRUE) 
dev.off()

### interpolate case data '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# but these maps simply show the density based on the points, obviously in Europe there is 
# a high country density = highest density of points
# however the parameter abundance is much more informative, as it actually interpolates the number of cases

# 3rd we can do this using the function ~marks(), which assigns data to the points given in covid_planar
attach(covid)
marks(covid_planar) <- cases  # cases is the name of the relevant variable in the original array covid,
# which we attach here, as covid_planar is simply a list of points

# using the function ~Smooth it interpolates the point data given in covid_planar and assigns it the new name map_cases
map_cases <- Smooth(covid_planar)
                    
# to plot this map we use function ~plot
plot(map_cases, col = c2) 
points(covid_planar, pch = 19) # add points
plot(coastlines, add = T) # adds coastlines    
                    
# next we download the package sf
install.packages("sf") # used for spatial vector data
library(sf)

# use function ~st_as_st() to convert the covid object to an sf object(extends data.frame-like objects with a simple feature list column) 
s_points <- st_as_sf(covid, coords = c("lon", "lat"))

# create a new color palette
c1 <- colorRampPalette(c("antiquewhite4", "aquamarine4", "darkslategray", "coral4", "firebrick3"))(100)
plot(map_cases, col = c1) # plot the smoothed case map
plot(s_points, cex = s_points$cases/10000, col = "purple4", lwd = 3, add = T) # add circles around the countries with high case numbers, 
# depending on their absolute value

# now we add on the coastlines to the smoothed map above
coastlines <- readOGR("ne_10m_coastline.shp")
plot(coastlines, add = T)
