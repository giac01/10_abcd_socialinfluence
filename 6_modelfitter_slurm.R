source("2_load_social_influence_data.R")

model_name              <- Sys.getenv("MODELNAME")
my_seed                 <- Sys.getenv("MYSEED")

print(model_name)

source(file.path("model_fitting_scripts",paste0(model_name,".R")))

saveRDS(model, file = paste0("/rds/user/gb424/hpc-work/",model_name,"seed",my_seed,"-",Sys.time(),".Rds"))