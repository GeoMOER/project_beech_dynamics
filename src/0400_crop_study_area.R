#' Crop to study area
#'
rm(list=ls())
# Load environment
print("Reading libraries and settings...")
if(Sys.info()["sysname"] == "Windows"){
  # source("E:/modis_carpathian_mountains/src/00_set_environment.R")
  # source("/mnt/sd19006/data/processing_data/modis_carpathian_mountains/src/00_set_environment.R")
  # source("D:/BEN/ML/project_beech_dynamics/src/00_set_environment.R")
  source("C:/Users/tnauss/permanent/edu/msc-phygeo-environmental-observations/git/project_beech_dynamics/src/00_set_environment.R")
  cores = 3
} else {
  source("/mnt/sd19006/data/processing_data/modis_carpathian_mountains/src/00_set_environment.R")
  cores = 16
}
lib = c("snow", "beechForestDynamics", "doParallel", "raster", "rgdal", "GSODTools")

# Define parallelization information
cores = 3
cl = parallel::makeCluster(cores)
doParallel::registerDoParallel(cl)

#### Crop to study area
sa = readOGR(paste0(path_vectors, "/carpathian_mountains_sinusoidal_rumania.shp"))
# mapview::mapview(sa)

# MODIS filled time series
if(length(showConnections()) == 0){
  cl = parallel::makeCluster(cores)
  doParallel::registerDoParallel(cl)
}
mftfns = list.files(path_modis_filled_timeseries, pattern = glob2rx("*.tif"),
                    full.names = TRUE)

outpath = paste0(path_study_area, subpath_modis_filled_timeseries)
if(!dir.exists(outpath)){
  dir.create(outpath, recursive = TRUE)
}
outfns = paste0(outpath, "/", basename(mftfns))

mft = stack(mftfns)

foreach(i = raster::unstack(mft), j = as.list(outfns), 
        .packages = lib, .export = ls(envir = globalenv())) %dopar% {
          mft_sa = crop(i, sa)
          writeRaster(mft_sa, filename = j, format = "GTiff", overwrite = TRUE)
        }


# MODIS deseasoned
if(length(showConnections()) == 0){
  cl = parallel::makeCluster(cores)
  doParallel::registerDoParallel(cl)
}
mftfns = list.files(path_modis_deseasoned, pattern = glob2rx("*.tif"),
                    full.names = TRUE)

outpath = paste0(path_study_area, subpath_modis_deseasoned)
if(!dir.exists(outpath)){
  dir.create(outpath, recursive = TRUE)
}
outfns = paste0(outpath, "/", basename(mftfns))

mft = stack(mftfns)

foreach(i = raster::unstack(mft), j = as.list(outfns), 
        .packages = lib, .export = ls(envir = globalenv())) %dopar% {
          mft_sa = crop(i, sa)
          writeRaster(mft_sa, filename = j, format = "GTiff", overwrite = TRUE)
        }



# MODIS mk trends
if(length(showConnections()) == 0){
  cl = parallel::makeCluster(cores)
  doParallel::registerDoParallel(cl)
}
mftfns = list.files(path_modis_mktrend, pattern = glob2rx("*.tif"),
                    full.names = TRUE)

outpath = paste0(path_study_area, subpath_modis_mktrend)
if(!dir.exists(outpath)){
  dir.create(outpath, recursive = TRUE)
}
outfns = paste0(outpath, "/", basename(mftfns))

mft = stack(mftfns)

foreach(i = raster::unstack(mft), j = as.list(outfns), 
        .packages = lib, .export = ls(envir = globalenv())) %dopar% {
          mft_sa = crop(i, sa)
          writeRaster(mft_sa, filename = j, format = "GTiff", overwrite = TRUE)
        }


# MSWEP
if(length(showConnections()) == 0){
  cl = parallel::makeCluster(cores)
  doParallel::registerDoParallel(cl)
}
mftfns = list.files(path_mswep_temporal_aggregated_modis, pattern = glob2rx("*.tif"),
                    full.names = TRUE)

outpath = paste0(path_study_area, "/mswep_temporal_aggregated_modis_proj")
if(!dir.exists(outpath)){
  dir.create(outpath, recursive = TRUE)
}
outfns = paste0(outpath, "/", basename(mftfns))

mft = stack(mftfns)

foreach(i = raster::unstack(mft), j = as.list(outfns), 
        .packages = lib, .export = ls(envir = globalenv())) %dopar% {
          mft_sa = crop(i, sa)
          writeRaster(mft_sa, filename = j, format = "GTiff", overwrite = TRUE)
        }





if (cores > 1L)
  parallel::stopCluster(cl)
