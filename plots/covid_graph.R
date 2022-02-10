# recreate this brilliant graph: https://scontent-bru2-1.xx.fbcdn.net/v/t39.30808-6/271707360_10167182497640487_5929662526027937568_n.jpg?_nc_cat=109&ccb=1-5&_nc_sid=8bfeb9&_nc_ohc=zz3DWhG9I_4AX_OafmX&tn=D-s71FtFBgBw9nXZ&_nc_ht=scontent-bru2-1.xx&oh=00_AT-b1ihB5JpuFPa8LAfEItOAwnEafSMRgqHgWj9bYx3jkQ&oe=620877BC

# source of the data: https://github.com/nytimes/covid-19-data/blob/bb151f2da348623a793fc32f73a372bc9fe8ace1/rolling-averages/us.csv


library(tidyverse)


covid <- read_csv("data/NYTimes_Covid_us.csv")

# no scaling of deaths and cases: on same scale, deaths are almost invisible

ggplot(covid) + 
  geom_line(aes(x=date, y=cases), color="red") + 
  geom_line(aes(x=date, y=deaths), color="black")

# use percentage of the maximum of deaths and cases as scale:

max_deaths <- max(covid$deaths)
max_cases <- max(covid$cases)

ggplot(covid) + 
  geom_line(aes(x=date, y=cases/max_cases), color="red") + 
  geom_line(aes(x=date, y=deaths/max_deaths), color="black")

# Use percentage of the maximum of LAST YEAR's deaths and cases as scale:

n <- length(covid$deaths) # 750
max_deaths <- max(covid$deaths[1:n-150])
max_cases <- max(covid$cases[1:n-150])

ggplot(covid) + 
  geom_line(aes(x=date, y=cases/max_cases), color="red") + 
  geom_line(aes(x=date, y=deaths/max_deaths), color="black")

# use rolling average instead of raw numbers to efface weekend effect: 

n <- length(covid$deaths_avg) # 750
max_deaths_avg <- max(covid$deaths_avg[1:n-150])
max_cases_avg <- max(covid$cases_avg[1:n-150])

ggplot(covid) + 
  geom_line(aes(x=date, y=cases_avg/max_cases_avg), color="red") + 
  geom_line(aes(x=date, y=deaths_avg/max_deaths_avg), color="black")

# move the deaths 21 days ahead in order to be better able to compare cases and deaths: 

n <- length(covid$deaths_avg) # 750
max_deaths_avg <- max(covid$deaths_avg[1:n-150])
max_cases_avg <- max(covid$cases_avg[1:n-150])

ggplot(covid) + 
  geom_line(aes(x=date, y=cases_avg/max_cases_avg), color="red") + 
  geom_line(aes(x=date-21, y=deaths_avg/max_deaths_avg), color="black")

# add annotation at the peak of this year's and last year's waves:

n <- length(covid$deaths_avg) # 750
max_deaths_avg <- max(covid$deaths_avg[1:(n-150)])
max_cases_avg <- max(covid$cases_avg[1:(n-150)])

(avg_deaths_peak_1 <- max(covid$deaths_avg[1:(n-150)]))
(avg_deaths_peak_2 <- max(covid$deaths_avg[(n-150):n]))

(avg_deaths_peak_1_msg <- paste("peak1:", as.character(round(avg_deaths_peak_1)), "deaths"))
(avg_deaths_peak_2_msg <- paste("peak2:", as.character(round(avg_deaths_peak_2)), "deaths"))

(avg_deaths_peak_1_loc <- which(covid$deaths_avg[1:(n-150)] == avg_deaths_peak_1))
(avg_deaths_peak_2_loc <- (n-150) + which(covid$deaths_avg[(n-150):n] == avg_deaths_peak_2))
(avg_deaths_peak_1_date <- covid$date[avg_deaths_peak_1_loc])
(avg_deaths_peak_2_date <- covid$date[avg_deaths_peak_2_loc])

(avg_deaths_peak_1_msg <- paste("peak 1 (", 
                                as.character(covid$date[avg_deaths_peak_1_loc]), 
                                "): 100 % =",
                                as.character(round(avg_deaths_peak_1)), 
                                "deaths"))
(avg_deaths_peak_2_msg <- paste("peak 2 (", 
                                as.character(covid$date[avg_deaths_peak_2_loc]),
                                "):",
                                as.character(round(100*(avg_deaths_peak_2 / max_deaths_avg))),
                                "% =",
                                as.character(round(avg_deaths_peak_2)), 
                                "deaths"))


(avg_cases_peak_1 <- max(covid$cases_avg[1:(n-150)]))
(avg_cases_peak_2 <- max(covid$cases_avg[(n-150):n]))

(avg_cases_peak_1_loc <- which(covid$cases_avg[1:(n-150)] == avg_cases_peak_1))
(avg_cases_peak_2_loc <- (n-150) + which(covid$cases_avg[(n-150):n] == avg_cases_peak_2))
(avg_cases_peak_1_date <- covid$date[avg_cases_peak_1_loc])
(avg_cases_peak_2_date <- covid$date[avg_cases_peak_2_loc])

(avg_cases_peak_1_msg <- paste("peak 1 (", 
                               as.character(covid$date[avg_cases_peak_1_loc]), 
                               "): 100 % =",
                               as.character(round(avg_cases_peak_1)), 
                               "cases"))
(avg_cases_peak_2_msg <- paste("peak 2 (", 
                               as.character(covid$date[avg_cases_peak_2_loc]), 
                               "):",
                               as.character(round(100*(avg_cases_peak_2 / max_cases_avg))),
                               "% =",
                               as.character(round(avg_cases_peak_2)), 
                               "cases"))

move_deaths <- 21
move_msg <- paste("(deaths moved", as.character(move_deaths), "days back to match cases curve closer)")

ggplot(covid) + 
  geom_line(aes(x=date, y=cases_avg/max_cases_avg), color="red") + 
  geom_line(aes(x=date-move_deaths, y=deaths_avg/max_deaths_avg), color="black") +
  geom_hline(yintercept=1, linetype="dashed", color="darkgrey") + 
  # add points at the peaks:
  annotate("point", x=avg_cases_peak_1_date, y=avg_cases_peak_1 / max_cases_avg, color="red") + 
  annotate("point", x=avg_cases_peak_2_date, y=avg_cases_peak_2 / max_cases_avg, color="red") + 
  annotate("point", x=avg_deaths_peak_1_date-move_deaths, y=avg_deaths_peak_1 / max_deaths_avg, color="black") + 
  annotate("point", x=avg_deaths_peak_2_date-move_deaths, y=avg_deaths_peak_2 / max_deaths_avg, color="black") + 
  # add text annotations at the peaks:
  annotate("text", x=avg_cases_peak_1_date-40, y=0.1 + (avg_cases_peak_1 / max_cases_avg), label=avg_cases_peak_1_msg, color="red") + 
  annotate("text", x=avg_cases_peak_2_date-40, y=0.1 + (avg_cases_peak_2 / max_cases_avg), label=avg_cases_peak_2_msg, color="red") +
  annotate("text", x=avg_deaths_peak_1_date-40-move_deaths, y=0.2 + (avg_deaths_peak_1 / max_deaths_avg), label=avg_deaths_peak_1_msg, color="black") + 
  annotate("text", x=avg_deaths_peak_2_date-40-move_deaths, y=0.1 + (avg_deaths_peak_2 / max_deaths_avg), label=avg_deaths_peak_2_msg, color="black") +
  # add annotation about moving the deaths data to the left:
  annotate("text", x=covid$date[1]-move_deaths, y=-0.15, hjust=0, vjust=0, color="black", label=move_msg) +
  # display the y axis tick labels as percent rather than 1.0, 2.0 etc.:
  scale_y_continuous(labels = scales::percent) +
  # Add title + axis labels:
  labs(y="percentage of last winter's wave", 
       title="Omicron cases and deaths compared to last winter's wave (rolling averages)",
       caption="Data: NYTimes (https://github.com/nytimes/covid-19-data/blob/bb151f2da348623a793fc32f73a372bc9fe8ace1/rolling-averages/us.csv)")+
  theme_bw()

ggsave("plots/covid.png")