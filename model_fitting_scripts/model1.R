if (TRUE){
  
  modelarg =  c(
    list(
      formula =   bf(  sit_values_finalrating2 ~ 0 + sit_values_initialrating2 + delta_m4 + delta_m2 + delta_2 + delta_4 + (0 +  delta_m4 + delta_m2 + delta_2 + delta_4 | subject),
                       sigma ~ 0 + delta_m4 + delta_m2 + delta_2 + delta_4 + (1 | subject)
      ),
      seed = 1,
      prior =  c(
        prior(normal(0, 1), class = "b"),
        prior(cauchy(0, 1), class = "sd")
      )
    ),
    brm_args
  )
  
  model1 = do.call(brm, modelarg)
  
  saveRDS(model1, file = file.path("saved_models","model1.Rds"))
  
}


