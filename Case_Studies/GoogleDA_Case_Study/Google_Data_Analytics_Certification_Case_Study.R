library(tidyverse)
library(data.table)

# Variable to keep track of total rows of data
total_rows <- 0

for(i in 1:12){
  if(i==1){
    file_name <- "202301-divvy-tripdata.csv"
    trip_data <- fread(file_name)
    total_rows <- total_rows + nrow(trip_data)
  }
  else if(i<10){
    file_name <- paste("20220",i,"-divvy-tripdata.csv", sep="")
    temp_df <- fread(file_name)
    total_rows <- total_rows + nrow(temp_df)
    trip_data <- rbind(trip_data, temp_df)
  }
  else{
    file_name <- paste("2022",i,"-divvy-tripdata.csv", sep="")
    temp_df <- fread(file_name)
    total_rows <- total_rows + nrow(temp_df)
    trip_data <- rbind(trip_data, temp_df)
  }
}

# Check if all rows were imported
if(total_rows==nrow(trip_data)){
  print("Number of rows match")
} else{
  print("Number of rows do not match.")
}

# Replace blank strings with NA values, then drop rows with NA
trip_data <- trip_data[!duplicated(trip_data)] %>% 
  mutate(across(where(is.character), ~ na_if(.,""))) %>% 
  drop_na()

# Find duration of each trip, and drop trips with trip duration of 0 or lower
trip_data$trip_length <- with(trip_data, as.numeric(difftime(ended_at, started_at, units='mins')))
trip_data <- trip_data[trip_data$trip_length > 0, ]

# Separate month into its own column, then find associate season for the month
trip_data$month <- as.numeric(format(as.Date(trip_data$started_at, format="%d/%m/%Y"),"%m"))

trip_data <- trip_data %>%
  mutate(
    season = case_when(
      month %in%  9:11 ~ "Fall",
      month %in%  c(12, 1, 2)  ~ "Winter",
      month %in%  3:5  ~ "Spring",
      month %in%  6:8 ~ "Summer"))

# Separate hour of the day into its own column
trip_data$hour <- (format(as.POSIXct(trip_data$started_at), format = "%H"))

# Find the day of the week that the trip was taken
trip_data$day_of_week <- lubridate::wday(trip_data$started_at, label=TRUE, abbr=TRUE)

library(scales)

# Plot membership type
member_type_plot <- ggplot(trip_data, aes(x = "", fill = factor(member_casual))) +
  geom_bar(stat= "count") +
  geom_text(aes(label = scales::percent(..count.. / sum(..count..))), 
            stat = "count", position = position_stack(vjust = .5)) +
  coord_polar("y", start = 0, direction = -1)+
  theme_void()+
  labs(title="Breakdown by Member Type")+
  scale_fill_discrete(name = "Member Type")

# Plot days of the week vs count of trips, by membership type
day_plot <-ggplot(data=trip_data, aes(x=day_of_week, fill = member_casual)) + 
            geom_bar(position="dodge") + 
            scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
            xlab("Day of Week") +
            scale_fill_discrete(name = "Member Type") + 
            labs(title="Total Rides by Day of Week")

# Mean duration of trip
trip_data %>% group_by(member_casual) %>% 
  summarise(mean_duration=mean(trip_length),
            .groups = 'drop')

# Plot seasons vs count of trips, by membership type
seasons_plot <-ggplot(data=trip_data, aes(x=factor(season, level=c('Spring', 'Summer', 'Fall', 'Winter')), fill = member_casual)) + 
  geom_bar(position="dodge") + 
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  xlab("Season") +
  scale_fill_discrete(name = "Member Type") +
  labs(title="Total Rides by Season")

trip_data %>% group_by(member_casual) %>% 
  count(season)

# Plot of preferred types of bike
bike_type_count <- trip_data %>% 
  group_by(member_casual) %>% 
  count(rideable_type)

bike_type_plot <- ggplot(data=bike_type_count, aes(x=" ", y=n, group=rideable_type, fill=rideable_type)) +
  geom_bar(width = 1, stat = "identity", position="fill") +
  coord_polar("y", start=0)+
  facet_grid(~ member_casual)+
  theme_void()+
  labs(title="Share of Bike Type")+
  scale_fill_discrete(name = "Bike Type")

# We want to find the average number of rides by weekdays vs weekends, casual vs members
trip_data <- trip_data %>%
  mutate(
    day_type = ifelse((trip_data$day_of_week == 'Sat' | trip_data$day_of_week == 'Sun'),
                      'weekend', 'weekday'))

trip_data %>% 
  filter(day_type=='weekday') %>% 
  group_by(member_casual, hour, day_type) %>% 
  summarise(trips=n()/5) %>% 
  ggplot() + 
  geom_line(aes(x=hour, y=trips, group=member_casual, color=member_casual),
            linewidth=1) + 
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  xlab("Hour of Day") +
  scale_color_discrete(name = "Member Type") +
  labs(title="Total Rides By Hour (Average Weekday)")

trip_data %>% 
  filter(day_type=='weekend') %>% 
  group_by(member_casual, hour, day_type) %>% 
  summarise(trips=n()/2) %>% 
  ggplot() + 
  geom_line(aes(x=hour, y=trips, group=member_casual, color=member_casual),
            linewidth=1) + 
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  xlab("Hour of Day") +
  scale_color_discrete(name = "Member Type") +
  labs(title="Total Rides By Hour (Average Weekend)")

# Plot average length of trip by day, by member type
trip_data %>% 
  group_by(day_of_week, member_casual) %>% 
  summarise(mean_duration=mean(trip_length)) %>% 
  ggplot() +
  geom_col(aes(x=day_of_week, y=mean_duration, fill=member_casual), position="dodge")+
  scale_fill_discrete(name="Member Type")+
  xlab("Day of Week")+
  ylab("Mean Trip Duration")+
  labs(title="Mean Trip Duration by Day of the Week")

trip_data %>% 
  group_by(season, member_casual) %>% 
  summarise(mean_duration=mean(trip_length)) %>% 
  ggplot() +
  geom_col(aes(x=factor(season, level=c('Spring', 'Summer', 'Fall', 'Winter')), y=mean_duration, fill=member_casual), position="dodge")+
  scale_fill_discrete(name="Member Type")+
  xlab("Season")+
  ylab("Mean Trip Duration")+
  labs(title="Mean Trip Duration by Season")

