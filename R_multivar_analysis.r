# community ecology example using multivariate analysis in R


# set a working directory using function ~setwd() for R to save all documents, files, objects etc in: in this case it is in the folder monitoring (see path below)
setwd("C:/RStudio/monitoring")

# install necessary packages
install.packages("vegan") # = vegetation analysis, community ecology package
library(vegan)

# load the data from the wd using function ~load("") to import/reload a complete saved R project (with several files inside)
load("biomes_multivar.RData") # this data contains two tables: biomes.cv and biometypes.cv(?)

# now for the multivariate analysis use function ~decorana() (=detrended correspondence analysis, is just like PCA) and assign it to a name using <-
multivar <- decorana(biomes) # this simplifies the data by creating new data dimensions in a matrix, just like in a principal component analysis
multivar # this shows the properties of this list: 
# Call:
# decorana(veg = biomes) 

# Detrended correspondence analysis with 26 segments.
# Rescaling of axes with 4 iterations.

#                   DCA1   DCA2    DCA3    DCA4
# Eigenvalues     0.5117 0.3036 0.12125 0.14267     # so the first DCA explains 51% and the second 30%, these two dimensions already explain >80% of the data, much easier to interpret than all 26 dimensions
# Decorana values 0.5360 0.2869 0.08136 0.04814
# Axis lengths    3.7004 3.1166 1.30055 1.47888

plot(multivar) # use function ~plot() to visualize the matrix created by decorana in a plot showing the first two axis DCA1 and DCA2


# to now add the biome labels in the decorana graph first use function ~attach()) to attach the second table biomes_types
# then use function ~ordiellipse() to add a circle around those points who are in the same biome, define in which table; type to define which kind of ellipse, here factor = biomes; what colors; kind = ehull to make a specific shape of ellipse; and lwd = linewidth  
attach(biomes_types)
ordiellipse(multivar, type, col=c("cornsilk4","deeppink3","darkseagreen4","mediumpurple2"), kind = "ehull", lwd=2)
# now use function ~ordispider()  to attach the labels to the circles
attach(biomes_types)
ordispider(multivar, type, col=c("cornsilk4","deeppink3","darkseagreen4","mediumpurple2"), label = T)

# to save the plot in a pdf format use function ~pdf("")
pdf("multivar.pdf")
plot(multivar)
ordiellipse(multivar, type, col=c("cornsilk4","deeppink3","darkseagreen4","mediumpurple2"), kind = "ehull", lwd=2)
ordispider(multivar, type, col=c("cornsilk4","deeppink3","darkseagreen4","mediumpurple2"), label = T)
dev.off()

