modelarg =  c(
  list(
    formula =   bf(  sit_values_finalrating2 ~ 1 + sit_values_initialrating2 + delta_pos + delta_neg + (0 +  delta_pos + delta_neg |ID1| subject),
                     sigma ~ 1 + (1 |ID1| subject)
    )
    # prior =  c(
    #   prior(normal(0, .707), class = "b"),
    #   prior(normal(0, .707), class = "sd"),
    #   prior(lkj_corr_cholesky(.4), class = "L")
    #   # prior(normal(0, .707), dpar = "sigma")
    # )
  ),
  # sample_prior = "only",
  brm_args,
  # max_treedepth = 15,
  init = function() {
    list(
      b = c(
        1.0,  
        0.4,  
        0.3
      ), # delta_neg
      Intercept = -.1,
      Intercept_sigma = -.1,
      sd_subject__delta_pos = 0.25,  # Group-level SD for delta_pos
      sd_subject__delta_neg = 0.25,  # Group-level SD for delta_neg
      sd_sigma__Intercept = .6,
      cor_subject__delta_pos__delta_neg = .9,  # Start at 0 for better mixing
      cor_subject__delta_pos__sigma_Intercept = -.1,  # Start at 0 for better mixing
      cor_subject__delta_neg__sigma_Intercept = -.1  # Start at 0 for better mixing
      
    )
  }
)

model1 = do.call(brm, modelarg)

saveRDS(model1, file = paste0("/rds/user/gb424/hpc-work/model1",Sys.time(),".Rds"))

#saveRDS(model1, file = file.path("saved_models",paste0("model1_d",Sys.time(),".Rds")))



