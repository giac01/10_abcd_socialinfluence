modelarg =  c(
    list(
      formula =   bf(  sit_values_finalrating2 ~ 0 + sit_values_initialrating2 + delta_pos + delta_neg + (0 +  delta_pos + delta_neg | subject)
      ),
      prior =  c(
        prior(normal(0, .707), class = "b"),
        prior(normal(0, .707), class = "sd"),
        prior(lkj_corr_cholesky(.4), class = "L")
        # prior(normal(0, .707), dpar = "sigma")
      )
    ),
    # sample_prior = "only",
    brm_args
 )
  
model1 = do.call(brm, modelarg)
  
saveRDS(model1, file = paste0("/rds/user/gb424/hpc-work/model1",Sys.time(),".Rds"))

#saveRDS(model1, file = file.path("saved_models",paste0("model1_c",Sys.time(),".Rds")))
  


