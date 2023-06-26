### SDM data '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' 
# this script is used to look at the SDM package (species distribution modeling)

setwd("C:/Rstudio/monitoring")

# install necessary packages and activate them 
install.packages("sdm")
install.packages("rgdal", dependencies = TRUE)
library(sdm)
library(raster)
library(rgdal)

# the function ~system.file lets you search for a specific file without its path
# in this case data that was downloaded as part of sdm, in a folder called external
file <- system.file("external/species.shp", package = "sdm")
species <- shapefile(file)

# look at species shapefile
plot(species)
species

# sql (structured query language) used to subset data
# the column Occurrence is == 1 (equal in sql is written with double =) and to stop the selection after 1 we add a ,
# so we select only presence of species
presence <- species[species$Occurrence == 1,]
presence$Occurrence # gives now only 1s
plot(presence)

# or select only the absence of species
absence <- species[species$Occurrence == 0,]
absence$Occurrence
plot(absence)

# now plot presences and add absences using function ~points (as another plot function would overwrite the first one)
plot(presence, col ="darkgreen", pch = 15)
points(absence, col = "lightblue", pch = 19)

# we add more data, this time it is raster data, the predictors (determinantes of species absence/presence, 
# physical conditions like temp, rain, elevation etc)
# for this look at folder from above, we look at ascii files (~comma separated image file)
path <- system.file("external", package = "sdm")

# to list the predictors in this folder use function ~list.files, looking for asc in the patterns ( the $ shows that asc is an extension)
lst <- list.files(path = path, pattern = "asc$", full.names = TRUE)
lst # this shows us there are 4 files with an asc extension in the folder: elevation, precipitation, temperature, vegetation

# we create a stack of these files using the function ~stack
preds <- stack(lst)
# create a color palette
cl <- colorRampPalette(c("purple", "red", "orange", "yellow")) (100)
plot(preds, col=cl)

# plot predictors and occurrences
plot(preds$elevation, col=cl)
points(species[species$Occurrence == 1,], pch=15)

plot(preds$temperature, col=cl)
points(species[species$Occurrence == 1,], pch=15)

plot(preds$precipitation, col=cl)
points(species[species$Occurrence == 1,], pch=15)

plot(preds$vegetation, col=cl)
points(species[species$Occurrence == 1,], pch=15)

### create model '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# we want to establish relationships between the point data and the predictors to complete the model
# first we set the training data (objects = species, points) and the predictors for the sdm into a new object containing all the data
datasdm <- sdmData(train=species, predictors=preds)

# now run the model using the function ~sdm, plotting the occurrence of the frogs (nr of records = 200) with the 4 predictors
# the used method is glm (generalized linear model) with all variables together
m1 <- sdm(Occurrence ~ elevation + precipitation + temperature + vegetation, data = datasdm, methods = "glm")

# make the raster output layer using the function ~predict, this predicts the spread of the species based on the input data
p1 <- predict(m1, newdata = preds)

# plot the output using the color from above, then add the point data of the actual species presence
plot(p1, col=cl)
points(species[species$Occurrence == 1,], pch = 17)

# add to the stack, so one can see all rasters together
s1 <- stack(preds, p1)
plot(s1, col=cl)
