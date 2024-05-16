# Load Data --------------------------------------------------------------------

rm(list = ls(all.names = TRUE))

library(brms)
library(cmdstanr)
library(tidyverse)

df_long      = data.table::fread(file.path("cleaned_data", "sit_df_long_cleaned1.csv"), data.table = FALSE)

df_long$sit_values_delta_factor = factor(df_long$sit_values_delta)
df_long$sit_values_scenario = factor(df_long$sit_values_scenario)

df_long_odd  = data.table::fread(file.path("cleaned_data", "sit_df_long_cleaned1_odd.csv"), data.table = FALSE)
df_long_even = data.table::fread(file.path("cleaned_data", "sit_df_long_cleaned1_even.csv"), data.table = FALSE)


random_pps = sample(unique(df_long$subject), 200, replace = FALSE)

df_long_subset = df_long %>%
  filter(subject %in% random_pps)

# Quick LM models --------------------------------------------------------------

# This only works with brms 2.17.0 currently!
lm(sit_values_finalrating2 ~ 1 + sit_values_initialrating2 + (sit_values_delta),
   data = df_long) %>%
  summary()

lm(sit_values_finalrating2 ~ 0 + sit_values_initialrating2 + delta_m4 + delta_m2 + delta_2 + delta_4,
   data = df_long) %>%
  summary()

# Linear Delta Models ----------------------------------------------------------

model1   = brm( 
  sit_values_finalrating2 ~ 1 + sit_values_initialrating2 + (sit_values_delta) + (1 + sit_values_delta || subject),
  algorithm = "meanfield",
  iter = 40000,
  chains = 2, 
  cores = 2,
  backend = "cmdstanr", 
  threads = threading(4),
  tol_rel_obj = 0.0001,
  draws = 2000,
  data = df_long,
  seed = 1
)

saveRDS(model1, file = file.path("saved_models","model1.Rds"))

model2   = brm( 
  sit_values_finalrating2 ~ 1 + sit_values_initialrating2 + (sit_values_delta) + (1 + sit_values_delta || subject),
  family = student(),
  algorithm = "meanfield",
  iter = 40000,
  chains = 2, 
  cores = 2,
  backend = "cmdstanr", 
  threads = threading(4),
  tol_rel_obj = 0.0001,
  draws = 2000,
  data = df_long,
  seed = 1
)
saveRDS(model2, file = file.path("saved_models","model2.Rds"))

model3   = brm( 
  sit_values_finalrating2 ~ 1 + sit_values_initialrating2 + (sit_values_delta) + (1 + sit_values_delta | subject),
  algorithm = "meanfield",
  iter = 40000,
  chains = 2, 
  cores = 2,
  backend = "cmdstanr", 
  threads = threading(4),
  tol_rel_obj = 0.0001,
  draws = 2000,
  data = df_long, 
  seed = 1
)
saveRDS(model3, file = file.path("saved_models","model3.Rds"))

model4   = brm( 
  sit_values_finalrating2 ~ 1 + sit_values_initialrating2 + (sit_values_delta) + (1 + sit_values_delta | subject),
  family = student(),
  algorithm = "meanfield",
  iter = 40000,
  chains = 2, 
  cores = 2,
  backend = "cmdstanr", 
  threads = threading(4),
  tol_rel_obj = 0.0001,
  draws = 2000,
  data = df_long,
  seed = 1
)

saveRDS(model4, file = file.path("saved_models","model4.Rds"))

## Experimental Models ----------------------------------------------------------

model3b   = brm( 
  sit_values_finalrating2 ~ 1 + sit_values_initialrating2 + sit_values_delta + sit_values_delta*trialcount_centered + (0 + sit_values_delta | subject),
  algorithm = "meanfield",
  iter = 40000,
  chains = 2, 
  cores = 2,
  backend = "cmdstanr", 
  threads = threading(4),
  tol_rel_obj = 0.0001,
  draws = 2000,
  data = df_long, 
  seed = 1
)
saveRDS(model3b, file = file.path("saved_models","model3b.Rds"))


model3c   = brm( 
  bf(  sit_values_finalrating2 ~ 1 + sit_values_initialrating2 + sit_values_delta + sit_values_delta*trialcount_centered + (0 + sit_values_delta | subject),
       sigma ~ 1  + ( 1 | subject) + ( 1 | sit_values_scenario) 
       ),
  # algorithm = "meanfield",
  # iter = 10000000,
  # tol_rel_obj = 0.001,
  # draws = 2000,

  chains = 2, 
  cores = 2,
  backend = "cmdstanr", 
  threads = threading(4),
  data = df_long_subset, 
  seed = 2
)

saveRDS(model3b, file = file.path("saved_models","model3b.Rds"))



## Run Models on Split Half Data ------------------------------------------------

model3_odd   = brm( 
  sit_values_finalrating2 ~ 1 + sit_values_initialrating2 + (sit_values_delta) + (1 + sit_values_delta | subject),
  algorithm = "meanfield",
  iter = 40000,
  chains = 2, 
  cores = 2,
  backend = "cmdstanr", 
  threads = threading(4),
  tol_rel_obj = 0.0001,
  draws = 2000,
  data = df_long_odd,
  seed = 1
)

model3_even   = brm( 
  sit_values_finalrating2 ~ 1 + sit_values_initialrating2 + (sit_values_delta) + (1 + sit_values_delta | subject),
  algorithm = "meanfield",
  iter = 40000,
  chains = 2, 
  cores = 2,
  backend = "cmdstanr", 
  threads = threading(4),
  tol_rel_obj = 0.0001,
  draws = 2000,
  data = df_long_even, 
  seed = 1
)

saveRDS(model3_odd,  file = file.path("saved_models","model3_odd.Rds"))
saveRDS(model3_even, file = file.path("saved_models","model3_even.Rds"))

# Dummy Coded Delta Models -----------------------------------------------------

model_dummy1   = brm( 
  bf(  
    sit_values_finalrating2 ~ 0 + sit_values_initialrating2 + delta_m4 + delta_m2 + delta_2 + delta_4 + 
      (0 + delta_m4 + delta_m2 + delta_2 + delta_4 | subject),
    sigma ~ 1  + ( 1 | subject) 
  ),
  # algorithm = "meanfield",
  # iter = 10000000,
  # tol_rel_obj = 0.001,
  # # draws = 2000,
  # data = df_long,
  
  chains = 2,
  cores = 2,
  backend = "cmdstanr",
  threads = threading(4),
  data = df_long,

  seed = 20
)

saveRDS(model_dummy1, file = file.path("saved_models","model_dummy1.Rds"))


# 
# model1_vi = brm( 
#   sit_values_finalrating2 ~ 0 + sit_values_initialrating2 + delta_m4 + delta_m2 + delta_2 + delta_4 + (0 + delta_m4 + delta_m2 + delta_2 + delta_4 | subject),
#   algorithm = "meanfield",
#   iter = 40000,
#   # chains = 2, 
#   # cores = 2,
#   backend = "cmdstanr", 
#   # threads = threading(4),
#   tol_rel_obj = 0.001,
#   data = df_long
# )
# 
# model3 = brm( 
#   sit_values_finalrating2 ~ 0 + sit_values_initialrating2 + delta_m4 + delta_m2 + delta_2 + delta_4 + (0 + delta_m4 + delta_m2 + delta_2 + delta_4 | subject),
#   algorithm = "meanfield",
#   iter = 40000,
#   # chains = 2, 
#   # cores = 2,
#   backend = "cmdstanr", 
#   # threads = threading(4),
#   tol_rel_obj = 0.001,
#   data = df_long
# )


# Takes 1.52seconds

summary(model1)
summary(model1_vi)
summary(model1_vi)

# Plot Model Draws -------------------------------------------------------------
library(tidybayes)
draws_wide = model3 %>%
  as.data.frame() %>% 
  select(ends_with("sit_values_delta]")) %>%
  as.matrix()
  # t() %>%
  # data.frame()

colnames(draws_wide) =  gsub("r_subject\\[(.*),sit_values_delta\\]", "\\1", colnames(draws_wide))

# rownames(draws_wide) =  gsub("r_subject\\[(.*),Intercept\\]", "\\1", rownames(draws_wide))

draws_delta_beta = model3 %>%
  as.data.frame() %>% 
  pull(b_sit_values_delta)

draws_wide = draws_wide + (draws_delta_beta)

draws_wide = t(draws_wide) %>% as.data.frame()

# draws_wide = t(as.matrix(draws_wide)) + (as.vector(draws_delta_beta))

prob_conforming   = apply(draws_wide, 1, function(x) length(which(x>0))/length(x)) %>% as.numeric()
conforming_pps    = as.numeric(prob_conforming>.90)
nonconforming_pps = as.numeric(prob_conforming<.10)
unclearconforming_pps = as.numeric(prob_conforming>=.10 & prob_conforming <= .90)

conforming_category = dplyr::case_when(
  prob_conforming < 0.10 ~ "nonconforming",
  prob_conforming >= 0.10 & prob_conforming <= 0.90 ~ "unclear",
  prob_conforming > 0.90 ~ "conforming",
  .default = "other?!"
)

conformity_df = data.frame(
  subject  = rownames(draws_wide),
  meanbeta = apply(draws_wide, 1, mean),
  conforming_category = conforming_category                      
                           )

avg_rt = df_long %>%
  group_by(subject) %>%
  summarise(mean_rt = mean(sit_values_rt_initialrating + sit_values_rt_finalrating)/1000)

draws_wide %>% 
  mutate(id = 1:nrow(.)) %>%
  pivot_longer(cols = !contains("id")) %>%
  mutate(conforming_category = conforming_category[.$id]) %>%
  filter(id<1000) %>%
  ggplot(aes(x = value, group = id, col = conforming_category)) +
  geom_density()

df_long %>%
  mutate(conforming_category = conforming_category[match(.$subject, rownames(draws_wide))]) %>%
  mutate()

dplyr::full_join(avg_rt, conformity_df, by = "subject") %>%
  ggplot(aes(x = meanbeta, y = mean_rt)) + 
  geom_point(aes( col = conforming_category), alpha = .3) + 
  geom_smooth() + 
  theme_bw() 

df_long %>% 
  mutate(change_score = sit_values_finalrating2 - sit_values_initialrating2) %>%
  mutate(conforming_category = conforming_category[match(.$subject, rownames(draws_wide))]) %>%
  ggplot(aes(y = change_score, x = sit_values_delta)) +
  geom_jitter(width = .5, alpha = .2) + 
  facet_wrap(~conforming_category)

df_long %>% 
  mutate(change_score = sit_values_finalrating2 - sit_values_initialrating2) %>%
  mutate(conforming_category = conforming_category[match(.$subject, rownames(draws_wide))]) %>%
  group_by(conforming_category, sit_values_delta) %>%
  summarise(
    mean_change_score = mean(change_score)
  )
  

# Bignardi's Reliability Coefficient -------------------------------------------

calc_r_brms = function(
    input_model
){
  # browser()
  # tidybayes::get_variables(input_model)
  
  draws_wide = input_model %>%
    as.data.frame() %>%
    select(ends_with("sit_values_delta]")) %>%
    t() %>%
    data.frame()
  
  col_select = sample(1:ncol(draws_wide), replace = F)
  draws_wide_1 = draws_wide[col_select[1:(length(col_select)/2)]]  
  draws_wide_2 = draws_wide[col_select[(length(col_select)/2+1):length(col_select)]] 
  
  cors = sapply(1:length(draws_wide_1), function(i) cor(draws_wide_1[,i],draws_wide_2[,i]))
  
  cors_hcdi = ggdist::mean_hdci(cors)
  
  return(cors_hcdi)
}

undebug(calc_r_brms)
calc_r_brms(model3)

model1 %>% tidybayes::get_variables()

model_draws = as.data.frame(model1) %>%
  select(ends_with("Intercept]"))

colnames(model_draws)
# ------------------------------------------------------------------------------


