source("2_load_social_influence_data.R")

model_name              <- Sys.getenv("MODELNAME")

print(model_name)

source(file.path("model_fitting_scripts",paste0(model_name,".R")))
 