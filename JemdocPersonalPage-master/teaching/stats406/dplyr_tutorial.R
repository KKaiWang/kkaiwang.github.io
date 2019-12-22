
if(!require(dplyr)){
  install.packages("dplyr")
  library(dplyr)
}
if(!require(tidyr)){
  install.packages("tidyr")
  library(tidyr)
}
install.packages("nycflights13")
library(nycflights13)
dim(flights)
# tbl is less verbose
head(flights)
# see its class
class(flights)

#### filtering rows by col values ####
filter(flights, month == 1, day == 1)
# same as
flights[flights$month == 1 & flights$day == 1, ]
# used in conjunction with OR operator
filter(flights, month == 1 | month == 2)
# slice selects the rows
slice(flights, 1:10)

#### arrange orders the tbl ####
arrange(flights, year, month, day)
# in descending order
arrange(flights, desc(arr_delay))
# corresponding code if you use base R functions only
flights[order(flights$year, flights$month, flights$day), ]
flights[order(flights$arr_delay, decreasing = TRUE), ]

#### select columns ####
select(flights, year, month, day)
# select columns between two col names
select(flights, year:day)
# excluding col by names
select(flights, -(year:day))
# select with a helper function
select(flights, matches("._time"))
# renaming a column
select(flights, tail_num = tailnum)
# `rename' keeps the other columns, unlike `select'
rename(flights, tail_num = tailnum)

#### Extract distinct (unique) rows ####
distinct(flights, tailnum)
# and using a combination of columns
distinct(flights, origin, dest)

#### Add new columns with mutate() ####
mutate(flights,
       gain = arr_delay - dep_delay,
       speed = distance / air_time * 60)
# mutate allows using col newyl created
mutate(flights,
       gain = arr_delay - dep_delay,
       gain_per_hour = gain / (air_time / 60)
)
# transmute only keeps the new cols
transmute(flights,
          gain = arr_delay - dep_delay,
          gain_per_hour = gain / (air_time / 60)
)

#### Summarise values with summarise() ####
summarise(flights,
          delay = mean(dep_delay, na.rm = TRUE))

#### Randomly sample rows with sample_n() and sample_frac() ####
sample_n(flights, 10)
sample_frac(flights, 0.01)
# replace = TRUE to perform a bootstrap sample
# weight is also available for weighted sampling

#### Grouped operations ####
by_tailnum <- group_by(flights, tailnum)
delay <- summarise(by_tailnum,
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE))
delay <- filter(delay, count > 20, dist < 2000)
# plot delay against distance
library(ggplot2)
ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2) +
  geom_smooth() +
  scale_size_area()
# illustrate use of aggregate function n_distinct()
destinations <- group_by(flights, dest)
summarise(destinations,
          planes = n_distinct(tailnum),
          flights = n()
)
# When you group by multiple variables, 
# each summary peels off one level of the grouping. 
daily <- group_by(flights, year, month, day)
(per_day   <- summarise(daily, flights = n()))
(per_month <- summarise(per_day, flights = sum(flights)))
(per_year  <- summarise(per_month, flights = sum(flights)))

#### Chaining ####
# dplyr provides the %>% operator.
# x %>% f(y) turns into f(x, y)
flights %>%
  group_by(year, month, day) %>%
  select(arr_delay, dep_delay) %>%
  summarise(
    arr = mean(arr_delay, na.rm = TRUE),
    dep = mean(dep_delay, na.rm = TRUE)
  ) %>%
  filter(arr > 30 | dep > 30)
# same as the following code chunk, but much easier to read
filter(
  summarise(
    select(
      group_by(flights, year, month, day),
      arr_delay, dep_delay
    ),
    arr = mean(arr_delay, na.rm = TRUE),
    dep = mean(dep_delay, na.rm = TRUE)
  ),
  arr > 30 | dep > 30
)


