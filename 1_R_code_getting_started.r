### first R introduction to monitoring''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# this is a first code script to get a basic understanding of R and how to use it

# first create an array using the concatenate function ~c()
pescivores <- c(5, 17, 43, 61, 88)  
pescivores

# then create a second set of data
herbivores <- c(134, 75, 34, 12, 3)
herbivores

# now we create a first plot in R using ~plot()
plot(pescivores, herbivores)

# we can add different elements to this plot
plot(pescivores, herbivores, col = "cadetblue4") # change the color (look at r-charts.com for different colours)

plot(pescivores, herbivores, col = "chocolate3", pch = 15) # change the shape of the points

plot(pescivores, herbivores, col = "cyan4", pch = 17, cex = 2) # change the scale of the points

plot(pescivores, herbivores, col = "deeppink3", pch = 5, cex = 6) # go even bigger

# we can add simple titles
plot(pescivores, herbivores, col = "orange", pch = 18, cex = 6, main = "My first ecological graph in R!")

# next we create a dataframe
ecodata <- data.frame(pescivores, herbivores)
ecodata

# we can do simple calculations, like mean number of individuals per site
(5 + 17 + 43 + 61 + 88)/5 # 42.8

# to see some summary statistics of the dataframe use function ~summary()
summary(ecodata) 
# pescivores     herbivores   
# Min.   : 5.0   Min.   :  3.0  
# 1st Qu.:17.0   1st Qu.: 12.0  
# Median :43.0   Median : 34.0  
# Mean   :42.8   Mean   : 51.6  
# 3rd Qu.:61.0   3rd Qu.: 75.0  
# Max.   :88.0   Max.   :134.0  
