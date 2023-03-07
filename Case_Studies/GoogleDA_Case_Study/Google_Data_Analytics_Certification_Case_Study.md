Google Data Analytics Certification Case Study
================
Admon Lee
2023-03-02

# Cyclistic Bike Share Case Study

### Introduction

This case study is the capstone project for the Google Data Analytics
Certification. In this scenario, a fictional bike-sharing company
Cyclistic is looking for ways to maximize their annual member count over
casual users, as the former category is much more profitable for their
business. We will be analyzing historical data on Cyclistic to identify
solutions to their business problem.

### Business Task

The main question that we will seek to answer with this analysis is:
“How do annual members and casual riders use Cyclistic bikes
differently?” The analysis will give insights on the motivations for
Cyclistic bike users for preferring to be an annual member or a casual
user. The stakeholders can then tailor the annual membership product to
appeal to a wider range of users to expand their customer base.

### Data

The data used in this analysis was provided by Divvy, a real world bike
sharing company, who hosts historical ridership data on their
[site](https://divvybikes.com/system-data). This data was collected by
the company themselves, and have been anonymized for privacy concerns.
It is available for public use based on this [license
agreement](https://ride.divvybikes.com/data-license-agreement). The last
twelve months of available data (2022-02 to 2023-01) was used for the
analysis. The data was organized into .csv files by month. Data that was
included in these data sets are ride IDs, bike type, start and end times
of rides, start and end station names, station IDs, station coordinates,
and member type. Based on a preliminary scan of the data in Excel, there
are blank values in the columns containing station information. The
column names for each of the monthly tables were consistent.

### Data Cleaning and Processing

Since the .csv files have over a hundred thousand rows each, R was
selected as the tool for analysis over Excel. The data was imported into
R then bound together into a single data frame.

``` r
library(tidyverse)
library(data.table)
library(lubridate)
library(scales)

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
```

    ## [1] "Number of rows match"

Once the data was imported into a data frame, the structure of the data
was checked to ensure that the columns were imported as the correct data
type.

``` r
str(trip_data)
```

    ## Classes 'data.table' and 'data.frame':   5754248 obs. of  13 variables:
    ##  $ ride_id           : chr  "F96D5A74A3E41399" "13CB7EB698CEDB88" "BD88A2E670661CE5" "C90792D034FED968" ...
    ##  $ rideable_type     : chr  "electric_bike" "classic_bike" "electric_bike" "classic_bike" ...
    ##  $ started_at        : POSIXct, format: "2023-01-21 20:05:42" "2023-01-10 15:37:36" ...
    ##  $ ended_at          : POSIXct, format: "2023-01-21 20:16:33" "2023-01-10 15:46:05" ...
    ##  $ start_station_name: chr  "Lincoln Ave & Fullerton Ave" "Kimbark Ave & 53rd St" "Western Ave & Lunt Ave" "Kimbark Ave & 53rd St" ...
    ##  $ start_station_id  : chr  "TA1309000058" "TA1309000037" "RP-005" "TA1309000037" ...
    ##  $ end_station_name  : chr  "Hampden Ct & Diversey Ave" "Greenwood Ave & 47th St" "Valli Produce - Evanston Plaza" "Greenwood Ave & 47th St" ...
    ##  $ end_station_id    : chr  "202480.0" "TA1308000002" "599" "TA1308000002" ...
    ##  $ start_lat         : num  41.9 41.8 42 41.8 41.8 ...
    ##  $ start_lng         : num  -87.6 -87.6 -87.7 -87.6 -87.6 ...
    ##  $ end_lat           : num  41.9 41.8 42 41.8 41.8 ...
    ##  $ end_lng           : num  -87.6 -87.6 -87.7 -87.6 -87.6 ...
    ##  $ member_casual     : chr  "member" "member" "casual" "member" ...
    ##  - attr(*, ".internal.selfref")=<externalptr>

Since blank values were observed for the columns containing station
data, we convert the blank values into NA values and drop the rows
containing NA values.

``` r
trip_data <- trip_data[!duplicated(trip_data)] %>% 
  mutate(across(where(is.character), ~ na_if(.,""))) %>% 
  drop_na()
```

To prepare for our data analysis, a few transformations needed to be
performed on the data. To make working with the trip times easier, we
created a new calculated column to determine the duration of each trip
by subtracting the end time from the start time of the trip. Trips with
a 0 or negative were removed from the dataset.

``` r
trip_data$trip_length <- with(trip_data, as.numeric(difftime(ended_at, started_at, units='mins')))

trip_data <- trip_data[trip_data$trip_length > 0, ]
```

After cleaning, the dataset had a total of 4.4 million rows.

To make working with dates easier, we also separated the date value into
months and days. The month was first extracted from the starting date of
the trip, then assigned to a season value, with Spring being March to
May, Summer being June to August, Fall being September to November, and
Winter being December to February.

``` r
trip_data$month <- as.numeric(format(as.Date(trip_data$started_at, format="%d/%m/%Y"),"%m"))

trip_data <- trip_data %>%
  mutate(
    season = case_when(
      month %in%  9:11 ~ "Fall",
      month %in%  c(12, 1, 2)  ~ "Winter",
      month %in%  3:5  ~ "Spring",
      month %in%  6:8 ~ "Summer"))
```

For the day value, the day of the week was identified from the starting
date of the trip using the lubridate package.

``` r
trip_data$day_of_week <- lubridate::wday(trip_data$started_at, label=TRUE, abbr=TRUE)
```

Similar processing was done to obtain the hour of the day that a trip
was taken on.

``` r
trip_data$hour <- (format(as.POSIXct(trip_data$started_at), format = "%H"))
```

Another value that could be of use was whether the day a trip was taken
was a weekday or weekend, so a column was added to the dataset
indicating as such.

``` r
trip_data <- trip_data %>%
  mutate(
    day_type = ifelse((trip_data$day_of_week == 'Sat' | trip_data$day_of_week == 'Sun'),
                      'weekend', 'weekday'))
```

### Analysis

#### Share of Member Type

Within the timeframe that was analyzed, about 60% of all trips were
taken by annual members, with the other 40% of trips taken by casual
users.

``` r
ggplot(trip_data, aes(x = "", fill = factor(member_casual))) +
  geom_bar(stat= "count") +
  geom_text(aes(label = scales::percent(..count.. / sum(..count..))), 
            stat = "count", position = position_stack(vjust = .5)) +
  coord_polar("y", start = 0, direction = -1)+
  theme_void()+
  labs(title="Breakdown by Member Type")+
  scale_fill_discrete(name = "Member Type")
```

    ## Warning: The dot-dot notation (`..count..`) was deprecated in ggplot2 3.4.0.
    ## ℹ Please use `after_stat(count)` instead.

![](Google_DA_Cert_Case_Study_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

#### A look into number of trips taken throughout the week

The first relationship that was studied was how ridership by the two
groups varied on different days of the week.

``` r
ggplot(data=trip_data, aes(x=day_of_week, fill = member_casual)) + 
  geom_bar(position="dodge") + 
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  xlab("Day of Week") +
  scale_fill_discrete(name = "Member Type") + 
  labs(title="Total Rides by Day of Week")
```

![](Google_DA_Cert_Case_Study_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

An inverse relationship can be observed between the two user groups in
the plot of trips taken by day of the week. We see that more trips were
taken by casual users than members on weekends. Conversely, members take
a significantly higher number of trips on weekdays. One possible
explanation for this trend is that annual members are more likely to use
the bike-sharing service as part of their daily commute to work or
class.

To further investigate this implication, we will break down the trips
into hourly segments to visualize the ridership trend throughout the
day. The total number of rides for every hour were averaged, grouping by
day types (weekends and weekdays), then plotted for each member type.

``` r
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
```

![](Google_DA_Cert_Case_Study_files/figure-gfm/unnamed-chunk-11-1.png)<!-- -->

The number of trips on weekends peaks in the afternoon for both casual
users and annual members. The number of trips for casual users does
reach a higher peak than annual members, and they both reach a minimum
at around 4 to 5 am.

The weekday plot on the other hand, shows a very different kind of
trend.

``` r
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
```

![](Google_DA_Cert_Case_Study_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->

A very striking detail of this plot is that the peaks are much sharper
here compared to the weekend plot. For annual members, the plot appears
to be bimodal, with sharp peaks occurring at 8 am and 5 pm,
corresponding to the common times for commuting to and from work. For
casual members, ridership also peaks at 5pm, though at a much smaller
magnitude compared to annual member. These plots seem to support the
conjecture that annual members tend to use the service for commuting,
while casual riders are more likely to use the service during leisure
time.

#### A look into trip durations throughout the week

Using the data on trip start and end times, the duration of each trip
could be calculated and analyzed. Here we look at the average duration
of trips taken on the bikes, grouped by day of the week.

``` r
trip_data %>% 
  group_by(day_of_week, member_casual) %>% 
  summarise(mean_duration=mean(trip_length)) %>% 
  ggplot() +
  geom_col(aes(x=day_of_week, y=mean_duration, fill=member_casual), position="dodge")+
  scale_fill_discrete(name="Member Type")+
  xlab("Day of Week")+
  ylab("Mean Trip Duration")+
  labs(title="Mean Trip Duration by Day of the Week")
```

![](Google_DA_Cert_Case_Study_files/figure-gfm/unnamed-chunk-13-1.png)<!-- -->

We can see that for causal riders the trend of mean trip duration
throughout the week is similar to the trend of number of trips taken
throughout the week: casual members tend to take longer trips on
weekends. However, annual members do not take longer rides on weekdays,
even though they tend to take more rides on weekdays. Instead, they show
a similar trend to casual members, peaking in trip duration on weekends,
though with a much smaller increase from weekdays. This trend seems to
suggest that even though the two member types are likely to be primarily
using the bikes for different purposes, both groups tend to take their
longest rides in leisure time.

#### A look into seasonal trends

Another aspect that was analyzed was the trends in ridership based on
seasons. For this analysis, the months are assigned as follows: Spring
(March-May), Summer (June-August), Fall (September-November), and Winter
(December-February). First, we plot the total rides for every season.

``` r
ggplot(data=trip_data, aes(x=factor(season, level=c('Spring', 'Summer', 'Fall', 'Winter')), fill = member_casual)) + 
  geom_bar(position="dodge") + 
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  xlab("Season") +
  scale_fill_discrete(name = "Member Type") +
  labs(title="Total Rides by Season")
```

![](Google_DA_Cert_Case_Study_files/figure-gfm/unnamed-chunk-14-1.png)<!-- -->

We can observe that ridership trends similarly for both member groups,
peaking in the summer and reaching a minimum in the winter. One
difference between the two groups however, is that summer to winter
represents a \~70% drop in rides for annual members, while rides by
casual users drops by a much larger \~90% between summer and winter.
This may be due to a larger portion of annual members than casual users
who are commuters, and so are unlikely to switch modes of transportation
due to weather conditions.To further investigate this speculation, we
will observe the mean trip duration by seasons.

``` r
trip_data %>% 
  group_by(season, member_casual) %>% 
  summarise(mean_duration=mean(trip_length)) %>% 
  ggplot() +
  geom_col(aes(x=factor(season, level=c('Spring', 'Summer', 'Fall', 'Winter')), y=mean_duration, fill=member_casual), position="dodge")+
  scale_fill_discrete(name="Member Type")+
  xlab("Season")+
  ylab("Mean Trip Duration")+
  labs(title="Mean Trip Duration by Season")
```

![](Google_DA_Cert_Case_Study_files/figure-gfm/unnamed-chunk-15-1.png)<!-- -->

This plot shows quite a different trend compared to the trend of total
number of trips. Casual members tend to take the longest rides in the
spring, while taking shorter trips the rest of the year, and reaching a
minimum in winter. Trip duration for annual members does not fluctuate
much compared to casual users. Similar to what we have seen with the
mean trip duration throughout the week, casual members take much longer
trips than annual members. There seems to be a relationship between this
fact and the trend of total trips by season: since casual users tend to
take long trips, they would be affected by cold weather more so than
annual members who take much shorter rides.

### Key Takeaways and Suggestions

#### Key Takeaways

- Casual users on average take much longer trips than annual members.
- Casual ridership plunges on weekdays, while annual members ride more
  frequently on weekdays.
- These two findings suggest that users who commute with the bikes are
  more likely to be annual members.
- Casual ridership peaks in spring and decreases with each season, while
  member ridership is relatively stable throughout the year.

#### Suggestions

Based on the findings and observations, casual users are more likely to
be using the bike service for leisure. Therefore, any changes to the
business model that aims to increase conversion rate of casual members
should be focused on making membership more appealing to leisurely
bikers. Additionally, since casual users tend to take longer rides, some
form of benefit to users who take long duration trips could attract more
members. Below are three of the main suggestions that I would suggest to
improve membership rates.

- Introduce a rebate or reduced pricing to members who frequently take
  long trips. Since casual users have an average trip duration of over
  20 minutes, Cyclistic could offer discounted membership to members who
  take a certain number of trips above 20 minutes in a year.
- Partner with fitness tracking services or apps to reward those who use
  the bike services for recreational or fitness purposes. Enabling easy
  linking to such services could attract more users to get a membership
  instead of investing in their own bike.
- Offer seasonal special rates for membership based on rider demand.
  Since casual ridership peaks in spring, offering membership at a
  reduced price at the beginning of the year may attract more casual
  users to sign up for membership.
