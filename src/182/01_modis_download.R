#source("E:/modis_carpathian_mountains/src/00_set_environment.R")
source("/mnt/sd19006/data/processing_data/modis_carpathian_mountains/src/00_set_environment.R")


lap = path_modis_arc
MODISoptions(localArcPath = lap 
             , outDirPath = file.path(lap, "PROCESSED"))

# MODISoptions(localArcPath = lap 
#              , outDirPath = file.path(lap, "PROCESSED")
#              , outProj = "+init=epsg:32634") 

clc = getCollection("MYD13Q1") 
# tls = getTile() 

shp = shapefile(paste0(path_vectors, "carpathian_mountains.shp"))
shp = spTransform(shp, CRS("+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"))
# mapview::mapview(shp)

# hdf = getHdf("MYD13Q1" 
#              , begin = as.Date("2002-07-01") 
#              , end = as.Date("2002-07-31") 
#              , tileH = 19, tileV = 4) 
# hdf 

# sds = getSds(hdf[["MYD13Q1.006"]][1]) 
# sds 

# ?runGdal 
tfs = runGdal("MYD13Q1" 
              , collection = clc 
              , begin = as.Date("2001-12-01") 
              # , end = as.Date("2017-12-31") 
              # , tileH = 19, tileV = 4 
              , extent = shp
              , SDSstring = "101000000011" 
              , job = "carpathian_mountains") 
tfs 




