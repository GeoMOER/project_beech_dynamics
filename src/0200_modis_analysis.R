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

# Test run?
test = TRUE

# Define parallelization information
cores = 3
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
tilepathes = list.dirs(path_modis_tiles, recursive = FALSE)
act_tile_path = tilepathes[1] # will be replaced by the loop later
# for(act_tile_path in tilepathes){



#### Compute quality check for NDVI data
if(length(showConnections()) == 0){
  cl = parallel::makeCluster(cores)
  doParallel::registerDoParallel(cl)
}

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

if(test == TRUE){
  checkResults(file = outfiles[1], subpath_file = "/data_small_test", subpath_test = "/data_small")
  saveRDS(ndvi_qc_rst, file = paste0(path_rdata, "/data_small_test_01_ndvi_qc_rst.rds"))
  saveRDS(outfiles, file = paste0(path_rdata, "/data_small_test_01_outfiles.rds"))
}


#### Compute outlier check for NDVI data
if(test == TRUE){
  ndvi_qc_rst = readRDS(paste0(path_rdata, "/data_small_test_01_ndvi_qc_rst.rds"))
  outfiles = readRDS(paste0(path_rdata, "/data_small_test_01_outfiles.rds"))
  # Alternative
  # ndvi_qc_files = list.files(paste0(act_tile_path, "/", subpath_modis_quality_checked),
  #                            pattern = glob2rx("*.tif"), full.names = TRUE)
  # ndvi_qc_rst = stack(ndvi_qc_files)
  # outfiles = ndvi_qc_files
}
if(length(showConnections()) == 0){
  cl = parallel::makeCluster(cores)
  doParallel::registerDoParallel(cl)
}
outfiles = compileOutFilePath(input_filepath = outfiles,
                              output_subdirectory = subpath_modis_outlier_checked,
                              prefix=NA, suffix="oc")

ndvi_oc_rst = outlierCheck(rstack = ndvi_qc_rst, outfilepathes = outfiles,
                           lq=0.4, uq=0.9)


if(test == TRUE){
  checkResults(file = outfiles[1], subpath_file = "/data_small_test", subpath_test = "/data_small")
  saveRDS(ndvi_oc_rst, file = paste0(path_rdata, "/data_small_test_02_ndvi_oc_rst.rds"))
  saveRDS(outfiles, file = paste0(path_rdata, "/data_small_test_02_outfiles.rds"))
}



#### Compute whittaker smoother
if(test == TRUE){
  ndvi_oc_rst= readRDS(file = paste0(path_rdata, "/data_small_test_02_ndvi_oc_rst.rds"))
  outfiles = readRDS(paste0(path_rdata, "/data_small_test_02_outfiles.rds"))
}
if(length(showConnections()) == 0){
  cl = parallel::makeCluster(cores)
  doParallel::registerDoParallel(cl)
}

wfiles = outfiles

outfiles = compileOutFilePath(input_filepath = outfiles,
                              output_subdirectory = subpath_modis_whittaker_smoothed,
                              prefix=NA, suffix="ws")

ndvi_ws_rst = whittakerSmoother(vi = ndvi_oc_rst, names_vi = wfiles,
                                pos1=10, pos2=16,
                                begin="2002185", end="2017345",
                                quality_stck=NULL,
                                doy_stck=NULL,
                                prefixSuffix = c("MYD13Q1", substr(basename(outfiles[1]), 18, (nchar(basename(outfiles[1]))-4))),
                                outfilepath = paste0(dirname(outfiles[1]), "/"),
                                lambda = 6000, nIter = 3, threshold = 2000, pillow = 0,
                                cores = cores)

if(test == TRUE){
  checkResults(file = outfiles[1], subpath_file = "data_small_test", subpath_test = "data_small")
  saveRDS(ndvi_ws_rst, file = paste0(path_rdata, "/data_small_test_03_ndvi_ws_rst.rds"))
  saveRDS(outfiles, file = paste0(path_rdata, "/data_small_test_03_outfiles.rds"))
}



#### Scale raster
if(test == TRUE){
  ndvi_ws_rst = readRDS(file = paste0(path_rdata, "/data_small_test_03_ndvi_ws_rst.rds"))
  outfiles = readRDS(paste0(path_rdata, "/data_small_test_03_outfiles.rds"))
}
if(length(showConnections()) == 0){
  cl = parallel::makeCluster(cores)
  doParallel::registerDoParallel(cl)
}
outfiles = compileOutFilePath(input_filepath = outfiles,
                              output_subdirectory = subpath_modis_scaled,
                              prefix=NA, suffix="sc")

ndvi_sc_rst = scaleRaster(rstck = ndvi_ws_rst,  scalefac = 10000,
                          outputfilepathes = outfiles)


if(test == TRUE){
  checkResults(file = outfiles[1], subpath_file = "data_small_test", subpath_test = "data_small")
  saveRDS(ndvi_sc_rst, file = paste0(path_rdata, "/data_small_test_04_ndvi_sc_rst.rds"))
  saveRDS(outfiles, file = paste0(path_rdata, "/data_small_test_04_outfiles.rds"))
}


#### temporalAggregation ####
if(test == TRUE){
  ndvi_sc_rst = readRDS(paste0(path_rdata, "/data_small_test_04_ndvi_sc_rst.rds"))
  outfiles = readRDS(paste0(path_rdata, "/data_small_test_04_outfiles.rds"))
}
if(length(showConnections()) == 0){
  cl = parallel::makeCluster(cores)
  doParallel::registerDoParallel(cl)
}

doy_fs = list.files(paste0(act_tile_path, subpath_modis_doy),
                    pattern = glob2rx("*.tif"), full.names = TRUE)

start = which(substr(basename(doy_fs), 10, 16) %in% substr(names(ndvi_sc_rst)[1], 10, 16))
end = which(substr(basename(doy_fs), 10, 16) %in% substr(names(ndvi_sc_rst)[nlayers(ndvi_sc_rst)], 10, 16))

doy_rst = stack(doy_fs[start:end])

outfiles = compileOutFilePath(input_filepath = outfiles,
                              output_subdirectory = subpath_modis_temporal_aggregated,
                              prefix=NA, suffix="ta")

ndvi_ta_rst = temporalAggregation(rstack = ndvi_sc_rst, rstack_doy = doy_rst,
                                  pos1 = 10, pos2 = 16,
                                  outputfilepathes = outfiles,
                                  interval = "fortnight", fun = max, na.rm = TRUE,
                                  cores = cores)


outfiles = paste0(dirname(outfiles), "/", names(ndvi_ta_rst))

if(test == TRUE){
  checkResults(file = outfiles[1], subpath_file = "data_small_test", subpath_test = "data_small")
  saveRDS(ndvi_ta_rst, file = paste0(path_rdata, "/data_small_test_05_ndvi_ta_rst.rds"))
  saveRDS(outfiles, file = paste0(path_rdata, "/data_small_test_05_outfiles.rds"))
}



#### Fill gaps
if(test){
  ndvi_ta_rst = readRDS(paste0(path_rdata, "/data_small_test_05_ndvi_ta_rst.rds"))
  outfiles = readRDS(paste0(path_rdata, "/data_small_test_05_outfiles.rds"))
}
if(length(showConnections()) == 0){
  cl = parallel::makeCluster(cores)
  doParallel::registerDoParallel(cl)
}

outfiles = compileOutFilePath(input_filepath = outfiles,
                              output_subdirectory = subpath_modis_filled_timeseries,
                              prefix=NA, suffix="ft")

ndvi_ft_rst = fillGapsLin(ndvi_ta_rst, outfiles)


if(test == TRUE){
  checkResults(file = outfiles[1], subpath_file = "data_small_test", subpath_test = "data_small")
  saveRDS(ndvi_ft_rst, file = paste0(path_rdata, "/data_small_test_06_ndvi_ft_rst.rds"))
  saveRDS(outfiles, file = paste0(path_rdata, "/data_small_test_06_outfiles.rds"))
}



#### Deseason data
if(test == TRUE){
  ndvi_ft_rst = readRDS(file = paste0(path_rdata, "/data_small_test_06_ndvi_ft_rst.rds"))
  outfiles = readRDS(file = paste0(path_rdata, "/data_small_test_06_outfiles.rds"))
}
if(length(showConnections()) == 0){
  cl = parallel::makeCluster(cores)
  doParallel::registerDoParallel(cl)
}

outfiles = compileOutFilePath(input_filepath = outfiles,
                              output_subdirectory = subpath_modis_deseasoned,
                              prefix=NA, suffix="ds")

start = grep("2003001", basename(outfiles))
end = grep("2017001", basename(outfiles))-1
outfiles = outfiles[start:end]

ndvi_ds_rst = beechForestDynamics::deseason(rstack = ndvi_ft_rst[[start:end]], outFilePath = outfiles, cycle.window = 24L)


if(test == TRUE){
  checkResults(file = outfiles[1], subpath_file = "data_small_test", subpath_test = "data_small")
  saveRDS(ndvi_ds_rst, file = paste0(path_rdata, "/data_small_test_07_ndvi_ds_rst.rds"))
  saveRDS(outfiles, file = paste0(path_rdata, "/data_small_test_07_outfiles.rds"))
}



#### Mann-Kendall trend
if(test == TRUE){
  ndvi_ds_rst = readRDS(file = paste0(path_rdata, "/data_small_test_07_ndvi_ds_rst.rds"))
  outfiles = readRDS(file = paste0(path_rdata, "/data_small_test_07_outfiles.rds"))
}
if(length(showConnections()) == 0){
  cl = parallel::makeCluster(cores)
  doParallel::registerDoParallel(cl)
}

mkoutput = compileOutFilePath(input_filepath = outfiles,
                              output_subdirectory = subpath_modis_mktrend,
                              prefix=NA, suffix="mk")

mkoutfile = paste0(basename(substr(mkoutput[1], 1, nchar(mkoutput[1])-4)), "_0010.tif")

mkoutfile = paste0(dirname(mkoutput[1]), "/",
                   substr(mkoutfile, 1, 16),
                   substr(basename(mkoutput[length(mkoutput)]), 8, 16),
                   substr(mkoutfile, 17, nchar(mkoutfile)))

ndvi_mk_rst = mkTrend(input = ndvi_ds_rst, p = 0.01, prewhitening = TRUE, method = "yuepilon",
                      filename = mkoutfile)

if(test == TRUE){
  checkResults(file = mkoutfile, subpath_file = "data_small_test", subpath_test = "data_small")
  saveRDS(ndvi_mk_rst, file = paste0(path_rdata, "/data_small_test_08_ndvi_mk_rst.rds"))
  saveRDS(outfiles, file = paste0(path_rdata, "/data_small_test_08_outfiles.rds"))
}



# }


###flexTimeAggStack
if(length(showConnections()) == 0){
  cl = parallel::makeCluster(cores)
  doParallel::registerDoParallel(cl)
}
mswep_files <- list.files(path_mswep, pattern = glob2rx("*.tif"), full.names = TRUE)

dates_path <- list.files(paste0(act_tile_path, subpath_modis_temporal_aggregated), 
                         pattern = glob2rx("*.tif"), full.names = TRUE)

dates=substr(basename(dates_path),10,16)

flexTimeAggStack(beginnzeitsp = 2002, endzeitsp = 2003, dates_path = dates, aggrdata = mswep_files, a=1, b=4, c=5, d=7,
             outfilepath = path_output, edit="kap")




if (cores > 1L)
  parallel::stopCluster(cl)
