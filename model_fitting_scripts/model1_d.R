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
    brm_args,
    max_treedepth = 15,
    init = function() {
      list(
        b = c(1.0,  # sit_values_initialrating2 (based on your posterior)
              0.42,  # delta_pos
              0.34), # delta_neg
        sd_subject__delta_pos = 0.3,  # Group-level SD for delta_pos
        sd_subject__delta_neg = 0.3,  # Group-level SD for delta_neg
        cor_subject__delta_pos__delta_neg = .7,  # Start at 0 for better mixing
        sigma = 1.1  # Start near estimated sigma
      )
    }
 )
  
model1 = do.call(brm, modelarg)
  
saveRDS(model1, file = paste0("/rds/user/gb424/hpc-work/model1",Sys.time(),".Rds"))

#saveRDS(model1, file = file.path("saved_models",paste0("model1_d",Sys.time(),".Rds")))
  


