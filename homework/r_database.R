#HEADER-----------------------------------------
#
#Author:  Leping  Chen
#Copyright
#Email:  2932348481@qq.com
#Date:  2024.4.15
#Script  Name:  r_database
#Script  Description:
#
#Setup-------------------------------------------

# 加载包
library(reticulate)
library(RPostgreSQL)
library(DBI)
library(ade4)
library(rdataretriever)
data("doubs")

# 连接PostgreSQL数据库
con <- dbConnect(RPostgres::Postgres(), dbname = "postgres", port = 5432, user = "postgres", password = "720816")

# 将数据写入数据库
dbWriteTable(con, "env", doubs$env,overwrite =T)
dbWriteTable(con, "fish", doubs$fish,overwrite =T)
dbWriteTable(con, "xy", doubs$xy,overwrite =T)
dbWriteTable(con, "species", doubs$species,overwrite =T)

# 从数据库中读入数据
dbReadTable(con, "env")

#展示上传的表
dbListTables(con)

#关闭连接
dbDisconnect(con)
