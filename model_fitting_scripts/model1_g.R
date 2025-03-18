n_pps = length(unique(df_long$subject))

init_function = function(chain_id) {
  list(
    b = c(
      1.0,  
      0.44,  
      0.33
    ), 
    Intercept = 0,
    Intercept_sigma = -.2,
    # sd_subject__delta_pos = 0.3,  
    # sd_subject__delta_neg = 0.3,  
    # sd_sigma__Intercept = .64,
    # cor_subject__delta_pos__delta_neg = .83,  
    # cor_subject__delta_pos__sigma_Intercept = -.1,  
    # cor_subject__delta_neg__sigma_Intercept = -.2,
    # L_1 = c(1, 0.8, -0.1, 0, 0.6, -0.2, 0, 0, 1)
    L_1 = matrix(c(1, 0.8, -0.1, 0, 0.6, -0.2, 0, 0, 1),ncol=3),
    sd_1 = c(.3, .3, .64),
    z_1 = matrix(rep(0, n_pps*3), ncol = n_pps, nrow = 3)
  )
}


modelarg =  c(
  list(
    formula =   bf(  sit_values_finalrating2 ~ 1 + sit_values_initialrating2 + delta_pos + delta_neg + (0 +  delta_pos + delta_neg |ID1| subject),
                     sigma ~ 1 + (1 |ID1| subject)
    )
  ),
  # sample_prior = "only",
  brm_args,
  max_treedepth = 15,
  init = init_function
)

model = do.call(brm, modelarg)



