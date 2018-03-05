# Set path ---------------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  filepath_base = "F:/modis_carpathian_mountains/"
} else {
  filepath_base = "/mnt/sd19006/data/processing_data/modis_carpathian_mountains/"
}

# Basic data path
path_data = paste0(filepath_base, "/data")

# Path to original modis dataset
path_modis = paste0(path_data, "/modis")
path_modis_arc = paste0(path_modis, "/MODIS_ARC")
path_modis_prj = paste0(path_modis_arc, "/PROCESSED/carpathian_mountains")
path_modis_adj = paste0(path_modis, "/modis_adj")

# Path to top-level tile directory
path_modis_tiles = paste0(path_modis, "/tiles")

# Subpathes defining modis processing steps
subpath_modis_ndvi = "/modis_ndvi"
subpath_modis_doy = "/modis_doy"
subpath_modis_quality = "/modis_quality"
subpath_modis_reliability = "/modis_reliability"
subpath_modis_quality_checked = "/modis_quality_checked"
subpath_modis_outlier_checked = "/modis_outlier_checked"
subpath_modis_whittaker_smoothed = "/modis_whittaker_smoothed"
subpath_modis_scaled = "/modis_scaled"
subpath_modis_temporal_aggregated = "/modis_temporal_aggregated"
subpath_modis_filled_timeseries = "/modis_filled_timeseries"
subpath_modis_deseasoned = "/modis_deseasoned"
subpath_modis_mktrend = "/modis_mktrend"

# Path to spatially re-aggregated MODIS data
path_modis_modis_filled_timeseries = paste0(path_modis, "/modis_filled_timeseries")
path_modis_deseasoned = paste0(path_modis, "/modis_deseasoned")
path_modis_mktrend = paste0(path_modis, "/modis_mktrend")

# Path to top-level study area directory
path_study_area = paste0(path_data, "/study_area")

# Path to rainfall
path_mswep = paste0(path_data, "/mswep")
path_mswep_org = paste0(path_mswep, "/org")
path_mswep_temporal_aggregated = paste0(path_mswep, "/temporal_aggregated")
path_mswep_temporal_aggregated_modis = paste0(path_mswep, "/temporal_aggregated_modis_proj")

# Path to Maryland
path_maryland = paste0(path_data, "/maryland")
path_maryland_org = ppaste0(path_maryland, "/org")
path_maryland = paste0(path_maryland, "/maryland_modis_proj")

# Path to results etc.
path_rdata = paste0(path_data, "/rdata")
path_temp = paste0(path_data, "/temp")
path_output = paste0(path_data, "/output/")
path_vectors = paste0(path_data, "/vectors")
path_proj = paste0(path_data, "/projection/")


# Set libraries ----------------------------------------------------------------
library(beechForestDynamics)
library(doParallel)
library(GSODTools)
library(gimms)
library(rgeos)
# library(mapview)
# devtools::install_github("MatMatt/MODIS", ref = "develop")
library(MODIS)
# library(metTools)  # devtools::install_github("environmentalinformatics-marburg/metTools")
library(raster)
library(rgdal)
library(remote)
library(satelliteTools)  # devtools::install_github("environmentalinformatics-marburg/satelliteTools")
library(sp)
library(snow)

# Other settings ---------------------------------------------------------------
rasterOptions(tmpdir = path_temp)

# saga_cmd = "C:/OSGeo4W64/apps/saga/saga_cmd.exe "
# initOTB("C:/OSGeo4W64/bin/")
# initOTB("C:/OSGeo4W64/OTB-5.8.0-win64/OTB-5.8.0-win64/bin/")


