#run\_analysis.R
Howard Kendall      
October 23, 2015     

##Environment
Prior to using the **run\_analysis.R** script, the project data set needs to be downloaded from [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).  The downloaded file should be unzipped into a working directory containing the **run\_analysis.R** script. When this is done, the working directory should contain **run\_analysis.R** and the  **UCI HAR Dataset** folder.  Within the **UCI HAR Dataset** folder are four files (**activity\_labels.txt, features.txt, features\_info.txt and README.txt**) and two additional folders, **test** and **train**. This structure creates the working environment necessary for **run\_analysis.R**.     

To run the script in R or RStudio, type `source("run_analysis.R")` It will take a few moments for the script to finish due to the size of some of the files being read into memory.  Upon completion, the tidy data set is called **tidydata**.      
    
##What run\_analysis.R does
The work done by **run\_analysis.R** is broken down into six parts.     

###PART 1 - Reading and Loading Files     
The six text files that will make the body of the working data frame (**subject\_test.txt, subject\_train.txt, X\_test.txt, X\_train.txt, Y\_test.txt, Y\_train.txt**) are read using **read.table()** and assigned names (**sub\_test, sub\_train, x\_test, x\_train, y\_test, y\_train**). The **dplyr** library is also loaded at this time.

    sub_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
    sub_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
    x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
    x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
    y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
    y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
    library(dplyr)
###PART 2 - Creating the Vector of Variable Names     
The required variable names for **x\_test** and **x\_train** are contained in the second column of the data frame stored in the **features.txt** file. This was determined during a preliminary examination of **features.txt** in RStudio.  This second column of **features.txt** is read as a vector using **as.vector(read.table())** and assigned the name **features\_list**.     

    features_list <- as.vector((read.table("./UCI HAR Dataset/features.txt")[,2]))
To make this vector easier to work with later, **gsub()** is used to remove undesirable or unnecessary text or characters:     

**"-mean()"** is replaced with **"\_Mean"** and **"-std()"** is replaced with **"_Std"**. In both cases, the underscore is added so it can be used later for selecting columns.     

    features_list <- gsub("-mean\\(\\)", "_Mean", features_list)
    features_list <- gsub("-std\\(\\)", "_Std", features_list)
A hyphen, **"-"**, is removed anywhere it appears.     

    features_list <- gsub("-", "", features_list)     
 
**"BodyBody"** is replaced with **"Body"** to correct a duplication error in the features list. This information is found in the Coursera Getting and Cleaning Data Course Project Discussion Forum thread [***"Descriptive variable names" - what is meant by this?***](https://class.coursera.org/getdata-033/forum/thread?thread_id=118)     

    features_list <- gsub("BodyBody", "Body", features_list)     
A detailed explanation of variable names can be found in the **Codebook** file in this repository.

###PART 3 - Creating Intermediate Data Frames     
The contents of **features\_list** are added to the **x\_train** data frame as column names using **colnames()**. Also, column names of "activity" for **y\_train** and "subjectID" for **sub\_train** are manually added to those data frames using **colnames()**.     

    colnames(x_train) <- features_list
    colnames(y_train) <- "activity"
    colnames(sub_train) <- "subjectID"
Each of these three data frames contains the same number of rows.  They are joined together using **cbind()** to form an intermediate data frame named **train**.  The data frames are listed in **cbind()** in the order they are to appear in **train** from left to right.  The subjectID will be first, followed by the activity, then the variable measurements.     

    train <- cbind(sub_train, y_train, x_train)
The same process is repeated using the **x\_test**, **y\_test** and **sub\_test** data frames to produce a second intermediate data frame named **test**.      

    colnames(x_test) <- features_list
    colnames(y_test) <- "activity"
    colnames(sub_test) <- "subjectID"
    test <- cbind(sub_test, y_test, x_test)
###PART 4 - Joining "Train" and "Test" into "mergeddata"
**Train** and **Test** contain the same number of columns.  They are joined together using **rbind()** to form a new data frame named **mergeddata** which is 10299 rows by 563 columns.     

    mergeddata <- rbind(test, train)
###PART 5 - Finalizing "mergeddata"
Attempting to pick out the desired columns from **mergeddata** using **select()** at this point results in an error due to duplicate column names.  It turns out that duplicate column names existed in the original raw data file **features.txt**.  None of these columns contain mean or standard deviation measurements desired for the final output and can be eliminated.  This is supported by information found in the Coursera Getting and Cleaning Data Course Project Discussion Forum thread [***Duplicate column names i training and test dataset***](https://class.coursera.org/getdata-033/forum/thread?thread_id=194).     

To remove these columns, the duplicate column numbers are determined using **which(duplicated())**, then **mergeddata** is subsetted keeping only those columns that were **not** duplicates.     

    mergeddata <- mergeddata[, -which(duplicated(features_list))]
Using **select()**, **mergeddata** is further reduced by creating a subset of itself  with the columns containing measurements on the mean and standard deviation.  These columns are identified using the underscore in the character strings **\_Mean** and **\_Std** which were inserted into the column names in Part 2. Subsetting is accomplished using **contains("\_")**.  The identifier columns, **subjectID** and **activity**, are also selected to be kept.  The result is converted to a data frame tbl using **tbl\_df()** for further processing with **dplyr**.     

    mergeddata <- select(mergeddata, subjectID, activity, contains("_"))
    mergeddata <- tbl_df(mergeddata)
###PART 6 - Final Tidy Data
Using chained commands, **mergeddata** is grouped by **subjectID** and **activity**. It is then summarized using **summarise\_each()** to calculate the mean of each measurement for each subject/activity grouping. The resulting data frame tbl is named **tidydata**.    

    tidydata <- mergeddata %>% group_by(subjectID, activity) %>% summarise_each(funs(mean))
The required activity names are found in the second column of the data frame stored in the **activity\_labels.txt** file. This was determined during a preliminary examination of **activity\_labels.txt** in RStudio.  This second column of **activity\_labels.txt** is read as a vector using **as.vector(read.table())** and assigned the name **activity\_list**.     

The activity numbers in **tidydata** are replaced with activity names from **activity\_list** using a loop that matches activity number to activity name.    

    activity_list <- as.vector((read.table("./UCI HAR Dataset/activity_labels.txt")[,2]))
    for (i in 1:6){
    tidydata$activity[tidydata$activity == i] <- activity_list[i]
    }
##Output
The final object created by running the script **run\_analysis.R** is named **tidydata**.  This is a wide format  data set that exhibits the principles of tidy data. Each variable measured is contained in a single  uniquely named column, each activity and the mean of each measurement for that activity are on a single row, and these rows are grouped by study subject.     

To write **tidydata** to a text file in R or RStudio, type     
    
    write.table(tidydata, file = "tidydata.txt", row.names = FALSE)
To read **tidydata.txt** in R or RStudio, type     

    read.table("tidydata.txt", header = TRUE)
