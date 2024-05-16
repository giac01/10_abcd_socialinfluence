rm(list = ls(all.names = TRUE))
rm(list = ls(envir = .GlobalEnv), envir = .GlobalEnv)
# source("0_load_abcd.R")
source("0_load_r_packages.R")

# Load Social Influence Data ---------------------------------------------------

sit_files = list.files("/home/rstudio/Users/giaco/OneDrive/Work/blakemore_postdoc/Analyses/5_abcd_reward_lone/data/socialinfluence_extracted/",
                       full.names = TRUE, recursive = TRUE)

sit_df_list = lapply(sit_files, function(x) data.table::fread(x, colClasses = "character", data.table = FALSE))

all_colnames = lapply(sit_df_list, function(df) colnames(df)) %>% unlist() %>% unique()

all_colnames = colnames(sit_df_list[[1]])

table(sapply(sit_df_list,ncol)) # Some data.frames are 27 variables and others have 35

add_cols_if_missing = function(df, cols){
  missing_columns = all_colnames[!(all_colnames %in% colnames(df))]
  for(column_name in missing_columns){
    df[[column_name]] <- NA
  }
  df = df[all_colnames]
  return(df)
}

sit_df_list2 = lapply(sit_df_list, function(df) add_cols_if_missing(df, all_colnames))

for(i in seq_along(sit_df_list2)) {
  sit_df_list2[[i]]$filename = sit_files[i]
}

sit_df_long = do.call("bind_rows", sit_df_list2)

write.csv(sit_df_long,file.path("cleaned_data", "sit_df_long_uncleaned.csv"), row.names = FALSE) 

# Clean character variables ----------------------------------------------------

sit_df_long$sit_values_initialrating2 = gsub("px","", sit_df_long$sit_values_initialrating) %>% 
                                        gsub(",",".", .) %>%
                                        as.numeric()

sit_df_long$sit_values_peerrating2    = gsub("px","", sit_df_long$sit_values_peerrating) %>% 
                                        gsub(",",".", .) %>%
                                        as.numeric()

sit_df_long$sit_values_finalrating2   = gsub("px","", sit_df_long$sit_values_finalrating) %>% 
                                        gsub(",",".", .) %>%
                                        as.numeric()

sit_df_long$sit_values_delta          = (sit_df_long$sit_values_peerrating2 - sit_df_long$sit_values_initialrating2) %>%
                                        # as.numeric() %>%
                                        round(., digit = 4)

sit_df_long$subjectnum = match(sit_df_long$subject, unique(sit_df_long$subject))

sit_df_long$sit_values_rt_finalrating   = as.numeric(sit_df_long$sit_values_rt_finalrating)
sit_df_long$sit_values_rt_initialrating = as.numeric(sit_df_long$sit_values_rt_initialrating)

sit_df_long$sit_values_rt_finalrating[sit_df_long$sit_values_rt_finalrating>10000] = NA # For some reason we have two huge numbers here 
sit_df_long$sit_values_rt_initialrating[sit_df_long$sit_values_rt_initialrating>10000] = NA # For some reason we have two huge numbers here 

sit_df_long$delta_m4 = ifelse(sit_df_long$sit_values_delta ==-4, -4, 0)
sit_df_long$delta_m2 = ifelse(sit_df_long$sit_values_delta ==-2, -2, 0)
sit_df_long$delta_2  = ifelse(sit_df_long$sit_values_delta == 2,  2, 0)
sit_df_long$delta_4  = ifelse(sit_df_long$sit_values_delta == 4,  4, 0)


# Fix the date formatting - dates are formatted differently for build versions 5 and 6 of the task 

process_date_build_5 <- function(date) {
  # Ensure the date is numeric and zero-padded to six digits
  date_padded <- sprintf("%06d", as.numeric(date))
  as.Date(date_padded, format = "%m%d%y")
}

process_date_build_6 <- function(date) {
  as.Date(date, format = "%Y-%m-%d")
}

# process_date_build_5("12923")      # output:  "2023-01-29"
# process_date_build_6("2021-05-05") # output "2021-05-05"
# 
# process_date_build_5("12923asdasdf")
# process_date_build_5("129923")
# process_date_build_5(c("12923","12923"))

sit_df_long$build_number = str_extract(sit_df_long$build, "\\d+")

sit_df_long$cleandate = as.Date(NA)
sit_df_long$cleandate[which(sit_df_long$build_number==5)] = process_date_build_5(sit_df_long$date[which(sit_df_long$build_number==5)])
sit_df_long$cleandate[which(sit_df_long$build_number==6)] = process_date_build_6(sit_df_long$date[which(sit_df_long$build_number==6)])


# Filter out rows of data which are empty --------------------------------------
  
sit_df_long$valid_trial               = !is.na(sit_df_long$sit_values_initialrating2) & !is.na(sit_df_long$sit_values_finalrating2) & !is.na(sit_df_long$sit_values_peerrating2) 

sit_df_long2 = sit_df_long %>%
               filter(as.numeric(sit_values_condition)!=0) %>%   # This is the same as delta, but coded weirdly (1=-4, 2 = -2, 3 = 2, 4 = 4). There are no valid trials when this is equal to 0, i'm not sure why there are so many empty rows
               filter(valid_trial) 

# Add additional variables -----------------------------------------------------

sit_df_long2$sit_values_scenario = factor(sit_df_long2$sit_values_scenario)

sit_df_long2$subject = factor(sit_df_long2$subject)

# add number of trials completed by each participant 

n_trials_completed = table(sit_df_long2$subject)

sit_df_long2$n_trials = as.numeric(n_trials_completed[match(sit_df_long2$subject, names(n_trials_completed))])

sit_df_long2 = sit_df_long2 %>%
  group_by(subject) %>%
  arrange(subject,as.numeric(sit_values_trialcount)) %>%
  mutate(
    trialcount = row_number(),
    trialcount_centered = row_number() - mean(trialcount)
    ) 


# Remove Duplicated Rows of Data -----------------------------------------------
sit_df_long2$check_duplicates = paste0(sit_df_long2$subject, sit_df_long2$sit_values_scenario,sit_df_long2$sit_values_finalrating2, sep = ".")
sit_df_long2$check_duplicates = duplicated(sit_df_long2$check_duplicates)

sit_df_long2 = sit_df_long2 %>%
  filter(!check_duplicates)



write.csv(sit_df_long2,file.path("cleaned_data", "sit_df_long_cleaned1.csv"))

# Create odd and even datasets -------------------------------------------------

sit_df_long2_odd = sit_df_long2 %>%
  filter((as.numeric(trialcount) %% 2) != 0)

sit_df_long2_even = sit_df_long2 %>%
  filter((as.numeric(trialcount) %% 2) == 0)


write.csv(sit_df_long2_odd, file.path("cleaned_data", "sit_df_long_cleaned1_odd.csv"))
write.csv(sit_df_long2_even,file.path("cleaned_data", "sit_df_long_cleaned1_even.csv"))


