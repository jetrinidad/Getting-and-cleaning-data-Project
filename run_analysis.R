## Download files and unzip them to Working directory

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(getwd(), "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

## Load packages
library(data.table)
library(dplyr)
library(reshape2)


## reading activity labels
activityLabels <- fread("UCI HAR Dataset/activity_labels.txt",col.names = c("classLabels","activityname"))

## reading features 
featurelist <- fread("UCI HAR Dataset/features.txt",col.names = c("index","features"))
selectfeatures <- grep("(mean|std)\\(\\)", featurelist[, features])

## Select only mean and std features
measurements <- featurelist[selectfeatures,features]
measurements <- gsub('[()]', '', measurements)


## Reading and combining the train data set
x_train <- fread(file.path(getwd(), "UCI HAR Dataset/train/X_train.txt"))[,selectfeatures,with = FALSE]
data.table::setnames(x_train, colnames(x_train), measurements)


activity_train <- fread(file.path(getwd(),"UCI HAR Dataset/train/y_train.txt"),col.names = c("Activity"))
subject_train <- fread(file.path(getwd(),"UCI HAR Dataset/train/subject_train.txt"),col.names = c("subjectnumber"))

train <- cbind(activity_train,subject_train,x_train)


## Reading and combining the test data set
x_test <- fread(file.path(getwd(), "UCI HAR Dataset/test/X_test.txt"))[,selectfeatures,with = FALSE]
data.table::setnames(x_test, colnames(x_test), measurements)


activity_test <- fread(file.path(getwd(),"UCI HAR Dataset/test/y_test.txt"),col.names = c("Activity"))
subject_test <- fread(file.path(getwd(),"UCI HAR Dataset/test/subject_test.txt"),col.names = c("subjectnumber"))

test <- cbind(activity_test,subject_test,x_test)


## combine train and test data

combined <- rbind(train,test)


## Add activity labels to combined dataset
merged <- merge(combined,activityLabels,by.x = "Activity",by.y = "classLabels") %>%
select(activityname,subjectnumber,`tBodyAcc-mean-X`:`fBodyBodyGyroJerkMag-std`) %>%
print

## Getting summarized data set


melted <- melt(merged, id=c("subjectnumber","activityname"))
finaldf <- dcast(melted, subjectnumber+activityname ~ variable, mean)

## Writing the summary into a csv file

data.table::fwrite(x = finaldf, file = "tidyData.txt", quote = FALSE)

       
