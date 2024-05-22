# Load Data --------------------------------------------------------------------
cmdstanr::set_cmdstan_path(path = "/home/gb424/.cmdstan/cmdstan-2.34.1")
rm(list = ls(all.names = TRUE))

library(brms)
library(cmdstanr)
library(tidyverse)

variational = FALSE
small_data  = FALSE

df_long      = data.table::fread(file.path("cleaned_data", "sit_df_long_cleaned1.csv"), data.table = FALSE)

df_long$sit_values_delta_factor = factor(df_long$sit_values_delta)
df_long$sit_values_scenario = factor(df_long$sit_values_scenario)

df_long$initialrating_boundrycloseness = abs(df_long$sit_values_initialrating2 - 5)
df_long$initialrating_boundrysquared =    (df_long$sit_values_initialrating2 - 5)^2

# plot(df_long$sit_values_initialrating2, df_long$initialrating_boundrycloseness)
# plot(df_long$sit_values_initialrating2, df_long$initialrating_boundrysquared)

# df_long_odd  = data.table::fread(file.path("cleaned_data", "sit_df_long_cleaned1_odd.csv"), data.table = FALSE)
# df_long_even = data.table::fread(file.path("cleaned_data", "sit_df_long_cleaned1_even.csv"), data.table = FALSE)

df_long = df_long %>%
  filter(n_trials > 22) 

if (small_data){
  set.seed(10)
  random_pps = sample(unique(df_long$subject), 200, replace = FALSE)
  df_long = df_long %>%
    filter(subject %in% random_pps)
}

# brms arguments ---------------------------------------------------------------

if (variational){
  brm_args = list(
    algorithm = "meanfield",
    iter = 1000000,
    tol_rel_obj = 0.0001,
    data = df_long,
    backend = "cmdstanr",
    threads = threading(8)
  )
}

if (!variational){
  threads_run = 4
  brm_args = list(
    data = df_long,
    chains = threads_run,
    cores = threads_run,
    # threads = threading(4),
    threads = future::availableCores()/threads_run,
    backend = "cmdstanr",
    iter = 3000
  )
}

# What factors predict residual variation --------------------------------------

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

  model5 = do.call(brm, modelarg)
  
  saveRDS(model5, file = file.path("saved_models","model5.Rds"))
  
}



