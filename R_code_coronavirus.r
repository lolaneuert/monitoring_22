# this file is used to analyse the (initial spatial spread) of the coronavirus using graphs from the package ggplot2

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

