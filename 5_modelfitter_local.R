#rm(list=ls())
#rstudioapi::restartSession()
Sys.setenv(REMOVE_PARTICIPANTS_FEW_TRIALS = TRUE)
Sys.setenv(VARIATIONAL = FALSE)
Sys.setenv(SMALL_SAMPLE = TRUE)
Sys.setenv(MYSEED = 2)
Sys.setenv(WARMUP = 1000)
Sys.setenv(ITER = 1500)
Sys.setenv(CHAINS = 2)
Sys.setenv(ADAPTDELTA = .95)


source("2_load_social_influence_data.R")


source(file.path("model_fitting_scripts","model1_f.R")) 

