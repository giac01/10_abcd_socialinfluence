cmdstanr::set_cmdstan_path(path = "/home/gb424/.cmdstan/cmdstan-2.34.1")
# cmdstanr::set_cmdstan_path(path = "/home/rstudio/.cmdstan/cmdstan-2.35.0")

rm(list = ls(all.names = TRUE))

source("0_load_r_packages.R")

remove_participants_few_trials <- as.logical(Sys.getenv("REMOVE_PARTICIPANTS_FEW_TRIALS", unset = "TRUE"))
variational                    <- as.logical(Sys.getenv("VARIATIONAL", unset = "FALSE"))
small_sample_test              <- as.logical(Sys.getenv("SMALL_SAMPLE", unset = "FALSE"))
myseed                         <- as.numeric(Sys.getenv("MYSEED", unset = "1"))
warmup                         <- as.numeric(Sys.getenv("WARMUP", unset = "1000"))
iter                           <- as.numeric(Sys.getenv("ITER", unset = "2000"))
chains_run                     <- as.numeric(Sys.getenv("CHAINS", unset = "2"))
adapt_delta_val                <- as.numeric(Sys.getenv("ADAPTDELTA", unset = ".95"))


cat("remove_participants_few_trials\n")
print(remove_participants_few_trials)
cat("variational\n")
print(variational)
cat("small_sample_test\n")
print(small_sample_test)
cat("myseed\n")
print(myseed)

df_long      = data.table::fread(file.path("cleaned_data", "sit_df_long_cleaned1.csv"), data.table = FALSE)

df_long$sit_values_delta_factor = factor(df_long$sit_values_delta)
df_long$sit_values_scenario     = factor(df_long$sit_values_scenario)

df_long$initialrating_boundrycloseness = abs(df_long$sit_values_initialrating2 - 5)
df_long$initialrating_boundrysquared   = (df_long$sit_values_initialrating2 - 5)^2

df_long_odd  = data.table::fread(file.path("cleaned_data", "sit_df_long_cleaned1_odd.csv"), data.table = FALSE)
df_long_even = data.table::fread(file.path("cleaned_data", "sit_df_long_cleaned1_even.csv"), data.table = FALSE)

random_pps = sample(unique(df_long$subject), 1000, replace = FALSE)

# Remove participants with limited data ----------------------------------------

if (remove_participants_few_trials){
  df_long = df_long %>%
    filter(n_trials > 22) %>%
    mutate(trialcount_centered = scale(trialcount_centered, center = TRUE, scale = FALSE))
  
  df_long_odd = df_long_odd %>%
    filter(n_trials > 22) %>%
    mutate(trialcount_centered = scale(trialcount_centered, center = TRUE, scale = FALSE))
  
  
  df_long_even = df_long_even %>%
    filter(n_trials > 22) %>%
    mutate(trialcount_centered = scale(trialcount_centered, center = TRUE, scale = FALSE))
  
}

# Use Small Sample for testing -------------------------------------------------

if (small_sample_test){
  df_long = df_long %>%
    filter(subject %in% random_pps) %>%
    mutate(trialcount_centered = scale(trialcount_centered, center = TRUE, scale = FALSE))
  
  df_long_odd = df_long_odd %>%
    filter(subject %in% random_pps) %>%
    mutate(trialcount_centered = scale(trialcount_centered, center = TRUE, scale = FALSE))
  
  df_long_even = df_long_even %>%
    filter(subject %in% random_pps) %>%
    mutate(trialcount_centered = scale(trialcount_centered, center = TRUE, scale = FALSE))
  
}

# brms arguments ---------------------------------------------------------------

if (variational){
  brm_args = list(
    algorithm = "meanfield",
    iter = 1000000,
    tol_rel_obj = 0.0001,
    data = df_long,
    backend = "cmdstanr",
    threads = threading(8),
    seed    = myseed
  )
}

if (!variational){
  brm_args = list(
    data = df_long,
    chains = chains_run,
    cores = chains_run,
    # threads = threading(4),
    threads = floor(future::availableCores()/chains_run),
    control = list(adapt_delta = adapt_delta_val),
    backend = "cmdstanr",
    iter   = iter,
    warmup = warmup,
    seed   = myseed
  )
}


