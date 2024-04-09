#HEADER-----------------------------------------
#
#Author:  Leping  Chen
#Copyright
#Email:  2932348481@qq.com
#Date:  2024.4.9
#Script  Name:  'the fourth homework'
#Script  Description: creating a regression model of mpg as target and others as features (from a built-in dataset of mtcars) using random forest algorithm with caret package
#
#Setup-------------------------------------------
cat("\014") # Clears the console
rm(list = ls()) # Remove all variables

# data preparation
data(mtcars)

# data pre-process
# 1)Standardization of data
str(mtcars)
df <- na.omit(mtcars)
df[3:ncol(mtcars)] <- scale(df[3:ncol(df)]) # scale all but target
head(df)
# 2)conversion to dummy (binary) variables
install.packages("fastDummies")
library(fastDummies)
df <- fastDummies::dummy_cols(df, select_columns ="vs" ,remove_first_dummy = TRUE,  
                              remove_selected_columns = TRUE)

# Data segmentation and cross validation
install.packages("caret")
library(caret)
set.seed(100)
trainindex <- createDataPartition(df$mpg,p=0.7,list = FALSE)
train_data <- df[trainindex,]
test_data <- df[-trainindex,]

# feature selection and visualization
install.packages("randomForest")
install.packages("ggplot2")
library(randomForest)
library(ggplot2)

rate<-1 #设置模型误判率向量初始值
n <- nrow(train_data)
for(i in 1:(n-1))
{
  set.seed(1234)
  rf_train <- randomForest(as.factor(train_data$mpg)~.,data=train_data,
                         mtry=i,importance=T,proximity=T,ntree=1000)
  rate[i]<- mean(rf_train$err.rate)   #计算基于OOB数据的模型误判率均值
}
plot(rf_train)

# Variable importance
(varimp.rf_train <- caret::varImp(rf_train))

# evaluate the model
test_data$rf_train.pred <- predict(rf_train, newdata = test_data)
install.packages("Metrics")
library(Metrics)
Metrics::rmse(test_data$mpg, test_data$rf_train.pred)
