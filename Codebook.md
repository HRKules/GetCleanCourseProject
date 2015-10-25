# Data Codebook - tidydata.txt  
Howard Kendall  
October 22, 2015  


## Course Project Description
The purpose of this project was to take raw data collected using the accelerometer and gyroscope in Samsung Galaxy S smartphones and process that data into a new, tidy data based on certain criteria.    
###Project Criteria    
The final deliverable should follow these guidelines:     

- Contain only variables involving the mean or standard deviation for each measurement.
- Use descriptive activity names.
- Use descriptive variable names.
- Summarize the data set with the average of each variable for each activity and each subject.
- The final product should exhibit the principles of tidy data.     

The project files can be downloaded here: [(`PROJECT DOWNLOAD`)](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
##Raw Data Collection & Description      
###Experiment and Raw Data Collection
This study was performed on 30 subjects between the ages of 19 and 48. During the performance of six activities (walking, walking up stairs, walking down stairs, sitting, standing, laying), 3-axial linear acceleration and 3-axial angular velocity were recorded using the smartphone's built-in accelerometer and gyroscope. These measurements were processed further into a raw data set of 561 features. This data was split into two groups, **train** and **test**, by randomly assigning 70% of the subjects (21 subjects) to **train** and 30% (9 subjects) to **test**.       

Additional information regarding the collection and processing of the data can be found by viewing **README.txt** and **features_info.txt**  in the project download.      
###Raw Data Description     
Overall, the data set consists of 10299 instances and 561 attributes.  The information is split across 6 text files found in two directories in the project download:     

- **/UCI HAR Dataset/train/X_train.txt** - contains the measurements for the **train** subjects.
-  **/UCI HAR Dataset/train/Y_train.txt** - identifies which activity was performed for each measurement in **X\_train.txt**.
-  **/UCI HAR Dataset/train/subject_train.txt** - identifies the test subject who performed the activity for each measurement in **X\_train.txt**.
-  **/UCI HAR Dataset/test/X_test.txt** - contains the measurements for the **test** subjects.
-  **/UCI HAR Dataset/test/Y_test.txt** - identifies which activity was performed for each measurement in **X\_test.txt**.
-  **/UCI HAR Dataset/test/subject_test.txt** - identifies the test subject who performed the activity for each measurement in **X\_test.txt**.     

In addtion,     

- **/UCI HAR Dataset/features.txt** - provides the list of all column names for **X\_train.txt** and **X\_test.txt**.
- **/UCI HAR Dataset/activity\_labels.txt** - provides a cross-reference between the activity number found in **Y\_train.txt** and **Y_test.txt** and the activity name.     

##Tidy Data     
###Processing steps     
The following list describes the steps taken to process the raw data into the desired tidy data:      

1. The six text files that will make the body of the working data frame (**X\_train.txt, Y\_train.txt, subject\_train.txt, X\_test.txt, Y\_test.txt, subject\_test.txt**) are read using **read.table()** and assigned names.     
2. Advance examination of the **features.txt** file shows it to be a data frame with the required variable names in the second column. The second column of **features.txt** is read as a vector using **as.vector(read.table())** and assigned a name. This vector is processed to make it easier to use later by remove undesirable or unnecessary text or characters. Specifically, the following changes are made wherever found in the vector using **gsub()**:      



	- **"-mean()"** is replaced with **"_Mean"**. The underscore is used later for selecting columns.
	- **"-std()"** is replaced with **"_Std"**. The underscore is used later for selecting columns.
	- **"-"** is removed anywhere it appears.
	- **"BodyBody"** is replaced with **"Body"**.  This corrects a duplication error in the features list. This information is found in the Coursera Getting and Cleaning Data Course Project Discussion Forum thread [***"Descriptive variable names" - what is meant by this?***](https://class.coursera.org/getdata-033/forum/thread?thread_id=118)     
3. Column names from the modified vector created in Step 2 are added to both **X\_train** and **X\_test** using **colnames()**.
4.  **Y\_train/Y\_test** and **subject\_train\/subject\_test** are manually assigned column names of "activity" and "subjectID" respectively using **colnames()**.
5.  Using **cbind()**, an intermediate data frame called **test** is created by joining **subject\_test, Y\_test, and X\_test**. Another intermediate data frame called **train** is created by joining **subject\_train, Y\_train, and X\_train**.
6.  **train** and **test** are joined with **rbind()** to form another data frame called **mergeddata**, which is further processed as follows:
	- Duplicate columns are removed. None of these columns contain mean or standard deviation measurements and can be eliminated.  This information can be found in the Coursera Getting and Cleaning Data Course Project Discussion Forum thread [***Duplicate column names i training and test dataset***](https://class.coursera.org/getdata-033/forum/thread?thread_id=194).
	- **mergeddata** is reduced by using the dplyr function **select()** to eliminate all columns except the columns **"subjectID", "activity" and any column containing an underscore "\_"**.  The underscore was inserted back in Step 2, and was inserted only in the columns that originally contained the string "mean\(\)" or "std\(\)". These columns are ***retained*** because according to the variable descriptions in **features\_info.txt** in the project download, variables containing "mean\(\)" or "std\(\)" at the end were estimated from the original signals. Other variable that include "mean" or "mean\(\)" are not directly related to the original signals, such as the mean of a frequency or the mean of an angle between two vectors. These columns are ***discarded***.      
7. The function **tbl\_df** is called with the **mergeddata** data frame as the argument prior to additional processing.
8.  **mergeddata** is grouped by **subjectID** and **activity** using **grouped\_by()**, then each variable column is summarised by calculating the mean for each grouping using **summarise\_each(funs(mean))**. 
9.  Advance examination of the **activity\_labels.txt** file shows it to be a data frame with activity names in the second column. The second column of **activity\_labels.txt** is read as a vector using **as.vector(read.table())** and assigned a name. This vector is then used in a "for" loop to replace activity numbers with the actual activity names.
###run-analysis.R Script     
The included script, **run\_analysis.R** accomplishes all the processing steps listed above. In order for it to be run, both the script and the UCI HAR Dataset folder must be in your working directory.  Type `source("run_alalysis.R)` to run the script.     

The desired tidy dataframe, **tidydata**, can be written to a text file using `write.table(tidydata, file = "tidydata.txt", row.names = FALSE)`     

To read **tidydata.txt**, type `read.table("tidydata.txt", header = TRUE)`     

A complete and detailed description of the script **run\_analysis.R** can be found in the **README** file in this repository.
### The resulting tidy data
The **tidydata** data set produced by the **run\_analysis.R** script is a wide format that exhibits the principles of tidy data. First, each variable measured is contained in a single column. Each column is labeled with a descriptive name to confirm there is only one variable per column.  Second, each observation of that variable is a different row. Each activity and the mean of each measurement for that activity is a single row, and these rows are grouped by subjectID.      

It is important to remember that **run\_analysis.R** has produced a summary of the raw data. The values listed for each observation's measurements are **the mean** of the raw measurements for that activity for that subject.

##Variables in tinydata.txt
###Description
**tinydata.txt** is 180 rows by 68 columns. The first two variable columns, "subjectID" and the "activity", are identifiers for the measurements in columns 3-68.     

The measurement columns are labeled with descriptive variable names using a specific naming convention.  Using **tBodyGyroJerk\_MeanX** as an example:    
 
- The first portion of the example is a lowercase "**t**".  This can be either a "**t**" or "**f**" indicating "time" or "frequency" domain signals.
- The next portion of the example name, **BodyGyro**, describes the source of the signal. Possibilities are **BodyGyro** (built-in gyroscope), **BodyAcc** (accelerometer signal not due to gravity), or **GravityAcc** (accelerometer signal due to gravity).
- The next portion of the example, **Jerk**, describes further processing of other variables.  Possibilites are  **Jerk** (rate of chage of acceleration), **Mag** (the calculated magnitude of tri-axial measurements), or **JerkMag** (the calculated magnitude of the jerk in three dimensions). This portion is not always present.
- Next in the example is **\_Mean**.  This portion of the name indicates what sort of statistical calculation was performed on the measurements.  Possibilities are **\_Mean** (mean) or **\_Std** (standard deviation).
- The last portion of the example, **X**, indicates the three-dimensional axis along which the measurement is taken. Possibilities are **X**, **Y** or **Z**.  This portion will not be present if the measurement in question is not tri-axial.     

Units of measurement are not available for any variable is this data set.

###Variable List
1.  **subjectID**
	- Identifies the subject for the observation.
	- Integer with values between 1 and 30.       
2.   **activity**
	- Identifies the activity being done while measurements were collected.
	- Factor with 6 levels: "WALKING", "WALKING\_UPSTAIRS", "WALKING\_DOWNSTAIRS", "SITTING", "STANDING", "LAYING".       
3.   **tBodyAcc\_MeanX**
	- Mean of time domain measurements from accelerometer signal not due to gravity along X axis.
	- Numeric.       
4.   **tBodyAcc\_MeanY**
	- Mean of time domain measurements from accelerometer signal not due to gravity along Y axis.
	- Numeric.       
5.   **tBodyAcc\_MeanZ**
	- Mean of time domain measurements from accelerometer signal not due to gravity along Z axis.
	- Numeric.       
6.   **tBodyAcc\_StdX**
	- Standard deviation of time domain measurements from accelerometer signal not due to gravity along X axis.
	- Numeric.       
7.   **tBodyAcc\_StdY**
	- Standard deviation of time domain measurements from accelerometer signal not due to gravity along Y axis.
	- Numeric.       
8.   **tBodyAcc\_StdZ**
	- Standard deviation of time domain measurements from accelerometer signal not due to gravity along Z axis.
	- Numeric.       
9.   **tGravityAcc\_MeanX**
	- Mean of time domain measurements from accelerometer signal due to gravity along X axis.
	- Numeric.       
10.   **tGravityAcc\_MeanY**
	- Mean of time domain measurements from accelerometer signal due to gravity along Y axis.
	- Numeric.       
11.   **tGravityAcc\_MeanZ**
	- Mean of time domain measurements from accelerometer signal due to gravity along Z axis.
	- Numeric.       
12.   **tGravityAcc\_StdX**
	- Standard deviation of time domain measurements from accelerometer signal due to gravity along X axis.
	- Numeric.       
13.   **tGravityAcc\_StdY**
	- Standard deviation of time domain measurements from accelerometer signal due to gravity along Y axis.
	- Numeric.       
14.   **tGravityAcc\_StdZ**
	- Standard deviation of time domain measurements from accelerometer signal due to gravity along Z axis.
	- Numeric.       
15.   **tBodyAccJerk\_MeanX**
	- Mean of rate of change of time domain measurements from accelerometer signal not due to gravity along X axis.
	- Numeric.       
16.   **tBodyAccJerk\_MeanY**
	- Mean of rate of change of time domain measurements from accelerometer signal not due to gravity along Y axis.
	- Numeric.       
17.   **tBodyAccJerk\_MeanZ**
	- Mean of rate of change of time domain measurements from accelerometer signal not due to gravity along Z axis.
	- Numeric.       
18.   **tBodyAccJerk\_StdX**
	- Standard deviation of the rate of change of time domain measurements from accelerometer signal not due to gravity along X axis.
	- Numeric.       
19.   **tBodyAccJerk\_StdY**
	- Standard deviation of the rate of change of time domain measurements from accelerometer signal not due to gravity along Y axis.
	- Numeric.       
20.   **tBodyAccJerk\_StdZ**
	- Standard deviation of the rate of change of time domain measurements from accelerometer signal not due to gravity along Z axis.
	- Numeric.       
21.   **tBodyGyro\_MeanX**
	- Mean of time domain measurements from gyroscope signal along X axis.
	- Numeric.       
22.   **tBodyGyro\_MeanY**
	- Mean of time domain measurements from gyroscope signal along Y axis.
	- Numeric.       
23.   **tBodyGyro\_MeanZ**
	- Mean of time domain measurements from gyroscope signal along Z axis.
	- Numeric.       
24.   **tBodyGyro\_StdX**
	- Standard deviation of time domain measurements from gyroscope signal along X axis.
	- Numeric.       
25.   **tBodyGyro\_StdY**
	- Standard deviation of time domain measurements from gyroscope signal along Y axis.
	- Numeric.       
26.   **tBodyGyro\_StdZ**
	- Standard deviation of time domain measurements from gyroscope signal along Z axis.
	- Numeric.       
27.   **tBodyGyroJerk\_MeanX**
	- Mean of rate of change of time domain measurements from gyroscope signal along X axis.
	- Numeric.       
28.   **tBodyGyroJerk\_MeanY**
	- Mean of rate of change of time domain measurements from gyroscope signal along Y axis.
	- Numeric.       
29.   **tBodyGyroJerk\_MeanZ**
	- Mean of rate of change of time domain measurements from gyroscope signal along Z axis.
	- Numeric.       
30.   **tBodyGyroJerk\_StdX**
	- Standard deviation of the rate of change of time domain measurements from gyroscope signal along X axis.
	- Numeric.       
31.   **tBodyGyroJerk\_StdY**
	- Standard deviation of the rate of change of time domain measurements from gyroscope signal along Y axis.
	- Numeric.       
32.   **tBodyGyroJerk\_StdZ**
	- Standard deviation of the rate of change of time domain measurements from gyroscope signal along Z axis.
	- Numeric.       
33.   **tBodyAccMag\_Mean**
	- Mean of calculated magnitude of the three-dimensional time domain measurements from accelerometer signal not due to gravity.
	- Numeric.       
34.   **tBodyAccMag\_Std**
	- Standard deviation of the calculated magnitude of the three-dimensional time domain measurements from accelerometer signal not due to gravity.
	- Numeric.       
35.   **tGravityAccMag\_Mean**
	- Mean of calculated magnitude of the three-dimensional time domain measurements from accelerometer signal due to gravity.
	- Numeric.       
36.   **tGravityAccMag\_Std**
	- Standard deviation of the calculated magnitude of the three-dimensional time domain measurements from accelerometer signal due to gravity.
	- Numeric.      
37.   **tBodyAccJerkMag\_Mean**
	- Mean of calculated magnitude of rate of change of the three-dimensional time domain measurements from accelerometer signal not due to gravity.
	- Numeric.      
38.   **tBodyAccJerkMag\_Std**
	- Standard deviation of the calculated magnitude of rate of change of the three-dimensional time domain measurements from accelerometer signal not due to gravity.
	- Numeric.       
39.   **tBodyGyroMag\_Mean**
	- Mean of calculated magnitude of the three-dimensional time domain measurements from gyroscope signal.
	- Numeric.       
40.   **tBodyGyroMag\_Std**
	- Standard deviation of the calculated magnitude of the three-dimensional time domain measurements from gyroscope signal.
	- Numeric.      
41.   **tBodyGyroJerkMag\_Mean**
	- Mean of calculated magnitude of rate of change of the three-dimensional time domain measurements from gyroscope signal.
	- Numeric.      
42.   **tBodyGyroJerkMag\_Std**
	- Standard deviation of the calculated magnitude of rate of change of the three-dimensional time domain measurements from gyroscope signal.
	- Numeric.       
43.   **fBodyAcc\_MeanX**
	- Mean of frequency domain measurements from accelerometer signal not due to gravity along X axis.
	- Numeric.       
44.   **fBodyAcc\_MeanY**
	- Mean of frequency domain measurements from accelerometer signal not due to gravity along Y axis.
	- Numeric.       
45.   **fBodyAcc\_MeanZ**
	- Mean of frequency domain measurements from accelerometer signal not due to gravity along Z axis.
	- Numeric.       
46.   **fBodyAcc\_StdX**
	- Standard deviation of frequency domain measurements from accelerometer signal not due to gravity along X axis.
	- Numeric.       
47.   **fBodyAcc\_StdY**
	- Standard deviation of frequency domain measurements from accelerometer signal not due to gravity along Y axis.
	- Numeric.       
48.   **fBodyAcc\_StdZ**
	- Standard deviation of frequency domain measurements from accelerometer signal not due to gravity along Z axis.
	- Numeric..       
49.   **fBodyAccJerk\_MeanX**
	- Mean of rate of change of frequency domain measurements from accelerometer signal not due to gravity along X axis.
	- Numeric.       
50.   **fBodyAccJerk\_MeanY**
	- Mean of rate of change of frequency domain measurements from accelerometer signal not due to gravity along Y axis.
	- Numeric.       
51.   **fBodyAccJerk\_MeanZ**
	- Mean of rate of change of frequency domain measurements from accelerometer signal not due to gravity along Z axis.
	- Numeric.       
52.   **fBodyAccJerk\_StdX**
	- Standard deviation of the rate of change of frequency domain measurements from accelerometer signal not due to gravity along X axis.
	- Numeric.       
53.   **fBodyAccJerk\_StdY**
	- Standard deviation of the rate of change of frequency domain measurements from accelerometer signal not due to gravity along Y axis.
	- Numeric.       
54.   **fBodyAccJerk\_StdZ**
	- Standard deviation of the rate of change of frequency domain measurements from accelerometer signal not due to gravity along Z axis.
	- Numeric.       
55.   **fBodyGyro\_MeanX**
	- Mean of frequency domain measurements from gyroscope signal along X axis.
	- Numeric.       
56.   **fBodyGyro\_MeanY**
	- Mean of frequency domain measurements from gyroscope signal along Y axis.
	- Numeric.       
57.   **fBodyGyro\_MeanZ**
	- Mean of frequency domain measurements from gyroscope signal along Z axis.
	- Numeric.       
58.   **fBodyGyro\_StdX**
	- Standard deviation of frequency domain measurements from gyroscope signal along X axis.
	- Numeric.       
59.   **fBodyGyro\_StdY**
	- Standard deviation of frequency domain measurements from gyroscope signal along Y axis.
	- Numeric.       
60.   **fBodyGyro\_StdZ**
	- Standard deviation of frequency domain measurements from gyroscope signal along Z axis.
	- Numeric.       
61.   **fBodyAccMag\_Mean**
	- Mean of calculated magnitude of the three-dimensional frequency domain measurements from accelerometer signal not due to gravity.
	- Numeric.       
62.   **fBodyAccMag\_Std**
	- Standard deviation of the calculated magnitude of the three-dimensional frequency domain measurements from accelerometer signal not due to gravity.
	- Numeric.      
63.   **fBodyAccJerkMag\_Mean**
	- Mean of calculated magnitude of rate of change of the three-dimensional frequency domain measurements from accelerometer signal not due to gravity.
	- Numeric.      
64.   **fBodyAccJerkMag\_Std**
	- Standard deviation of the calculated magnitude of rate of change of the three-dimensional frequency domain measurements from accelerometer signal not due to gravity.
	- Numeric.       
65.   **fBodyGyroMag\_Mean**
	- Mean of calculated magnitude of the three-dimensional frequency domain measurements from gyroscope signal.
	- Numeric.       
66.   **fBodyGyroMag\_Std**
	- Standard deviation of the calculated magnitude of the three-dimensional frequency domain measurements from gyroscope signal.
	- Numeric.      
67.   **fBodyGyroJerkMag\_Mean**
	- Mean of calculated magnitude of rate of change of the three-dimensional frequency domain measurements from gyroscope signal.
	- Numeric.      
68.   **fBodyGyroJerkMag\_Std**
	- Standard deviation of the calculated magnitude of rate of change of the three-dimensional frequency domain measurements from gyroscope signal.
	- Numeric.     

##Sources
In addition to sources cited in the body of this document, the following sources were also used in the creation of this document:

- Coursera Getting and Cleaning Data Course Project [https://class.coursera.org/getdata-033/human_grading/view/courses/975117/assessments/3/submissions](https://class.coursera.org/getdata-033/human_grading/view/courses/975117/assessments/3/submissions)
- Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
- UCI Machine Learning Repository - Human Activity Recognition Using Smartphones Data Set [http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
- README.txt, features\_info.txt from the project download [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
- DSS Community Site - Getting and Cleaning Data - 18 Months of CTA Advice - Part 6:Getting and Cleaning the Assignment [https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/](https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/)