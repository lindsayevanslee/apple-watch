## setup -----------------
library(tidyverse)


## load ------------------

#load health data
df_all <- read_csv("data/apple_health_export/export.csv", 
                   col_names = c("startDate", "endDate", "type", "unit", "value"),
                   col_types = cols(startDate = col_datetime(format = "%Y-%m-%d %H:%M:%S %z"),
                                    endDate = col_datetime(format = "%Y-%m-%d %H:%M:%S %z"),
                                    .default = col_character())
)

#check for parsing errors
probs <- problems(df_all)
probs

## wrangle ---------------

#look at different types of health data available
df_all %>% 
  distinct(type)

#filter to oxygen saturation data
df_spo2 <- df_all %>% 
  filter(type == "HKQuantityTypeIdentifierOxygenSaturation") %>% 
  mutate(value = as.numeric(value))

#filter to sleep analysis data
df_sleep <- df_all %>% 
  filter(type == "HKCategoryTypeIdentifierSleepAnalysis") 

#see sleep analysis possible values
df_sleep %>% 
  distinct(value)

#filter to data when in bed or asleep
df_asleep <- df_sleep %>% 
  filter(value != "HKCategoryValueSleepAnalysisAwake")

#create table with one row per second asleep
df_asleep_times <- map2_dfr(.x = df_asleep$startDate, .y = df_asleep$endDate,
                 .f = function(start, end) {
                   tibble(asleep_times = seq(start, end, by = 1))
                 }) %>% 
  distinct() %>% 
  mutate(is_asleep = "Y")


#tag SpO2 with whether or not I was asleep
df_spo2_sleep <- df_spo2 %>% 
  left_join(df_asleep_times, 
            by = join_by(endDate == asleep_times)) %>% 
  mutate(is_asleep = case_when(
    is.na(is_asleep) ~ "N",
    TRUE ~ is_asleep
    ))



## print -----------------


#print point graph
df_spo2_sleep %>% 
  filter(endDate > "2023-01-01") %>% 
  mutate(period = case_when(
    endDate < "2023-04-01" ~ "2023-01 to 2023-03",
    TRUE ~ "2023-04 to now"
  )) %>% 
  ggplot(aes(x = endDate, y = value)) +
  geom_point(aes(color = is_asleep), alpha = 0.5) +
  scale_y_continuous(labels = scales::percent_format())+
  labs(x = "Date",
       y = "SpO2")

#print boxplot
pdf("output/boxplot.pdf", width = 10, height = 7)
df_spo2_sleep %>% 
  filter(endDate > "2023-01-01") %>% 
  mutate(period = case_when(
    endDate < "2023-04-01" ~ "2023-01 to 2023-03",
    TRUE ~ "2023-04 to now"
  )) %>% 
  ggplot(aes(x = period, y = value, color = is_asleep)) +
  geom_boxplot() +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(x = "Date",
       y = "SpO2",
       color = "Asleep")
dev.off()
