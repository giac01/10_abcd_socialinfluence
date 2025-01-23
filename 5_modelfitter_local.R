#rm(list=ls())
#rstudioapi::restartSession()

source("2_load_social_influence_data.R")

Sys.setenv(REMOVE_PARTICIPANTS_FEW_TRIALS = TRUE)
Sys.setenv(VARIATIONAL = FALSE)

source(file.path("model_fitting_scripts","model1.R"))
 
