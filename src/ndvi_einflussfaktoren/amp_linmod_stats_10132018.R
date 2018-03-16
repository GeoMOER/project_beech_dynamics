rm(list=ls())

# -------------------- multiple lin model -----------------------------
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
path_max = paste0(path_data, "/crop_area/max")
path_min = paste0(path_data, "/crop_area/min")
path_amp = paste0(path_data, "/crop_area/amp")
path_calc = paste0(path_data, "/crop_area/Ergebnisse")
# --------------------------------------------------------------------------------
setwd(path_crop)

# -----------------------------------------------------------
# ---------- dynamic data
# -> ndvi preparation

# ndvi_max <- list.files(paste0(path_max),
#                        pattern = glob2rx("*.tif"),
#                        full.names = TRUE)
# ndvi <- stack(ndvi_max)

# ----------
# ndvi_min <- list.files(paste0(path_min),
#                        pattern = glob2rx("*.tif"),
#                        full.names = TRUE)
# ndvi <- stack(ndvi_min)

# ----------
ndvi_amp <- list.files(paste0(path_amp),
                       pattern = glob2rx("*.tif"),
                       full.names = TRUE)
ndvi <- stack(ndvi_amp)

# ---------- 
# static variables
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
# ---------- create dataframe

# ----------
# ---------- static data
df_x1 <- as.data.frame(dem)
df_x2 <- as.data.frame(slope)
df_x3 <- as.data.frame(aspect)
df_x4 <- as.data.frame(treecover)
df_x5 <- as.data.frame(dist_streets)
# -------- multiple lin mod amplitude
# -------- loop 

#------- split data & lin model + predict data

library(caret)

cv <- lapply(seq(1:15), function(i){
  
  i = 1
  df_y <- as.data.frame(ndvi[[i]])
  df_x6 <- as.data.frame(prec[[i]]) 
  
  df <- data.frame(y = df_y, x1 = df_x1, x2 = df_x2, x3 = df_x3, x4 = df_x4, x5 = df_x5, x6 = df_x6)
  df_scale <- scale(df)
  df_scale1 <- as.data.frame(df_scale)
  names <- c("y","dem","slope","aspect","treecover","distance","precipitation")
  names(df_scale1) <- names
  spl <- createDataPartition(df_scale1$y, p = 0.5, list = FALSE)
  df2trai <- df_scale1[spl,]
  df2train <- df2trai[1:5891587,]
  df2test <- df_scale1[-spl,]
  # --------
  # residuals
  lmod_test <- lm(distance ~ dem, data = df2train)
  lmod_res <- lm(y ~ lmod_test$residuals, data =df2train)
  pred_res <- predict(lmod_res, df2test)
  lm_res <- lm(df2test$y ~ pred_res)
  
  lmod_2003 <- lm(y ~ dem + slope + aspect + treecover + distance + precipitation, data = df2train)
  lmod_dem <- lm(y ~ dem, data = df2train)
  lmod_slope <- lm(y ~ slope, data = df2train)
  lmod_aspect <- lm(y ~ aspect, data = df2train)
  lmod_treecover <- lm(y ~ treecover, data = df2train)
  lmod_distance <- lm(y ~ distance, data = df2train)
  lmod_precipitation <- lm(y ~ precipitation, data = df2train)
  # --------
  pred <- predict(lmod_2003, df2test)
  pred_dem <- predict(lmod_dem, df2test)
  pred_slope <- predict(lmod_slope, df2test)
  pred_aspect <- predict(lmod_aspect, df2test)
  pred_treecover <- predict(lmod_treecover, df2test)
  pred_distance <- predict(lmod_distance, df2test)
  pred_precipitation <- predict(lmod_precipitation, df2test)
  # --------
  lm_pred <- lm(df2test$y ~ pred)
  lm_dem = lm(df2test$y ~ pred_dem)
  lm_slope = lm(df2test$y ~ pred_slope)
  lm_aspect = lm(df2test$y ~ pred_aspect)
  lm_treecover = lm(df2test$y ~ pred_treecover)
  lm_distance = lm(df2test$y ~ pred_distance)
  lm_precipitation = lm(df2test$y ~ pred_precipitation)
  # --------
  predict_rsquared <- summary(lm_pred)$r.squared
  dem_rsquared <- summary(lm_dem)$r.squared
  slope_rsquared <- summary(lm_slope)$r.squared
  aspect_rsquared <- summary(lm_aspect)$r.squared
  treecover_rsquared <- summary(lm_treecover)$r.squared
  distance_rsquared <- summary(lm_distance)$r.squared
  precipitation_rsquared <- summary(lm_precipitation)$r.squared
  res_rsquared <- summary(lm_res)$r.squared
  
  return(data.frame(Value = c(predict_rsquared,dem_rsquared,slope_rsquared,aspect_rsquared,treecover_rsquared, distance_rsquared, precipitation_rsquared, res_rsquared
  )))
}
)

# --------- Create, name and save returns
names <- data.frame(Name = c("predict r²","dem r²","slope r²","aspect r²","treecover r²","distance r²","precipitation r²", "distance ~ dem residuals r² "))
stats_amplitude <- data.frame(cv)

ColName <- c("2002","2003","2004","2005","2006","2007","2008","2009",
             "2010","2011","2012","2013","2014","2015","2016")
RowNames = c("predict r²","predict res r²","dem r²","slope r²","aspect r²","treecover r²","distance r²","precipitation r²", "residuals r²")

names(stats_amplitude) <- ColName
rownames(stats_amplitude) <-RowNames

setwd(path_calc)
saveRDS(stats_amplitude, "linmod_amplitude.RDS")

# -----------------  

# summary(pred_dem)
# summary(pred_dist)
# summary(pred_prec)
# 
# summary(lm_dem)
# summary(lm_dist)
# summary(lm_prec)
# 
# 
# plot(pred, df2train_2$y)
# lmod_pred <- lm(pred ~ df2train_2$y, data=lm_val) 
# summary(lmod_pred)

#mod_pred <- gls(ytrain ~ pred_lm, data=lm_val)
