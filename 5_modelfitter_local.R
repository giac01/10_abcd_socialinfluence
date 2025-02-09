#rm(list=ls())
#rstudioapi::restartSession()
Sys.setenv(REMOVE_PARTICIPANTS_FEW_TRIALS = TRUE)
Sys.setenv(VARIATIONAL = FALSE)
Sys.setenv(SMALL_SAMPLE = FALSE)
Sys.setenv(MYSEED = 2)
Sys.setenv(WARMUP = 1500)
Sys.setenv(ITER = 2500)
Sys.setenv(CHAINS = 4)
Sys.setenv(ADAPTDELTA = .975)


source("2_load_social_influence_data.R")


source(file.path("model_fitting_scripts","model1_d.R")) 

