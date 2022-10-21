# this file is used to analyse the initial spatial spread of the coronavirus using graphs from the package ggplot2
# 1. getting started with the package ggplot2 first

install.packages("ggplot2")
library(ggplot2)

# create a dataframe (table), using invented coronavirus values (case numbers = virus, death numbers = death)

virus <- c(10, 30, 40, 50, 60, 80) # use function ~ c() to collect values in a list and assign a name to the list using <-
death <- c(100, 240, 310, 470, 580, 690)

# to simply plot the two variables use function ~plot()
plot(virus, death)

# however, to connect the two arrays (virus and death) in the form of a dataframe use function ~data.frame()
data.frame(virus, death) # creates table with two columns, virus & death

# to assign the dataframe to an object that can then be used use <- 
corona <- data.frame(virus, death)

# use function ~summary() to get basic statistical information about object
summary(corona)

# use ggplot2 to create visual representations of the spread: use function ~ggplot to create graph
ggplot(corona, aes(x = virus, y = death)) + geom_point() 
# data = corona (dataframe), aes = aesthetics: view of the graph, which variables?
# use function ~geom_point() to add a geometrical reference to the data, in this case geometric point format (this makes sense for this data, as points were measured in space)

# to change the look of the graph we add arguments in the geo_point function
ggplot(corona, aes(x = virus, y = death)) + geom_point(size = 4,  col = "cornflowerblue", pch = 11) # changes the size and color and symbol of the point

# if instead we wanted to visualize lines (doesn't make sense with this data) use function ~geom_line
ggplot(corona, aes(x = virus, y = death)) + geom_line()

# to create a polygon use function ~geom_polygon()
ggplot(corona, aes(x = virus, y = death)) + geom_polygon()

# you can use ggplot2 to connect multiple geometric shapes simply by adding more functions with + 
ggplot(corona, aes(x = virus, y = death)) + geom_point + geom_line + geom_polygon()

# 2. now on to real data: case numbers by country from the beginning of the covid-19 pandemic

# recall the relevant packages using function ~library()
library(ggplot2)
library(spatstat)

# set a working directory using function ~setwd() for R to save all documents, files, objects etc in: in this case it is in the folder monitoring (see path below)
setwd("C:/RStudio/monitoring")

# now we can import the datafolder (downloaded from virtuale into wd set above) using the function ~read.table() to import data directly from the wd
covid <- read.table("covid_agg.csv", header = TRUE)  # to import the head of the doc as a head, which doesn't contain data in R aswell, set the header = TRUE

# get a first look at the data we just imported
covid # prints the whole dataset in the console
head(covid) # prints the first few lines of the dataset in the console
summary(covid) # calculates the basic statistic parameters for the dataset

# use function ~ggplot() to visualize the data from the set, we are using lon and lat as x and y 
ggplot(covid, aes(x = lon, y = lat)) + geom_point()
# set the size of the points to cases so the symbol increases with case number at the different locations
ggplot(covid, aes(x = lon, y = lat, size = cases)) + geom_point()

# let's see the density of the coronavirus cases 
# use function ~ppp() from the spatstat package to create a planar point pattern  
attach(covid) # let's first attach the dataset to make sepcification easier (don't need $ to specify column names lat ,lon etc.)
covid_planar <- ppp(lon, lat, c(-180, 180), c(-90, 90)) # lon and lat are x and y, function ~c() is used to tell R the range to be used

# to now print a density map of the case numbers by country use function ~density()
density_map <- density(covid_planar)

plot(density_map) # simply plot the density of cases calculated above
points(covid_planar) # add the points of the cases for each country

# to visually change the map create a list of colors using function ~colorRampPalette(c())
colors <- colorRampPalette(c('blue','yellow','orange','red','magenta'))(100)
plot(density_map, col = colors) # now specify the color by setting col = the list created above
points(covid_planar) # add the points of cases for each country

# next we want to add the countries to the map
# install  and activate necessary packages
install.packages("rgdal")
library(rgdal)

