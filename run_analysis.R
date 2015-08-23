library(plyr)

#Read and combine the training and testing X data sets
trainx <- read.delim("train\\X_train.txt", sep="", header=FALSE)
testx <- read.delim("test\\X_test.txt", sep="", header=FALSE)
allx <- rbind(trainx, testx)

#Read and combine the training and testing Y data sets
trainy <- read.delim("train\\y_train.txt", sep="", header=FALSE)
testy <- read.delim("test\\y_test.txt", sep="", header=FALSE)
ally <- rbind(trainy, testy)

#Read and combine the training and testing subject lists
subjecttrain <- read.delim("train\\subject_train.txt", sep="", header=FALSE)
subjecttest <- read.delim("test\\subject_test.txt", sep="", header=FALSE)
subjectall <- rbind(subjecttest, subjecttrain)

#Read the activity labels and change the column names to allow merging with the data later
activitylabels <- read.table("activity_labels.txt", header=FALSE)
colnames(activitylabels) <- c('activityid','activity')

#Read the features list and label the columns with human readable strings
features <- read.table("features.txt", header=FALSE)
colnames(allx) <- features[,2]

#Merge the X and Y data sets
final <- cbind(ally, allx)

#Merge the subject list with the data sets
final <- cbind(subjectall, final)

#Setup the column names for a merge with activity types
colnames(final)[1:2] <- c('subjectid', 'activityid')

#Get the colum indexes to include only mean and standard deviation columns
meanstdCols <- cols <- unique(sort(c(as.numeric(grep("-mean()", colnames(final),fixed=TRUE)),as.numeric(grep("-std()", colnames(final),fixed=TRUE)))))

#Remove all columns that don't include mean or standard deviation. 
final <- final[,c(1,2,meanstdCols)]

#Merge in the activity labels for each row
final <- merge(final, activitylabels, by="activityid")

#Rearrange the data set to move activity column to the front
final <- final[c("subjectid", "activityid", "activity", names(subset(final, select=-c(activityid,subjectid,activity))))]

#Generate a new data set with the mean of each column by subject and activity id
final2 <- aggregate(final[, c(-1,-2,-3)], list(final$subjectid, final$activityid), mean)
colnames(final2)[1:2] <- c('subjectid', 'activityid')
final2 <- merge(final2, activitylabels, by="activityid")
final2 <- final2[c("subjectid", "activityid", "activity", names(subset(final2, select=-c(activityid,subjectid,activity))))]
