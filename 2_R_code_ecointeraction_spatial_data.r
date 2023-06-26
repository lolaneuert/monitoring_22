
### ecological interaction''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# this is a code for investigating relationships among ecological variables

# install necessary packages using function -install.packages(""), in this case sp, used for managing spatial data 
install.packages("sp")   # "" are used everytime one leaves R environment, for ex. when downloading new packages

# use function -library() to load/activate package for script in R, alternative function -require(): same result
library(sp)

# recall dataset using the function -data(), 
data(meuse) # this is a free dataset inside of the packages sp, it is the measurements of 4 heavy metals in top soil based in Northern Europe
# to get more info on the meuse dataset: https://cran.r.project.org/web/packages/gstat/vignettes/gstat.pdf

# use functions -view(), -head() or simply the name of the dataset to look inside the dataset
meuse # opens the complete dataset in the console(messy): it is a dataframe with 164 rows + additional columns (soil, landuse type, distance etc.)
View(meuse) # opens the dataframe in a new window, just as if you opened it in the environment, function is from package Rcmdr, therefore install.packages("Rcmdr"), library(Rcmdr) first
head(meuse) # opens the header and the first few rows of the dataframe in the console
names(meuse) # gives the names of the columns of the dataframe
# function -dev.off() is used to close opened windows


# 1st excersise: calculate the mean of all the variables
summary(meuse) # gives you the min, 1st quantile, median, mean, 3rd quantile and max values of each of the columns
mean(meuse$cadmium) # gives you the specific mean of one column


# 2nd exercise: plot zinc(y) against cadmium(x)
plot(meuse$cadmium, meuse$zinc)  # in order for r to recognize the column names, you can either specify them using $ or teach him the column names beforehand
dev.off() # to close the plot window

# to teach R the name of the columns you can link the dataframe meuse with the column names camium and zinc:
cadmium <- meuse$cadmium # use $ to specify which column and use <- to connect it to a new object 
zinc <- meuse$zinc 
plot(cadmium, zinc) # now one can simply plot c vs z and R knows where to take the data from

# using the function -attach $ is not necessary anymore, this function can only be used with dataframes
attach(meuse) # this attaches the database to the R search path, R therefore finds column inside meuse
plot(cadmium, zinc) # now you can simply plot c vs z and R looks in meuse for it
# if you want to detach again use function -detach()

# to create a scatterplot matrice with all the variables plotted against each other use function -pairs()
pairs(meuse) # shows mirrored image of all 14 variables: matrix of 14 x 13: 180 potential relationships, all plotted at once, very functional

# 2 options to pair just a few of the variables against each other
# to create a scatterplot matrix with only the element variables cadmium, copper, lead and zinc
pairs(meuse[,3:6]) # this way you specify that you only want the variables in columns 3-6 to be plotted
pairs(~ cadmium + copper + lead + zinc, data = meuse) # this way you specify the wanted variables by their column names

# to make the graph more appealing visually you only want cadmium, lead and zinc
pairs(~ cadmium + lead + zinc, data = meuse)

# now you want to change the color of the graphs
pairs(~ cadmium + lead + zinc, data = meuse, col = "darkorange2")

# to change the symbol in the graphs
pairs(~ cadmium + lead + zinc, data = meuse, col = "darkorange2", pch = 23)

# and increase the symbol size: 2 = double the size 
pairs(~ cadmium + lead + zinc, data = meuse, col = "darkorange2", pch = 23, cex = 2)


### Spatial data analysis ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# we want to use the dataset meuse for spatial analysis
# the function ~coordinates() either creates a spatial object, or in this case retrieves its coordinates
coordinates(meuse) = ~x+y

# the function ~plot() now shows how the data is spatially distributed
plot(meuse) 

# the function ~spplot() shows how variables, in this case elements like cadmium, lead etc. are concentrated spatially
spplot(meuse, "cadmium", main="Concentration of Cadmium") # plots the concentration of cadmium
spplot(meuse, "copper", main="Concentration of Copper") # plots the concentration of copper

# to see two variables use ~c(=concatenate) to attach both variables
spplot(meuse, c("copper","zinc"))

# to create a bubble-plot of spatial data use function ~bubble(), use ~col("") to edit the color of the bubble symbol
bubble(meuse, "zinc")
bubble(meuse, "lead", col="darkorchid4")
