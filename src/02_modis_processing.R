#' Compute MODIS NDVI time series trends
#'
#' @description
#' Compute time series trends for MODIS NDVI time series. MODIS datasets are
#' split into tiles to allow computation in limited working memory environments.
#'

# Load environment
# source("E:/modis_carpathian_mountains/src/00_set_environment.R")
source("/mnt/sd19006/data/processing_data/modis_carpathian_mountains/src/00_set_environment.R")
lib = c("doParallel", "raster", "rgdal", "GSODTools")

# Define parallelization information
cores = 8
cl = parallel::makeCluster(cores)
doParallel::registerDoParallel(cl)


## First quality assurance
p = c("NDVI.tif$", "reliability.tif$")
ndvi.rst = lapply(p, function(p){
  ndvi = stack(list.files(path_modis_prj, pattern = p, full.names = TRUE))
})

if (!dir.exists(path_modis_quality_checked))
  dir.create(path_modis_quality_checked)

suppressWarnings(
  lst_ndvi_qa = foreach(i = unstack(ndvi.rst[[1]]), j = ndvi.rst[[2]],
                        .packages = lib,
                        .export = ls(envir = globalenv())) %dopar% {
                          raster::overlay(i, j, fun = function(x, y) {
                            x[!y[] %in% c(0:2)] = NA
                            return(x)
                          }, filename = paste0(path_modis_quality_checked, "QA_", names(i)),
                          format = "GTiff", overwrite = TRUE)
                        }
)

ndvi.rst.qa = stack(lst_ndvi_qa)


## Subset MODIS files into tiles
p = c("NDVI.tif$")
ndvi.rst.qa = raster::stack(list.files(path_modis_quality_checked, pattern = p, full.names = TRUE))
tileRaster(raster = ndvi.rst.qa, tilenbr = c(12,10), overlap = 10, outpath = path_modis_quality_checked_tiles)

p = c("composite_day_of_the_year.tif$")
ndvi.rst.doy = raster::stack(list.files(path_modis_prj, pattern = p, full.names = TRUE))
tileRaster(raster = ndvi.rst.doy, tilenbr = c(12,10), overlap = 10, outpath = path_modis_doy_tiles)

p = c("Quality.tif$")
ndvi.rst.doy = raster::stack(list.files(path_modis_prj, pattern = p, full.names = TRUE))
tileRaster(raster = ndvi.rst.doy, tilenbr = c(12,10), overlap = 10, outpath = path_modis_qua_tiles)


## Additional outlier check
dirs = list.dirs(path_modis_quality_checked_tiles)[-1]
dirs = dirs[-seq(7)]

for(dir in dirs){
  p =  "^.*_NDVI_.*\\.tif$"
  files = list.files(dir, pattern = p, full.names = TRUE)
  ndvi.rst.qa = raster::stack(files)
  ndvi_mat_qa = raster::as.matrix(ndvi.rst.qa)
  ndvi_rst_sd = ndvi.rst.qa

  ndvi_lst_sd =
    foreach(i = 1:nrow(ndvi_mat_qa), .packages = lib,
            .export = ls(envir = globalenv())) %dopar% {
              val = ndvi_mat_qa[i, ]
              if(length(which(!is.na(val))) > 2){
                id = GSODTools::tsOutliers(val, lower_quantile = .4,
                                           upper_quantile = .9, index = TRUE)
                val[id] = NA
              }
              return(matrix(val, ncol = length(val), byrow = TRUE))
            }

  ndvi_mat_sd = do.call("rbind", ndvi_lst_sd)
  rm(ndvi_lst_sd)
  rm(ndvi_mat_qa)
  gc()

  for(l in seq(nlayers(ndvi_rst_sd))){
    ndvi_rst_sd[[l]] = raster::setValues(ndvi_rst_sd[[l]], ndvi_mat_sd[, l])
  }

  subpath = paste0(path_modis_outliers_tiles, basename(dir), "/")
  if (!dir.exists(subpath))
    dir.create(subpath, recursive = TRUE)

  ndvi_rst_sd = writeRaster(ndvi_rst_sd, format = "GTiff",
                            filename = subpath,
                            bylayer = TRUE, suffix = names(ndvi.rst.qa),
                            overwrite = TRUE)
  rm(ndvi.rst.qa)
  rm(ndvi_rst_sd)
  gc()
}


## Whittaker smoother
dirs = list.dirs(path_modis_outliers_tiles)[-1]

for(dir in dirs){
  p =  "^.*_NDVI_.*\\.tif$"
  vi = preStack(path=dir, pattern=p)

  dirw = paste0(path_modis_qua_tiles, basename(dir), "/")
  p =  "^.*_Quality_.*\\.tif$"
  w = preStack(path=dirw, pattern = p)

  dirt = paste0(path_modis_doy_tiles, basename(dir), "/")
  p =  "^.*_day_.*\\.tif$"
  t = preStack(path=dirt, pattern = p)

  timeInfo = orgTime(basename(vi), nDays="asIn", begin="2002185", end="2017345", pillow=0, pos1 = 14, pos2 = 20)
  vi = preStack(files=vi, timeInfo=timeInfo)


  if(all(substr(basename(vi), 14, 20) == substr(basename(w), 10, 16)) &
     all(substr(basename(vi), 14, 20) == substr(basename(t), 10, 16))){

    subpath = paste0(path_modis_whittaker_tiles, basename(dir), "/")
    if (!dir.exists(subpath))
      dir.create(subpath, recursive = TRUE)

    whittaker.raster(vi = vi, removeOutlier = TRUE,
                     threshold = 2000,
                     timeInfo = timeInfo,
                     lambda = 6000, nIter = 3,
                     prefixSuffix = c("MYD13Q1", substr(basename(vi[1]), 21, 60)),
                     outDirPath = subpath,
                     overwrite = TRUE, format = "raster")

  } else {
    stop
  }

}


## Scaling, temporal aggregation, deseasoning and trend computation
dirs = list.dirs(path_modis_whittaker_tiles)[-1]
for(dir in dirs){
  p =  "^.*_NDVI_.*\\.tif$"
  fls_wht = list.files(dir, pattern = p, full.names = TRUE)
  rst_wht =  raster::stack(fls_wht)
  subpath = paste0(path_modis_scaled_tiles, basename(dir), "/")
  if (!dir.exists(subpath))
    dir.create(subpath, recursive = TRUE)
  fls_scl = paste0(subpath, "/SCL_", names(rst_wht))
  lst_scl = foreach(i = unstack(rst_wht), j = as.list(fls_scl),
                    .packages = c("raster", "rgdal"),
                    .export = ls(envir = globalenv())) %dopar% {

                      # scale factor
                      rst = i
                      rst = rst / 10000

                      # rejection of inconsistent values
                      id = which(rst[] < -1 | rst[] > 1)

                      if (length(id) > 0) {
                        rst[id] = NA
                      }

                      # store
                      writeRaster(rst, filename = j, format = "GTiff", overwrite = TRUE)
                    }
  rst_scl = stack(lst_scl)

  # temporal composite
  # files = list.files(paste0(path_modis_scaled_tiles, basename(dir), "/"), pattern = "^.*_NDVI_.*\\.tif$", full.names = TRUE)
  # rst_scl = stack(files)
  dir_doy = paste0(path_modis_doy_tiles, basename(dir), "/")
  files_doy = list.files(dir_doy, pattern = "*day_of_the_year.*\\.tif", full.names = TRUE)

  start = which(substr(basename(files_doy), 10, 16) %in% substr(names(rst_scl)[1], 13, 19))
  end = which(substr(basename(files_doy), 10, 16) %in% substr(names(rst_scl)[nlayers(rst_scl)], 13, 19))
  rst_doy = stack(files_doy[start:end])

  # Bug in MODIS (extractDate)
  names(rst_doy) = substr(names(rst_doy), 1, nchar(names(rst_doy))-22)
  names(rst_doy) = paste0(substr(names(rst_doy), 1, 17), "h18v03.005.2010239071130.hdf")

  layer_dates = extractDate(rst_scl, pos1 = 13, pos2 = 19, asDate =TRUE)$inputLayerDates

  rst_fn = temporalComposite(x = rst_scl, y = rst_doy,
                             timeInfo = layer_dates, interval = "fortnight",
                             fun = max, na.rm = TRUE, cores = 4L)

  # rst_fn = stack(list.files(subpath, pattern = glob2rx("*.tif"), full.names = TRUE))
  subpath = paste0(path_modis_temp_agg_tiles, basename(dir), "/")
  if (!dir.exists(subpath))
    dir.create(subpath, recursive = TRUE)

  rst_fn_names = paste0(substr(names(rst_scl), 1, 12),
                        names(rst_fn), substr(names(rst_scl),
                                              20, nchar(names(rst_scl))))
  rst_fn_names = gsub("\\.\\.", ".", rst_fn_names)
  rst_fn_names = paste0(subpath, rst_fn_names)
  writeRaster(rst_fn, filename = rst_fn_names,
              format = "GTiff", bylayer = TRUE, overwrite = TRUE)


  # fill gaps in temporal aggregation using linear interpolation
  rst_fn_mat = raster::as.matrix(rst_fn)
  # 43701
  rst_fn_mat_filled =
    foreach(i = 1:nrow(rst_fn_mat), .packages = lib,
            .export = ls(envir = globalenv())) %dopar% {
              val = rst_fn_mat[i, ]
              val_length = length(val)
              if(sum(is.na(val))/val_length < 0.5){
                nas = rle(is.na(val))
                nas_lg = which(nas$lengths & nas$values)
                for(l in nas_lg){
                  l_size = nas$lengths[l]
                  nas_lg_pos = sum(nas$lengths[1:l])
                  sm = nas_lg_pos - l_size
                  lg = nas_lg_pos + 1
                  if(sm <= 0){
                    sm = 1
                    val[sm] = val[lg]
                  }
                  if(lg >= val_length){
                    lg = val_length
                    val[lg] = val[sm]
                  }
                  val[sm:lg]
                  gap_length = lg-sm+1
                  gap_values = approx(c(val[sm], val[lg]), method = "linear",
                                      n = gap_length)
                  val[(sm+1):(lg-1)] = gap_values$y[2:(gap_length-1)]
                }
              }
              return(matrix(val, ncol = length(val), byrow = TRUE))
            }
  rst_fn_mat_filled = do.call("rbind", rst_fn_mat_filled)
  rst_fn_filled = rst_fn
  rm(rst_fn)
  gc()

  for(l in seq(nlayers(rst_fn_filled))){
    rst_fn_filled[[l]] = raster::setValues(rst_fn_filled[[l]], rst_fn_mat_filled[, l])
  }


  names(rst_fn_filled) = paste0("FLD_", names(rst_fn_filled))
  subpath = paste0(path_modis_filled_tiles, basename(dir), "/")
  if (!dir.exists(subpath))
    dir.create(subpath, recursive = TRUE)
  fls_fn_filled = paste0(subpath, names(rst_fn_filled))

  lst_fn_filled = foreach(i = raster::unstack(rst_fn_filled), j = as.list(fls_fn_filled)) %do% {
    raster::writeRaster(i, filename = j, format = "GTiff", overwrite = TRUE)
  }

  # deseason
  # files = list.files(subpath, pattern = "^.*_NDVI_.*\\.tif$", full.names = TRUE)
  # rst_fn_filled = stack(files)
  start = grep("2003001", names(rst_fn_filled))
  end = grep("2017001", names(rst_fn_filled))-1

  rst_dsn = remote::deseason(rst_fn_filled[[start:end]], cycle.window = 24L,
                             use.cpp = TRUE)

  names(rst_dsn) = paste0("DSN_", names(rst_fn_filled[[start:end]]))
  subpath = paste0(path_modis_deseason_tiles, basename(dir), "/")
  if (!dir.exists(subpath))
    dir.create(subpath, recursive = TRUE)
  fls_dsn = paste0(subpath, names(rst_dsn))

  lst_dsn = foreach(i = raster::unstack(rst_dsn), j = as.list(fls_dsn)) %do% {
    raster::writeRaster(i, filename = j, format = "GTiff", overwrite = TRUE)
  }


  # trend
  subpath = paste0(path_modis_mktrends_tiles, basename(dir), "/")
  if (!dir.exists(subpath))
    dir.create(subpath, recursive = TRUE)

  fls_stau = paste0(subpath, "MK_", substr(names(rst_dsn)[1], 1, 25),
                    substr(names(rst_dsn)[length(names(rst_dsn))],
                           18, length(names(rst_dsn))))
  fls_stau = c(paste0(fls_stau, "_tau_1.000.tif"),
               paste0(fls_stau, "_tau_0.010.tif"))

  rst_stau_1000 = significantTau(rst_dsn, p = 1.0,
                                 prewhitening = TRUE, method = "yuepilon",
                                 filename = fls_stau[1])
  rst_stau_0010 = significantTau(rst_dsn, p = 0.01,
                                 prewhitening = TRUE, method = "yuepilon",
                                 filename = fls_stau[2])
}



## deregister parallel backend
if (cores > 1L)
  parallel::stopCluster(cl)


## Combine trend tiles
trends_stau_1000 = list.files(path_modis_mktrends_tiles, pattern = glob2rx("*tau_1.000.tif"),
                              recursive = TRUE, full.names = TRUE)
mergeTiledRasters(rasterlist = trends_stau_1000,  overlap = 10, outpath = paste0(path_modis_results, "MK_DSN_FLD_A2003_2016_tau_1.000.tif"))

#
# https://github.com/environmentalinformatics-marburg/paper_kilimanjaro_ndvi_comparison/blob/master/R/qcMCD13.R
#
# https://github.com/environmentalinformatics-marburg/gimms/blob/master/R/significantTau.R
