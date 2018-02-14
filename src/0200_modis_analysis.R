#' Compute MODIS NDVI time series trends
#'
#' @description
#' Compute time series trends for MODIS NDVI time series. MODIS datasets are
#' split into tiles to allow computation in limited working memory environments.
#'
#' Directory structure is as follows:
#' <some individual path>/data/modis/
#'                              |
#'                              |-MODIS_ARC
#'                              |
#'                              |-tiles
#'                                   |
#'                                   |-c0001-0511_r0001-0522
#'                                              |
#'                                              |-modis_ndvi
#'                                              |
#'                                              |-modis_doy
#'                                              |
#'                                              |-modis_qualflag
#'                                              |
#'                                              |-modis_quality_checked
#'                                              |
#'                                              |-modis_outlier_checked
#'                                              |
#'                                              |-...
#'                                   |-...
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


#### Subset MODIS into tiles
if (!dir.exists(path_modis_tiles))
  dir.create(path_modis_tiles, recursive = TRUE)

p = c("NDVI.tif$")
ndvi_rst = raster::stack(list.files(path_modis_prj, pattern = p, full.names = TRUE))
tileRaster(raster = ndvi_rst, tilenbr = c(12,10), overlap = 10,
           outpath = path_modis_tiles, subpath = subpath_modis_ndvi)

p = c("composite_day_of_the_year.tif$")
doy_rst = raster::stack(list.files(path_modis_prj, pattern = p, full.names = TRUE))
tileRaster(raster = doy_rst, tilenbr = c(12,10), overlap = 10,
           outpath = path_modis_tiles, subpath = subpath_modis_doy)

p = c("Quality.tif$")
qlt_rst = raster::stack(list.files(path_modis_prj, pattern = p, full.names = TRUE))
tileRaster(raster = qlt_rst, tilenbr = c(12,10), overlap = 10,
           outpath = path_modis_tiles, subpath = subpath_modis_quality)

p = c("reliability.tif$")
rlb_rst = raster::stack(list.files(path_modis_prj, pattern = p, full.names = TRUE))
tileRaster(raster = rlb_rst, tilenbr = c(12,10), overlap = 10,
           outpath = path_modis_tiles, subpath = subpath_modis_reliability)


#### Start loop
tilepathes = list.dirs(path_modis_tiles)[-1]
act_tile_path = tilepathes[1] # will be replaced by the loop later
# for(act_tile_path in tilepathes){ This is the star of the loop over all tile folders



#### Compute quality check for NDVI data
ndvi_files = list.files(paste0(act_tile_path, "/", subpath_modis_ndvi),
                        pattern = glob2rx("*.tif"), full.names = TRUE)
ndvi_rst = raster::stack(ndvi_files)

reliability_files = list.files(paste0(act_tile_path, "/", subpath_modis_reliability),
                           pattern = glob2rx("*.tif"), full.names = TRUE)
reliability_rst = raster::stack(reliability_files)

outfiles = compileOutFilePath(input_filepath = ndvi_files,
                              output_subdirectory = subpath_modis_quality_checked,
                              prefix=NA, suffix="qc")

ndvi_qc_rst = qualityCheck(rstck_values = ndvi_rst,
                           rstck_quality = reliability_rst,
                           outputfilepathes = outfiles)

checkResults (file = outfiles[1], subpath_file = "data_small_test", subpath_test = "data_small")

#### Compute outlier check for NDVI data
# Load data from disk or use stack from step above
# ndvi_qc_files = list.files(paste0(act_tile_path, "/", subpath_modis_quality_checked),
#                            pattern = glob2rx("*.tif"), full.names = TRUE)
# ndvi_qc_rst = stack(ndvi_qc_files)

ndvi_qc_rst



#### Continue...


# } This is the end of the loop over all tile folders

if (cores > 1L)
  parallel::stopCluster(cl)
