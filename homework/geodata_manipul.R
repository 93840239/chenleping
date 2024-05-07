#HEADER-----------------------------------------
#
#Author:  Leping  Chen
#Copyright
#Email:  2932348481@qq.com
#Date:  2024.4.25
#Script  Name: geodata manipul
#Script  Description: 1.沿着Doubs河设置2公里的缓冲区，并从地图上截取，用qgisprocess软件包提取每个点的集水区和坡度的光栅值。
#2.将提取的数据与Doubs数据集中的其他环境因素合并形成数据框，最后将数据框传输到包含几何列的sf对象。
#
#Setup-------------------------------------------

# 沿着Doubs河设置宽度为2公里的缓冲区
# 下载并加载包
install.packages("terra")
install.packages("sf")
library(terra)
library(sf)

# 读入数据
doubs_dem <- terra::rast("C://Users//11/Desktop//data//map.tif")
doubs_river <- sf::st_read("C://Users//11//Desktop//data//2024.4.27//river.shp")
doubs_points <- sf::st_read("C://Users//11//Desktop//data//2024.4.27//points2.shp")


# 对河流和数据点矢量数据的再投影
doubs_river_utm <- st_transform(doubs_river,32631)
doubs_points_utm <- st_transform(doubs_points,32631)

# 创造并可视化缓冲区
doubs_river_buff <- st_buffer(doubs_river_utm,dis=2000)
plot(st_geometry(doubs_river_buff),axes = TRUE)

library(ggplot2)
ggplot() + geom_sf(data = doubs_river_buff) #创建一个基于地理坐标系的缓冲区图形

# 截取缓冲区覆盖的高程数据
# 栅格数据重投影
terra::crs(doubs_dem) # 获取高程数据参考坐标系
utm_crs <- "EPSG:32631" # 设置参考坐标系
doubs_dem_utm <- terra::project(doubs_dem,utm_crs) # 进行重投影
terra::crs(doubs_dem_utm) # 检查坐标系

# 对缓冲区内的高程数据进行剪裁和掩膜
# 裁剪高程数据到 Doubs 河缓冲区范围内
doubs_dem_utm_cropped <- crop(doubs_dem_utm, doubs_river_buff)
# 掩膜化裁剪后的高程数据，只保留 Doubs 河缓冲区范围内的数据
doubs_dem_utm_masked = mask(doubs_dem_utm_cropped,doubs_river_buff)
# 可视化截取的缓冲区范围内的高程数据
plot(doubs_dem_utm_masked, axes = TRUE)

# 提取集水区面积和坡度值
# 下载qgisprocess包，将R与QGIS连接起来。在这之前先下载QGIS、SAGA、GRASS GIS软件，并在系统变量中设置R_QGISPROCESS_PATH路径，重启计算机以使添加的路径生效
remotes::install_github("r-spatial/qgisprocess")  #下载qgisprocess包
library(qgisprocess)
qgis_configure() # 初始化qgisprocess
qgis_plugins() # 查看可用插件
# 使用 qgis_search_algorithms() 函数搜索含有 "wetness" 关键词的算法，择前两个算法并提取提供者和算法名称
qgis_search_algorithms("wetness") |>
  dplyr::select(provider_title,algorithm) |>
  head(2)     
# 根据上一步搜索到的算法sagang:sagawetnessindex，根据高程数据计算地形的湿度指数，其中包括集水区面积和坡度
topo_total = qgisprocess::qgis_run_algorithm(
  alg = "sagang:sagawetnessindex",
  DEM = doubs_dem_utm_masked,
  SLOPE_TYPE = 1,
  SLOPE = tempfile(fileext = ".sdat"),
  AREA = tempfile(fileext = ".sdat"),
  .quiet = TRUE)  
# 从 topo_total 中选择 "AREA" 和 "SLOPE" 这两个栅格图层，然后将它们展平为向量，最后将结果转换为栅格对象。
topo_select <- topo_total[c("AREA","SLOPE")] |>
  unlist() |>
  rast() 
# 将缓冲区栅格对象与集水区面积、坡度栅格对象合并
names(topo_select) = c("carea","cslope") #给topo_select的栅格图层命名
origin(topo_select) = origin(doubs_dem_utm_masked) #将要合并的栅格对象设置为原点一致
topo_char = c(doubs_dem_utm_masked,topo_select) #合并两栅格对象
plot(topo_char)
# 从topo_char栅格对象中提取doubs_points_utm处的值，即doubs河各点集水区面积和坡度的值
topo_env <- terra::extract(topo_char,doubs_points_utm,ID = FALSE)
topo_env_2 <- topo_env[,2:3]

# 将提取的doubs河每个点集水区面积和坡度数据与doubs河其他环境变量合并成一个数据框
# 载入doubs河数据
library(ade4)
data(doubs)
doubs
water_env <- doubs$env # 提取环境变量
# 将环境变量与集水区面积、坡度数据合并
doubs_env = cbind(doubs_points_utm,topo_env,water_env)
# 将doubs_env保存为shp文件
sf::st_write(doubs_env,paste0("C:/Users/11/Desktop/data","/","doubs_env.shp"))
