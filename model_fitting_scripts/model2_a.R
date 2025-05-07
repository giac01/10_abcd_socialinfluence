# Adding random intercepts seems to through some issues with convergence (rhat) unless adapt_delta is increased. 

modelarg =  c(
    list(
      formula =   sit_values_finalrating2 ~ 1 + sit_values_initialrating2 + sit_values_delta * trialcount_centered + (0 + sit_values_delta * trialcount_centered || subject) + (1 + sit_values_delta || sit_values_scenario)),
      # prior =  c(
      #   prior(normal(0, 1), class = "b"),
      #   prior(cauchy(0, 1), class = "sd")
      # )
    # ),
    brm_args
 )
  
model = do.call(brm, modelarg)
  
# saveRDS(model2, file = paste0("/rds/user/gb424/hpc-work/model2",Sys.time(),".Rds"))
