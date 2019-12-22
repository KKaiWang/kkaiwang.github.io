##### Loading library and reading datatset #####

# try to load readxl package, for reading the data stored in Excel format
if (!require(readxl)) {
  install.packages("readxl")
  library(readxl)
}

# set working directory first

# read the dataset
responses <- read_excel("PersonalPages/JEMDOC/consulting/most_time_coverage/SquashClubInitialFormMar6.xlsx")

##### Re-formate responses into binary table #####

# creates storage for the binary table indicating availability of respondents
days_of_week <- c("Monday", "Tuesday", "Wednesday", "Thursday", 
                  "Friday", "Saturday", "Sunday")

times_of_day <- c("9:00am", "9:30am", "10:00am", "10:30am", "11:00am", "11:30am",
                  "12:00pm", "12:30pm", "1:00pm", "1:30pm", "2:00pm", "2:30pm", 
                  "3:00pm", "3:30pm","4:00pm", "4:30pm", "5:00pm", "5:30pm",
                  "6:00pm", "6:30pm", "7:00pm", "7:30pm","8:00pm", "8:30pm", 
                  "9:00pm", "9:30pm")

num_respondents <- nrow(responses)
timetable <- matrix(0, nrow = num_respondents, 
                    ncol = length(days_of_week) * length(times_of_day))
dim(timetable)
days_times <- as.vector(t(outer(X = days_of_week, Y = times_of_day, FUN = paste0)))
length(days_times)
colnames(timetable) <- days_times
rownames(timetable) <- responses$Name

for (day in days_of_week) {
  availability_day <- as.matrix(responses[,grep(pattern = day, 
                                                x = colnames(responses))])
  for (person in 1:num_respondents) {
    # extract available times
    available_times <- strsplit(x = availability_day[person], split = ";")
    available_times <- unlist(available_times)
    if (!is.na(available_times[1])) {
      for (availablie_time in available_times) {
        # mark person-day-time as available
        timetable[person, paste0(day, availablie_time)] <- 1
      }
    }
  }
}

##### convert availability into hour-long sessions #####

hours_of_day <- c("9:00am", "9:30am", "10:00am", "10:30am", "11:00am", "11:30am",
                  "12:00pm", "12:30pm", "1:00pm", "1:30pm", "2:00pm", "2:30pm", 
                  "3:00pm", "3:30pm","4:00pm", "4:30pm", "5:00pm", "5:30pm",
                  "6:00pm", "6:30pm", "7:00pm", "7:30pm","8:00pm", "8:30pm", 
                  "9:00pm")

hour_table <- matrix(0, nrow = num_respondents, 
                     ncol = length(days_of_week) * length(hours_of_day))
dim(hour_table)

days_hours <- as.vector(t(outer(X = days_of_week, Y = hours_of_day, FUN = paste0)))
length(days_hours)
colnames(hour_table) <- days_hours
rownames(hour_table) <- responses$Name

for (day in days_of_week) {
  for (this_time in hours_of_day) {
    # locate the corresponding time in the 30-min table, and then find the next time
    next_time <- times_of_day[grep(paste0("^", this_time), times_of_day) + 1]
    # if this time and next time are both 1, then mark as 1 in hour table
    hour_table[, paste0(day, this_time)] <- (timetable[, paste0(day, this_time)] & 
                                               timetable[, paste0(day, next_time)])
  }
}
rownames()

##### Search for the best combination of 2 x hour-long slots #####

best_coverage <- 0
best_two_slots <- list(c(colnames(hour_table)[1], colnames(hour_table)[2]))

for (i in colnames(hour_table)) {
  for (j in colnames(hour_table)) {
    coverage <- sum(hour_table[,i] | hour_table[,j])
    if (coverage == best_coverage) {
      best_two_slots <- c(best_two_slots, list(c(i,j)))
    }
    if (coverage > best_coverage) {
      best_coverage <- coverage
      best_two_slots <- list(c(i, j))
    }
  }
}
best_coverage
best_two_slots

# print all best combinations
for (slot_combination in best_two_slots) {
  print(hour_table[, slot_combination])
}


