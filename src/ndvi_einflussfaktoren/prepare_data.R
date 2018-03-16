# ----------------
# ----------------
# preparing all data for analysis
#   dem (aspect, slope)
#   ndvi (min, max, amplitude)
#   treecover
#   distance to roads
#   rainfall sums
# project data to proj4string 
#   "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
# clip data to study area
# aggregate to dem resolution
# ----------------
# ----------------

library(raster)
library(rgdal)

# Set pathes -------------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  filepath_base = "F:/Uni/Geo/_MA/environmental_observations"
} else {
  filepath_base = "/mnt/sd19006/data/processing_data/modis_carpathian_mountains/data_small_test"
}

# Basic data path
path_data = paste0(filepath_base, "/data/moer-envobs/study_area")
path_maryland = paste0(filepath_base, "/data/moer-envobs/maryland")
path_clip = paste0(filepath_base, "/data/moer-envobs/clip")
path_dem = paste0(filepath_base, "/data/ASTGTM2_N45E024/")
path_deseasoned = paste0(path_data, "/modis_deseasoned")
path_aggreg  = paste0(path_data, "/temporal_aggregated_modis_proj")
path_crop = paste0(path_data, "/crop_area")
path_time = paste0(path_data, "/modis_deseasoned")
path_ndvi = paste0(path_data, "/crop_area/ndvi_year")
# --------------------------------------------------------------------------------

# read asterDEM
# ----------------
dem = list.files(paste0(path_clip),
                 pattern = glob2rx("*_2.tif"), 
                 full.names = TRUE)
geo <- stack(dem)

# Unesco World Herritage Shape
# ----------------
setwd(path_clip)

unesco <- readOGR("clip_worldheritage_final.shp")

# projection to ndvi ->  proj4string : "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"                  
# ----------------
unesco2 <- spTransform(unesco, CRS("+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"))

writeOGR(unesco2, dsn = path_data, driver = "ESRI Shapefile", layer = "unesco_testpolygone2")
writeRaster(demN45_2, "demN45_2.tif",dsn = path_data)

# slope and aspect
# ----------------
slopeN45 <- terrain(demN45_2, filename = "slopeN45", opt = "slope", neighbors = 8, unit = "degrees", overwrite = TRUE)
aspectN45 <- terrain(demN45_2, filename = "aspectN45", opt = "aspect", neighbors = 8, unit = "degrees", overwrite = TRUE)

writeRaster(slopeN45, "slopeN45_2.tif",dsn = path_data)
writeRaster(aspectN45, "aspectN45_2.tif",dsn = path_data)

# test
# ----------------
dem = list.files(paste0(path_data),
                 pattern = glob2rx("*.tif"), 
                 full.names = TRUE)
dem <- stack(dem)
proj4string(dem)

# stack ndvi files - > proj4string : "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
# ----------------
ndvi_files <- list.files(paste0(path_time), 
                        pattern = glob2rx("MYD13Q1.A2003*.tif"), 
                        full.names = TRUE)
ndvi_rst <- stack(ndvi_files)
ndvi <- ndvi_rst
max_2003 <- max(ndvi_rst)
ndvi_deseasoned_crop <- projectRaster(from=ndvi, 
                    to=dem,
                    method="ngb", 
                    filename="ndvi_day100_crop.tif", 
                    overwrite = T)

# testplot
# ----------------
# plot(ndvi_deseasoned_crop[[1]])
# plot(unesco2, add = TRUE)



# project, clip & aggregate all data
# ----------------
dem = list.files(paste0(path_data),
                 pattern = glob2rx("*.tif"), 
                 full.names = TRUE)

dem <- stack(dem)
proj4string(dem)

# stack ndvi files - > proj4string : "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
ndvi_files <- list.files(paste0(path_deseasoned), 
                         pattern = glob2rx("*.tif"), 
                         full.names = TRUE)

ndvi_rst <- stack(ndvi_files)

ndvi_deseasoned_crop <- projectRaster(from=ndvi_rst, 
                                      to=dem,
                                      method="ngb", 
                                      filename="ndvi25__deseasoned_crop.tif", 
                                      overwrite = T) 

# stack ndvi files - > proj4string : "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
ndvi_year <- list.files(paste0(path_aggreg), 
                         pattern = glob2rx("*.tif"), 
                         full.names = TRUE)

ndvi_year <- stack(ndvi_year)

# NDVI
# ------------- 
projectRaster(from=ndvi_year[[1]], 
                                to=dem,
                                method="ngb", 
                                filename="ndvi02_crop.tif", 
                                overwrite = T) 


projectRaster(from=ndvi_year[[2]], 
                                to=dem,
                                method="ngb", 
                                filename="ndvi03_crop.tif", 
                                overwrite = T) 


projectRaster(from=ndvi_year[[3]], 
                                to=dem,
                                method="ngb", 
                                filename="ndvi04_crop.tif", 
                                overwrite = T) 


projectRaster(from=ndvi_year[[4]], 
                                to=dem,
                                method="ngb", 
                                filename="ndvi05_crop.tif", 
                                overwrite = T) 


projectRaster(from=ndvi_year[[5]], 
                                to=dem,
                                method="ngb", 
                                filename="ndvi06_crop.tif", 
                                overwrite = T) 


projectRaster(from=ndvi_year[[6]], 
                                to=dem,
                                method="ngb", 
                                filename="ndvi07_crop.tif", 
                                overwrite = T) 


projectRaster(from=ndvi_year[[7]], 
                                to=dem,
                                method="ngb", 
                                filename="ndvi08_crop.tif", 
                                overwrite = T) 


projectRaster(from=ndvi_year[[8]], 
              to=dem,
              method="ngb", 
              filename="ndvi09_crop.tif", 
              overwrite = T) 


projectRaster(from=ndvi_year[[9]], 
              to=dem,
              method="ngb", 
              filename="ndvi10_crop.tif", 
              overwrite = T) 


projectRaster(from=ndvi_year[[10]], 
              to=dem,
              method="ngb", 
              filename="ndvi11_crop.tif", 
              overwrite = T) 


projectRaster(from=ndvi_year[[11]], 
              to=dem,
              method="ngb", 
              filename="ndvi12_crop.tif", 
              overwrite = T) 


projectRaster(from=ndvi_year[[12]], 
              to=dem,
              method="ngb", 
              filename="ndvi13_crop.tif", 
              overwrite = T) 


projectRaster(from=ndvi_year[[13]], 
              to=dem,
              method="ngb", 
              filename="ndvi14_crop.tif", 
              overwrite = T) 


projectRaster(from=ndvi_year[[14]], 
              to=dem,
              method="ngb", 
              filename="ndvi15_crop.tif", 
              overwrite = T) 


projectRaster(from=ndvi_year[[15]], 
              to=dem,
              method="ngb", 
              filename="ndvi16_crop.tif", 
              overwrite = T) 


# DEM
# ----------------
dem = list.files(paste0(path_data),
                 pattern = glob2rx("*.tif"), full.names = TRUE)

geo <- stack(dem[2],dem[3],dem[1])
geo[[1]]

proj4string(geo)
proj4string(unesco2)

plot(geo[[1]])
plot(ndvi_crop[[1]], add = TRUE)

plot(unesco, add = TRUE)


# Maryland
# ----------------

maryland_files = list.files(paste0(path_maryland),
                            pattern = glob2rx("*.tif"), 
                            full.names = TRUE)

maryland_1 = raster(maryland_files[[1]])
maryland_2 = raster(maryland_files[[2]])
maryland_3 = raster(maryland_files[[3]])
maryland_4 = raster(maryland_files[[4]])
maryland_5 = raster(maryland_files[[5]])
maryland_6 = raster(maryland_files[[6]])
setwd(path_clip)

projectRaster(from=maryland_1, 
              to=dem,
              method="ngb", 
              filename="Hansen_GFC-2016-v1.4_datamask_50N_020E_projection_crop.tif", 
              overwrite = T) 

projectRaster(from=maryland_2, 
              to=dem,
              method="ngb", 
              filename="Hansen_GFC-2016-v1.4_first_50N_020E_projection_crop.tif", 
              overwrite = T) 

projectRaster(from=maryland_3, 
              to=dem,
              method="ngb", 
              filename="Hansen_GFC-2016-v1.4_gain_50N_020E_projection_crop.tif", 
              overwrite = T) 

projectRaster(from=maryland_4, 
              to=dem,
              method="ngb", 
              filename="Hansen_GFC-2016-v1.4_last_50N_020E_projection_crop.tif", 
              overwrite = T) 

projectRaster(from=maryland_5, 
              to=dem,
              method="ngb", 
              filename="Hansen_GFC-2016-v1.4_lossyear_50N_020E_projection_crop.tif", 
              overwrite = T) 

projectRaster(from=maryland_6, 
              to=dem,
              method="ngb", 
              filename="Hansen_GFC-2016-v1.4_treecover2000_50N_020E_projection_crop.tif", 
              overwrite = T) 

r <- raster("Hansen_GFC-2016-v1.4_treecover2000_50N_020E_projection_crop.tif")
# plot(r)
# plot(unesco, add = TRUE)

ndvi_crop <- list.files(paste0(path_clip), 
                         pattern = glob2rx("*crop.tif"), 
                         full.names = TRUE)

ndvi_crop <- stack(ndvi_crop)

writeRaster(ndvi_crop, "ndvi_crop_stack.tif", dsn = path_clip)


# unesco world herritage - testpolygone
# ----------------
unesco <- readOGR("unesco_testpolygone2.shp")
proj4string(unesco)
# ----------------
# ----------------
crop <- list.files(paste0(path_crop), 
                   pattern = glob2rx("*.tif"), 
                   full.names = TRUE)
# ---------- layers in topo c(dem, slope, aspect) -----------
prec <- stack(crop[5])
dem <- raster(crop[2])
aspect <- raster(crop[1])
slope <- raster(crop[6])
treecover <- raster(crop[4])
dist_streets <- raster(crop[3])



aspect <- raster("aspect_crop.tif")
aspect_re <- cos((aspect*pi)/180)

