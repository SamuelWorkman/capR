#Requirements
library(roxygen2)
library("devtools", lib.loc="~/R/win-library/3.4")

#load package and run function getData
setwd("~/capR/CapRpackage")
load_all()
document()
devtools::check()
setwd("..")
install("CapRpackage")

#testing (note that RCurl should be installed as a dependent, but doesn't work yet)
library(RCurl)
#call the getData function to pull US hearings (works!)
data<-getData("US","hearings")
#proofoflife
hist(data$year)

#call the getData function to pull ES bills (link is not programmed, so it should print an error message -- does not work!, but does return empty df)
data2<-getData("ES","bills")

