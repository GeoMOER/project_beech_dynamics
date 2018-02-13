#' Compute MODIS NDVI time series trends
#'
#' @description
#' Compute time series trends for MODIS NDVI time series. MODIS datasets are
#' split into tiles to allow computation in limited working memory environments.
#'
#' Directory structure is as follows:
#' <some individual path>/modis/MODIS_ARC
#' <some individual path>/modis/tiles
#'                               |
#'                               |-c0001-0511_r0001-0522
#'                                          |
#'                                          |-modis_quality_checked
#'                                          |
#'                                          |-modis_outlier_checked
#'                                          |
#'                                          |-...
#'                               |-...
#'

# Load environment
# source("E:/modis_carpathian_mountains/src/00_set_environment.R")
# source("/mnt/sd19006/data/processing_data/modis_carpathian_mountains/src/00_set_environment.R")
source("C:/Users/tnauss/permanent/edu/msc-phygeo-environmental-observations/git/project_beech_dynamics/src/00_set_environment.R")
lib = c("beechForestDynamics", "doParallel", "raster", "rgdal", "GSODTools")


# Define parallelization information
cores = 2
cl = parallel::makeCluster(cores)
doParallel::registerDoParallel(cl)


## Subset MODIS into tiles
if (!dir.exists(path_modis_tiles))
  dir.create(path_modis_tiles, recursive = TRUE)

p = c("NDVI.tif$")
ndvi_rst = raster::stack(list.files(path_modis_prj, pattern = p, full.names = TRUE))
tileRaster(raster = ndvi_rst, tilenbr = c(12,10), overlap = 10, outpath = path_modis_tiles)

p = c("composite_day_of_the_year.tif$")
doy_rst = raster::stack(list.files(path_modis_prj, pattern = p, full.names = TRUE))
tileRaster(raster = doy_rst, tilenbr = c(12,10), overlap = 10, outpath = path_modis_tiles)

p = c("Quality.tif$")
qlt_rst = raster::stack(list.files(path_modis_prj, pattern = p, full.names = TRUE))
tileRaster(raster = qlt_rst, tilenbr = c(12,10), overlap = 10, outpath = path_modis_tiles)


