modelarg =  c(
    list(
      formula =   sit_values_finalrating2 ~ 1 + sit_values_initialrating2 + sit_values_delta*trialcount_centered,
      prior =  c(
        prior(normal(0, 1), class = "b")
        #prior(cauchy(0, 1), class = "sd")
      )
    ),
    brm_args
 )
  
model2 = do.call(brm, modelarg)
  
saveRDS(model2, file = paste0("/rds/user/gb424/hpc-work/model2",Sys.time(),".Rds"))
