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
source("C:/Users/Admin/Desktop/00_set_environment.R")
lib = c("beechForestDynamics", "doParallel", "raster", "rgdal", "GSODTools")


# Define parallelization information
cores = 4
cl = parallel::makeCluster(cores)
doParallel::registerDoParallel(cl)


# #### Subset MODIS into tiles
# if (!dir.exists(path_modis_tiles))
#   dir.create(path_modis_tiles, recursive = TRUE)
# 
# p = c("NDVI.tif$")
# ndvi_rst = raster::stack(list.files(path_modis_prj, pattern = p, full.names = TRUE))
# tileRaster(raster = ndvi_rst, tilenbr = c(12,10), overlap = 10,
#            outpath = path_modis_tiles, subpath = subpath_modis_ndvi)
# 
# p = c("composite_day_of_the_year.tif$")
# doy_rst = raster::stack(list.files(path_modis_prj, pattern = p, full.names = TRUE))
# tileRaster(raster = doy_rst, tilenbr = c(12,10), overlap = 10,
#            outpath = path_modis_tiles, subpath = subpath_modis_doy)
# 
# p = c("Quality.tif$")
# qlt_rst = raster::stack(list.files(path_modis_prj, pattern = p, full.names = TRUE))
# tileRaster(raster = qlt_rst, tilenbr = c(12,10), overlap = 10,
#            outpath = path_modis_tiles, subpath = subpath_modis_quality)
# 
# p = c("reliability.tif$")
# rlb_rst = raster::stack(list.files(path_modis_prj, pattern = p, full.names = TRUE))
# tileRaster(raster = rlb_rst, tilenbr = c(12,10), overlap = 10,
#            outpath = path_modis_tiles, subpath = subpath_modis_reliability)
# 

#### Start loop
tilepathes = list.dirs(path_modis_tiles)[-1]
act_tile_path = tilepathes[1] # will be replaced by the loop later
# for(act_tile_path in tilepathes){ This is the star of the loop over all tile folders



#### qualitycheck ####
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

checkResults(file = outfiles[1], subpath_file = "data_small_test", subpath_test = "data_small")

#### Compute outlier check for NDVI data

ndvi_qc_files = list.files(paste0(act_tile_path, "/", subpath_modis_quality_checked),
                            pattern = glob2rx("*.tif"), full.names = TRUE)
ndvi_qc_rst = stack(ndvi_qc_files)

outfiles = compileOutFilePath(input_filepath = ndvi_qc_files,
                              output_subdirectory = subpath_modis_outlier_checked,
                              prefix=NA, suffix="oc")

ndvi_oc_rst=outlierCheck(rstack = ndvi_qc_rst,outfilepathes = outfiles, lq=0.4, uq=0.9)

checkResults(file = outfiles[1], subpath_file = "data_small_test", subpath_test = "data_small")

#### whittakerSmoother ####

ndvi_oc_files=list.files(paste0(act_tile_path, "/", subpath_modis_outlier_checked),
                         pattern = glob2rx("*.tif"), full.names = TRUE)
ndvi_oc_rst=raster::stack(ndvi_oc_files)

ndvi_files = list.files(paste0(act_tile_path, "/", subpath_modis_ndvi),
                        pattern = glob2rx("*.tif"), full.names = TRUE)

ndvi_rst = raster::stack(ndvi_files)

ndvi_doy_files=list.files(paste0(act_tile_path, "/", subpath_modis_doy),
                          pattern = glob2rx("*.tif"), full.names = TRUE)

ndvi_doy_rst=raster::stack(ndvi_doy_files)

outfiles = compileOutFilePath(input_filepath = ndvi_qc_files,
                              output_subdirectory = subpath_modis_whittaker_smoothed,
                              prefix=NA, suffix="_ws")

ndvi_ws_rst=whittakerSmoother(ndvi_oc_rst = ndvi_rst,quality_rst = ndvi_oc_rst,
                              doy_rst = ndvi_doy_rst,output_subdirectory = outfiles,
                              lambda = 6000,nIter = 3,threshold = 2000,prefix = "ab",
                              suffix = "ws")

checkResults(file = outfiles[1], subpath_file = "data_small_test", subpath_test = "data_small")

#### scaleRaster ####

ndvi_ws_files=list.files(paste0(act_tile_path, "/", subpath_modis_whittaker_smoothed),
                         pattern = glob2rx("*.tif"), full.names = TRUE)

ndvi_ws_rst=raster::stack(ndvi_ws_files)

outfiles = compileOutFilePath(input_filepath = ndvi_qc_files,
                              output_subdirectory = subpath_modis_scaled,
                              prefix=NA, suffix="scl")

ndvi_scl_rst=scaleRaster(rstck = ndvi_ws_rst,outputfilepathes = outfiles)

checkResults(file = outfiles[1], subpath_file = "data_small_test", subpath_test = "data_small")

#### temporalAggregation ####

ndvi_scl_files=list.files(paste0(act_tile_path, "/", subpath_modis_scaled),
                                         pattern = glob2rx("*.tif"), full.names = TRUE)

ndvi_scl_rst=raster::stack(ndvi_scl_files)

ndvi_doy_files=list.files(paste0(act_tile_path, "/", subpath_modis_doy),
                         pattern = glob2rx("*.tif"), full.names = TRUE)

ndvi_doy_rst=raster::stack(ndvi_doy_files)

outfiles = compileOutFilePath(input_filepath = ndvi_qc_files,
                              output_subdirectory = subpath_modis_temporal_aggregated,
                              prefix=NA, suffix="ta")

#ndvi_ta_rst=temporalAggregation(rstack = ,rstack_doy = ndvi_doy_rst,layer_dates = ,outputfilepathes = outfiles)
#layer_date?!?

checkResults(file = outfiles[1], subpath_file = "data_small_test", subpath_test = "data_small")

#### fillGaps ####

ndvi_ta_files=list.files(paste0(act_tile_path, "/", subpath_modis_temporal_aggregated),
                         pattern = glob2rx("*.tif"), full.names = TRUE)

ndvi_ta_rst=raster::stack(ndvi_ta_files)

outfiles = compileOutFilePath(input_filepath = ndvi_qc_files,
                              output_subdirectory = subpath_modis_filled_timeseries,
                              prefix=NA, suffix="ft")

ndvi_ft_rst=fillGapsLin(rst_fn = ndvi_ta_rst,out_path = outlines)

checkResults(file = outfiles[1], subpath_file = "data_small_test", subpath_test = "data_small")

#### deseason ####

ndvi_ft_files=list.files(paste0(act_tile_path, "/", subpath_modis_filled_timeseries),
                         pattern = glob2rx("*.tif"), full.names = TRUE)

ndvi_ft_rst=raster::stack(ndvi_ft_files)

outfiles = compileOutFilePath(input_filepath = ndvi_qc_files,
                              output_subdirectory = subpath_modis_deseasoned,
                              prefix=NA, suffix="ds")

ndvi_ds_rst=deseason(rstack = ndvi_ft_rst,outFilePath = outfiles,cycle.window = 12L)

checkResults(file = outfiles[1], subpath_file = "data_small_test", subpath_test = "data_small")

#### mkTrend ####

ndvi_ds_files=list.files(paste0(act_tile_path, "/", subpath_modis_deseasoned),
                         pattern = glob2rx("*.tif"), full.names = TRUE)

ndvi_ds_rst=raster::stack(ndvi_ds_files)

outfiles = compileOutFilePath(input_filepath = ndvi_qc_files,
                              output_subdirectory = subpath_modis_mktrend,
                              prefix=NA, suffix="mk")

ndvi_mk_rst=mkTrend(input = ndvi_ds_rst,p=0.001,prewhitening = T,method = "yuepilon",filename = outfiles)

checkResults(file = outfiles[1], subpath_file = "data_small_test", subpath_test = "data_small")

# } This is the end of the loop over all tile folders

if (cores > 1L)
  parallel::stopCluster(cl)
