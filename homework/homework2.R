#HEADER-----------------------------------------
#
#Author:  Leping Chen
#Copyright
#Email:  2932348481@qq.com
#Date:  2024.3.13
#Script  Name:  'homework2'
#
#Setup-------------------------------------------

#finding and selecting packages
install.packages("packagefinder",dependebcies=TRUE)
library(packagefinder)
findPackage("tidyverse")

#installing the package
install.packages("tidyverse")

#helping yourself
help(package="tidyverse")

#Vignettes Demonstrations
vignette("tidyverse")
browseVignettes(package="tidyverse")
demo(package="tidyverse")

#Searching for help
apropos("tidyverse")
ls("package:tidyverse")
help.search("^tidyverse")