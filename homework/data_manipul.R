#HEADER-----------------------------------------
#
#Author:  Leping  Chen
#Copyright
#Email:  2932348481@qq.com
#Date:  2024.3.24
#Script  Name:  data_manipul.R
#Script  Description: 
#
#Setup-------------------------------------------
cat("\014") # clear the console
rm(list = ls()) # remove all variables

# import the data and creat a data frame
emp.data<- data.frame( #Creating data frame    
  name = c("Wang","Liu","Chen","Zhang","Wei"),    
  salary = c(623.3,915.2,611.0,729.0,843.25),     
  start_date = as.Date(c("2012-01-01", "2013-09-23", "2014-11-15", "2014-05-11","2015-03-27")),  
  dept = c("Operations","IT","HR","IT","Finance"),    
  stringsAsFactors = FALSE    
)  
emp.data

# save the dataframe as a xlsx file

# install the "xisx" package
install.packages("rJava")
install.packages("xlsxjars")
library("rJava")
install.packages("xlsx")
library("xlsx")

# save the data in a xlsx file
write.xlsx(emp.data, file = "data/employee.xlsx", 
           col.names=TRUE, 
           row.names=FALSE, # if TRUE, get new X. column
           sheetName="Sheet1",
           append = TRUE)  

# import and save data as a csv file
excel_data<- read.xlsx("data/employee.xlsx",sheetName = "Sheet1")  
print(excel_data) 
write.csv(excel_data,"data/exployee.csv")

# inspect data structure
csv_data <- read.csv("data/exployee.csv")  
print(csv_data) 
head(csv_data)
str(csv_data)

# check whether a column or row has missing data
is.na(csv_data)

# select a column
csv_data_salary <- csv_data$salary

# use mutate() to create a new column
install.packages("dplyr")  
library(dplyr)
csv_data %>%
  filter(!is.na(salary)) %>%
  mutate(salary_qianyuan = salary / 1000) %>%
  head()

# transform a wider table to a long format
library("tidyverse")
install.packages("readx1")
datalong <- gather(csv_data,key="personal characters",value="value",salary:dept)

# Data visualization with ggplot2
surveys <- data.frame(name = c(1:10),
                      weight = c(11:20))

ggplot(data = surveys)
ggplot(data = surveys, 
       aes(x = name, y = weight)) # define aes
ggplot(data = surveys, 
       aes(x = name, y = weight)) +
  geom_point() # dot plots

