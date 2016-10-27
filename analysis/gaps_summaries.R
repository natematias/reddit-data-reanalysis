library(ggplot2)
library(lubridate)


rm(list=ls())

#### PLOT MISSING DATA PER DAY (COMMENTS)
missing_data_comments <- read.csv("../data/aggregate_data/Missing Data Timeline - Comment Timeline.csv")
missing_data_comments$day <- as.Date(missing_data_comments$Date, format="%m/%d/%Y")

ggplot(missing_data_comments, aes(day, log1p(Count))) +
  geom_line(color="cornflowerblue") +
  theme(axis.text.x = element_text(hjust=0, vjust=1, size=14), 
        axis.title=element_text(size=14), 
        panel.background = element_rect(fill = "white"),
        plot.title = element_text(size = 16, colour = "black", vjust = -1)) +
  ggtitle("ln Missing Comments Per Day (Calculated by Checking Missing Reply Parents)")

ggplot(missing_data_comments, aes(day, Count)) +
  geom_line(color="orangered4") +
  theme(axis.text.x = element_text(hjust=0, vjust=1, size=14), 
        axis.title=element_text(size=14), 
        panel.background = element_rect(fill = "white"),
        plot.title = element_text(size = 16, colour = "black", vjust = -1)) +
  ggtitle("Missing Comments Per Day (Calculated by Checking Missing Reply Parents)")

ggplot(missing_data_comments, aes(day, Cumulative)) +
  geom_area(fill="orangered4") +
  theme(axis.text.x = element_text(hjust=0, vjust=1, size=14), 
        axis.title=element_text(size=14), 
        panel.background = element_rect(fill = "white"),
        plot.title = element_text(size = 16, colour = "black", vjust = -1)) +
  ggtitle("Cumulative Missing Comments Over Time (Calculated by Checking Missing Reply Parents)")


#### PLOT MISSING DATA PER ID RANGE (COMMENTS)
missing_data_comments_ids <- read.csv("../data/aggregate_data/Missing Data Timeline - Spectral Scan Comments.csv")
missing_data_comments_ids$ID.Partition.Base.10

ggplot(missing_data_comments_ids, aes(ID.Partition.Base.10, log1p(Missing.Count))) +
  geom_line(color="cornflowerblue") +
  theme(axis.text.x = element_text(hjust=0, vjust=1, size=14), 
        axis.title=element_text(size=14), 
        panel.background = element_rect(fill = "white"),
        plot.title = element_text(size = 16, colour = "black", vjust = -1)) +
  ggtitle("ln Missing Comments Per 1,000,000 (Calculated by Checking Missing IDs)")

ggplot(missing_data_comments_ids, aes(ID.Partition.Base.10, Missing.Count)) +
  geom_line(color="orangered4") +
  theme(axis.text.x = element_text(hjust=0, vjust=1, size=14), 
        axis.title=element_text(size=14), 
        panel.background = element_rect(fill = "white"),
        plot.title = element_text(size = 16, colour = "black", vjust = -1)) +
  ggtitle("Missing Submission Per 1,000,000 (Calculated by Checking Missing IDs)")

ggplot(missing_data_comments_ids, aes(ID.Partition.Base.10, Cumulative)) +
  geom_area(fill="orangered4") +
  theme(axis.text.x = element_text(hjust=0, vjust=1, size=14), 
        axis.title=element_text(size=14), 
        panel.background = element_rect(fill = "white"),
        plot.title = element_text(size = 16, colour = "black", vjust = -1)) +
  ggtitle("Missing Comments Per 1,000,000 (Calculated by Checking Missing IDs)")

#### PLOT MISSING DATA PER DAY (POSTS)
missing_data_posts <- read.csv("../data/aggregate_data/Missing Data Timeline - Submission Timeline.csv")
missing_data_posts$day <- as.Date(missing_data_posts$Date, format="%m/%d/%Y")

ggplot(missing_data_posts, aes(day, log1p(Count))) +
  geom_line(color="cornflowerblue") +
  theme(axis.text.x = element_text(hjust=0, vjust=1, size=14), 
        axis.title=element_text(size=14), 
        panel.background = element_rect(fill = "white"),
        plot.title = element_text(size = 16, colour = "black", vjust = -1)) +
  ggtitle("ln Missing Submissions Per Day (Calculated by Checking Missing Reply Parents)")

ggplot(missing_data_posts, aes(day, Count)) +
  geom_line(color="orangered4") +
  theme(axis.text.x = element_text(hjust=0, vjust=1, size=14), 
        axis.title=element_text(size=14), 
        panel.background = element_rect(fill = "white"),
        plot.title = element_text(size = 16, colour = "black", vjust = -1)) +
  ggtitle("Missing Submission Per Day (Calculated by Checking Missing Reply Parents)")

ggplot(missing_data_posts, aes(day, Cumulative)) +
  geom_area(fill="orangered4") +
  theme(axis.text.x = element_text(hjust=0, vjust=1, size=14), 
        axis.title=element_text(size=14), 
        panel.background = element_rect(fill = "white"),
        plot.title = element_text(size = 16, colour = "black", vjust = -1)) +
  ggtitle("Cumulative Missing Submission Per Day (Calculated by Checking Missing Reply Parents)")


#### PLOT MISSING DATA PER ID RANGE (POSTS)
missing_data_posts_ids <- read.csv("../data/aggregate_data/Missing Data Timeline - Spectral Scan Submissions.csv")
missing_data_posts_ids$ID.Partition.Base.10

ggplot(missing_data_posts_ids, aes(ID.Partition.Base.10, log1p(Missing.Count))) +
  geom_line(color="cornflowerblue") +
  theme(axis.text.x = element_text(hjust=0, vjust=1, size=14), 
        axis.title=element_text(size=14), 
        panel.background = element_rect(fill = "white"),
        plot.title = element_text(size = 16, colour = "black", vjust = -1)) +
  ggtitle("ln Missing Submissions Per 100,000 (Calculated by Checking Missing IDs)")


ggplot(missing_data_posts_ids, aes(ID.Partition.Base.10, Missing.Count)) +
  geom_line(color="orangered4") +
  theme(axis.text.x = element_text(hjust=0, vjust=1, size=14), 
        axis.title=element_text(size=14), 
        panel.background = element_rect(fill = "white"),
        plot.title = element_text(size = 16, colour = "black", vjust = -1)) +
  ggtitle("Missing Submission Per 100,000 (Calculated by Checking Missing IDs)")

ggplot(missing_data_posts_ids, aes(ID.Partition.Base.10, Cumulative)) +
  geom_area(fill="orangered4") +
  theme(axis.text.x = element_text(hjust=0, vjust=1, size=14), 
        axis.title=element_text(size=14), 
        panel.background = element_rect(fill = "white"),
        plot.title = element_text(size = 16, colour = "black", vjust = -1)) +
  ggtitle("Missing Submission Per 100,000 (Calculated by Checking Missing IDs)")

