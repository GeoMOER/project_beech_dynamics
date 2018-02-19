#--------------------------------------------------------------------------------------------#
####temporal aggregation loop#####
#climate data
filepath_base = "F:/Uni/EnvironmentalObservations/modis_carpathian_mountains"
path_mswep = paste0(filepath_base, "/data/mswep")
path_mswep_out = paste0(filepath_base, "/data/output_mswep_test/")
#path_vectors = paste0(filepath_base, "/data/vectors")

#create list with yearly stacked daily precipitation (mm/m²?) raster 
mswep_files=list.files(path_mswep, pattern = glob2rx("*.tif"), full.names = TRUE)
stacklist=lapply(mswep_files, function(x){
  stack(x)
})

#aggregate
timespan=c(2011:2016)
n=1
for (j in timespan){

  dates = substr(basename(list.files(path = paste0(act_tile_path, subpath_modis_doy), full.names = T)), 10, 16)
  l = substr(dates[substr(dates, 1, 4) == j], 5, 7)
  l = as.numeric(l)

  for(i in seq(1:(length(l)-1))){
    print(l[i]:(l[i+1]-1))
    temp_agg=sum(stacklist[[n]][[l[i]:(l[i+1]-1)]])
    writeRaster(temp_agg, paste0(path_mswep_out, "MSWEP_karpaten_", j, l[i], "temporal_aggregated.tif"))
  }
  if (n != length(stacklist)){
    temp_agg = sum(stacklist[[n]][[l[length(l)]:nlayers(stacklist[[n]])]])+sum(stacklist[[n+1]][[1:8]])
    writeRaster(temp_agg, paste0(path_mswep_out, "MSWEP_karpaten_", j, "361", "temporal_aggregated.tif"))
  }
  n=n+1
}

#---------------------------------------------------------------------------------------------#
######project temporal aggregated data#####
#load ndvi raster tiles over total study area 
input_path = paste0(act_tile_path, subpath_modis_ndvi)

input_filepath = list.files(input_path, pattern = glob2rx("*.tif"), full.names = TRUE)
raster_stack_ndvi = stack(input_filepath)

filepath_base = "F:/Uni/EnvironmentalObservations/modis_carpathian_mountains"

big_tile = raster(paste0(filepath_base, "/data/MYD13Q1.A2002185.250m_16_days_NDVI_c3999-4519_r2039-2570-1.tif"))

#project
#for all tiles (spacial) in study area and for all temporal aggregated rasters (temporal) do:
for (i in seq(1:length(ras_stack_mswep_tempAggregated))){
    projectRaster(from=ras_stack_mswep_tempAggregated[[i]], to=trend_ndvi_output_ras_example,
                  method="ngb", 
                  filename="ras_mswep_tempAggregated_projected.tif", overwrite = T) 

}

test=projectRaster(from=mswep[[1]], to=big_tile,
              method="bilinear", 
              filename="ras_mswep_tempAggregated_projected_blin.tif", overwrite = T)
plot(test)
