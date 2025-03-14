#rm(list=ls())
#rstudioapi::restartSession()
Sys.setenv(REMOVE_PARTICIPANTS_FEW_TRIALS = TRUE)
Sys.setenv(VARIATIONAL = FALSE)
Sys.setenv(SMALL_SAMPLE = FALSE)
Sys.setenv(MYSEED = 1001)
Sys.setenv(WARMUP = 1000)
Sys.setenv(ITER = 2000)
Sys.setenv(CHAINS = 4)
Sys.setenv(ADAPTDELTA = .965)

source("2_load_social_influence_data.R")

source(file.path("model_fitting_scripts","model1_g.R")) 

saveRDS(model1, file = file.path("saved_models",paste0("model1_g_seed1001",Sys.time(),".Rds")))


