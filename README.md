# Getting-and-cleaning-data-Project

### Description
The purpose of this project is to demonstrate the ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. 

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained.

### Source data
The data and information about the variables are contained here
(http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

### Goal of project

1. To Merge the training and the test sets to create one data set.
2. To Extracts only the measurements on the mean and standard deviation for each measurement.
3. To Use descriptive activity names to name the activities in the data set
4. To appropriately label the data set with descriptive variable names.
5. To create an independent tidy data set with the average of each variable for each activity and each subjectf rom the data set in step 4

## Step by step explanation of the code
## 1. Loading the packages needed

library(data.table)
library(dplyr)
library(reshape2)

## 2. Downloading the files and reading all the data into R

### Download files and unzip them to Working directory

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(getwd(), "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

### Reading the UCI Har Dataset files into R

activityLabels <- fread("UCI HAR Dataset/activity_labels.txt",col.names = c("classLabels","activityname"))
featurelist <- fread("UCI HAR Dataset/features.txt",col.names = c("index","features"))

### isolating the mean and std features
selectfeatures <- grep("(mean|std)\\(\\)", featurelist[, features])
measurements <- featurelist[selectfeatures,features]
measurements <- gsub('[()]', '', measurements)

### reading the train and test data sets
x_train <- fread(file.path(getwd(), "UCI HAR Dataset/train/X_train.txt"))[,selectfeatures,with = FALSE]
data.table::setnames(x_train, colnames(x_train), measurements)
activity_train <- fread(file.path(getwd(),"UCI HAR Dataset/train/y_train.txt"),col.names = c("Activity"))
subject_train <- fread(file.path(getwd(),"UCI HAR Dataset/train/subject_train.txt"),col.names = c("subjectnumber"))

x_test <- fread(file.path(getwd(), "UCI HAR Dataset/test/X_test.txt"))[,selectfeatures,with = FALSE]
data.table::setnames(x_test, colnames(x_test), measurements)
activity_test <- fread(file.path(getwd(),"UCI HAR Dataset/test/y_test.txt"),col.names = c("Activity"))
subject_test <- fread(file.path(getwd(),"UCI HAR Dataset/test/subject_test.txt"),col.names = c("subjectnumber"))


## 3. Combining the test and train data sets

train <- cbind(activity_train,subject_train,x_train)
test <- cbind(activity_test,subject_test,x_test)

combined <- rbind(train,test)

## 4. Finalizing the data set

### Adding the activity labels to the combined data set dplyr
merged <- merge(combined,activityLabels,by.x = "Activity",by.y = "classLabels") %>%
select(activityname,subjectnumber,`tBodyAcc-mean-X`:`fBodyBodyGyroJerkMag-std`) 

### Creating the summarized tidy data set using melt and dcast

melted <- melt(merged, id=c("subjectnumber","activityname"))
finaldf <- dcast(melted, subjectnumber+activityname ~ variable, mean)

## 5. Writing the summarized data into a text file 

data.table::fwrite(x = finaldf, file = "tidyData.txt", quote = FALSE)




