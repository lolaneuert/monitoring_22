# this is a code for investigating relationships among ecological variables

# install necessary packages, in this case sp, used for managing spatial data, use library function to activate package for script
install.packages("sp")
library(sp)

# recall dataset using function data
data(meuse)

# look inside the dataset
meuse
view(meuse)
head(meuse)

# excersise 1
