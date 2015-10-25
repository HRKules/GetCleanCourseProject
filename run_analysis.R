        ## Read text files and load dplyer library
sub_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
sub_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
library(dplyr)
        ## Read "features.txt' and format it for later use by eliminating "(" ")" and "-" characters
        ## Also replace "BodyBody" instances with "Body"
features_list <- as.vector((read.table("./UCI HAR Dataset/features.txt")[,2]))
features_list <- gsub("-mean\\(\\)", "_Mean", features_list)
features_list <- gsub("-std\\(\\)", "_Std", features_list)
features_list <- gsub("-", "", features_list)
features_list <- gsub("BodyBody", "Body", features_list)
        ## Name columns in _train files, then bind them together using cbind() into "train"
colnames(x_train) <- features_list
colnames(y_train) <- "activity"
colnames(sub_train) <- "subjectID"
train <- cbind(sub_train, y_train, x_train)
        ## Name columns in _test files, then bind them together using cbind() into "test"
colnames(x_test) <- features_list
colnames(y_test) <- "activity"
colnames(sub_test) <- "subjectID"
test <- cbind(sub_test, y_test, x_test)
        ## Bind "train" and "test" using rbind() to create "mergeddata"
        ## Remove duplicate and irrelevant columns that would cause problems later 
mergeddata <- rbind(test, train)
mergeddata <- mergeddata[, -which(duplicated(features_list))]
        ## Use only "subjectID" and "activity" columns and any columns containing "_Mean" or "_Std"
        ## Call tbl_df() on the result in preparation of manipulating with dplyr
mergeddata <- select(mergeddata, subjectID, activity, contains("_"))
mergeddata <- tbl_df(mergeddata)
        ## Group "mergeddata" by "subjectID" and "activity" columns THEN
        ## Calculate the mean of the measurements for each subject/activity group and assign to "tidydata"
tidydata <- mergeddata %>% group_by(subjectID, activity) %>% summarise_each(funs(mean))
        ## Read column 2 of activy_labels.txt and assign activity names to matching activity numbers
activity_list <- as.vector((read.table("./UCI HAR Dataset/activity_labels.txt")[,2]))
for (i in 1:6){
        tidydata$activity[tidydata$activity == i] <- activity_list[i]
}