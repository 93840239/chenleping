#HEADER-----------------------------------------
#
#Author:  Leping  Chen
#Copyright
#Email:  2932348481@qq.com
#Date:  2024.4.15
#Script  Name:  'data_exploration'
#Script  Description:
#
#Setup-------------------------------------------
# 加载需要用的包
library(reticulate)
library(RPostgreSQL)
library(DBI)
library(ade4)
library(rdataretriever)
library(corrplot)
data("doubs")

# 数据预处理
env_data <- doubs$env
 #删除缺失数据
env_data<-na.omit(env_data)

#求相关系数
M<-cor(env_data)
M

#画成对散点图
pairs(env_data)

#因为变量之间的相关性特别高例如alt和dfs的相关系数达-0.94，大部分成对变量之间的相关性
#超过0.6，因此环境变量之间具有多重共线性。


# 加载包
library(corrplot)
library(vegan) 
library(olsrr)

fish_data <- doubs$fish
species <- doubs$species
# 可视化相关系数矩阵
corrplot(cor(env_data))
corrplot(cor(fish_data))
corrplot(cor(cbind(env_data,fish_data)))

# 进行RDA分析
env.z <- subset(env_data, select = -dfs)
spe.rda<-rda(fish_data~.,env.z)
summary(spe.rda)

screeplot(spe.rda)
coef(spe.rda) # canonical coefficients
# R^2 retreived from the rda result
R2 <- RsquareAdj(spe.rda)$r.squared # unadjusted R^2 
R2 
R2adj <- RsquareAdj(spe.rda)$adj.r.squared # adjusted R^2
R2adj 

# plot RDA
# Triplot: sites, response variables and explanatory variables
# Scaling 1
plot(spe.rda, scaling=1, main="scaling 1 - wa scores")
spe.sc <- scores(spe.rda, choices=1:2, scaling=1, display="sp")
arrows(0,0,spe.sc[,1], spe.sc[,2], length=0, lty=1, col='red')

# Scaling 2
plot(spe.rda, main="scaling 2 - wa scores")
spe2.sc <- scores(spe.rda, choices=1:2, display="sp")  
arrows(0,0,spe2.sc[,1], spe2.sc[,2], length=0, lty=1, col='red')

# variance inflation factors in the RDA
vif.cca(spe.rda)



# Forward selection using ordistep (accepts models with lower adjusted R2)
fwd.sel <- ordiR2step(rda(fish_data~1,env_data), # lower model limit (simple)
                      scope = formula(spe.rda), # upper model limit (the "full" model)
                      direction = "forward",
                      R2scope = TRUE, # not surpass the "full" model's R2
                      pstep = 1000,
                      trace = TRUE) # see the selection process
# Test of RDA result
anova.cca(spe.rda, step=1000)


