# Set path ---------------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  filepath_base = "E:/modis_carpathian_mountains/"
} else {
  filepath_base = "/mnt/sd19006/data/processing_data/modis_carpathian_mountains/"
}

path_data = filepath_base
path_modis = paste0(filepath_base, "modis/")
path_modis_arc = paste0(path_modis, "MODIS_ARC/")
path_modis_prj = paste0(path_modis_arc, "PROCESSED/carpathian_mountains/")
path_modis_adj = paste0(path_modis, "modis_adj/")
path_modis_quality_checked = paste0(path_modis, "modis_quality_checked/")
path_modis_quality_checked_tiles = paste0(path_modis, "modis_quality_checked_tiles/")
path_modis_doy_tiles = paste0(path_modis, "modis_doy_tiles/")
path_modis_qua_tiles = paste0(path_modis, "modis_qua_tiles/")
path_modis_outliers_tiles = paste0(path_modis, "modis_outliers_tiles/")
path_modis_whittaker_tiles = paste0(path_modis, "modis_whittaker_tiles/")
path_modis_scaled_tiles = paste0(path_modis, "modis_scaled_tiles/")
path_modis_temp_agg_tiles = paste0(path_modis, "modis_temp_agg_tiles/")
path_modis_filled_tiles = paste0(path_modis, "modis_filled_tiles/")
path_modis_deseason_tiles = paste0(path_modis, "modis_deseason_tiles/")
path_modis_mktrends_tiles = paste0(path_modis, "modis_mktrends_tiles/")
path_modis_results= paste0(path_modis, "modis_results/")
path_rdata = paste0(path_modis, "rdata/")
path_temp = paste0(path_modis, "temp/")
path_output = paste0(path_modis, "output/")
path_vectors = paste0(path_data, "vectors/")


# Set libraries ----------------------------------------------------------------
library(doParallel)
library(GSODTools)
# library(gimms)
library(rgeos)
# library(mapview)
library(MODIS)
# library(metTools)  # devtools::install_github("environmentalinformatics-marburg/metTools")
library(raster)
library(rgdal)
library(remote)
# library(satelliteTools)  # devtools::install_github("environmentalinformatics-marburg/satelliteTools")
library(sp)

# Other settings ---------------------------------------------------------------
rasterOptions(tmpdir = path_temp)

# saga_cmd = "C:/OSGeo4W64/apps/saga/saga_cmd.exe "
# initOTB("C:/OSGeo4W64/bin/")
# initOTB("C:/OSGeo4W64/OTB-5.8.0-win64/OTB-5.8.0-win64/bin/")


