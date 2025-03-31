n_pps = length(unique(df_long$subject))
#
init_function = function(chain_id) {
  list(
    b = c(
      1.0,
      0.36,
      0.46,
      0.44,
      0.41
    ),
    sigma = 1.06,
    L_1 = matrix(c(
      1.000000, 0.000000, 0.000000, 0.000000, 
      0.995000, 0.099875, 0.000000, 0.000000, 
      0.780000, 0.139174, 0.610107, 0.000000, 
      0.770000, 0.038548, 0.580284, 0.262460
    ), ncol = 4, byrow = TRUE),
    sd_1 = c(.3, .3, .3, .3),
    z_1 = matrix(rep(0, n_pps*4), ncol = n_pps, nrow = 4)
  )
}


modelarg =  c(
  list(
    formula =   bf(  sit_values_finalrating2 ~ 0 + sit_values_initialrating2 + delta_m4 + delta_m2 + delta_2 + delta_4  + (0 + delta_m4 + delta_m2 + delta_2 + delta_4 | subject)
    )
  ),
  # sample_prior = "only",
  brm_args,
  max_treedepth = 15,
  init = init_function
)

model = do.call(brm, modelarg)



