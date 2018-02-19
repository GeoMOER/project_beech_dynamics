#--------------------------------------------------------------------------------------------#
####temporal aggregation loop#####
#climate data
filepath_base = "F:/Uni/EnvironmentalObservations/modis_carpathian_mountains"
path_mswep = paste0(filepath_base, "/data/mswep")
path_mswep_out = paste0(filepath_base, "/data/output_mswep_test/")
#path_vectors = paste0(filepath_base, "/data/vectors")
mswep_files=list.files(
  path="C:/Users/Admin/Desktop/mswep/",
  pattern = glob2rx("*.tif"), full.names = TRUE)
#create list with yearly stacked daily precipitation (mm/m²?) raster 
mswep_files=list.files(path_mswep, pattern = glob2rx("*.tif"), full.names = TRUE)
#stacklist=raster::stack(mswep_files)

#aggregate
endzeitsp=2017
beginnzeitsp=2002
#n=1




temporalaggregation=function(beginnzeitsp,endzeitsp,dates_path,mswep_files,outfilepath,edit=kap){
  foreach(j = seq(beginnzeitsp,endzeitsp), i = seq(1:(length(l)-1)))
    .packages = c("raster", "rgdal")
    %dopar%{
      dates = substr(basename(list.files(path = dates_path, full.names = T)), 10, 16)
    lc = substr(dates[substr(dates, 1, 4) == j], 5, 7)
    l = as.numeric(lc)
    
    if ((i+1 > (length(l)-1))){
      stacklist=raster::stack(mswep_files[which(j == seq(beginnzeitsp,endzeitsp))])
      temp_agg = sum(stacklist[[(l[length(l)]+1):nlayers(stacklist)]])
      raster::writeRaster(temp_agg, paste0(outfilepath, "MSWEP_",edit,"_", j, lc[i+1], "_temporal_aggregated"),format="GTiff",overwrite=T)
    } else {
      stacklist=raster::stack(mswep_files[which(j == seq(beginnzeitsp,endzeitsp))])
      temp_agg=sum(stacklist[[l[i]:(l[i+1]-1)]])
      raster::writeRaster(temp_agg, paste0(outfilepath, "MSWEP_",edit,"_", j, lc[i], "_temporal_aggregated"),format="GTiff",overwrite=T)
      
    }}}
    
      
#   for (j in seq(beginnzeitsp,endzeitsp)){
#     dates = substr(basename(list.files(path = dates_path, full.names = T)), 10, 16)
#     lc = substr(dates[substr(dates, 1, 4) == j], 5, 7)
#     l = as.numeric(lc)
#     
#     for(i in seq(1:(length(l)-1))){
#       if ((i+1 > (length(l)-1))){
#         stacklist=raster::stack(mswep_files[which(j == seq(beginnzeitsp,endzeitsp))])
#         temp_agg = sum(stacklist[[(l[length(l)]+1):nlayers(stacklist)]])
#         raster::writeRaster(temp_agg, paste0(outfilepath, "MSWEP_karpaten_", j, lc[i+1], "_temporal_aggregated"),format="GTiff",overwrite=T)
#       } else {
#         stacklist=raster::stack(mswep_files[which(j == seq(beginnzeitsp,endzeitsp))])
#         temp_agg=sum(stacklist[[l[i]:(l[i+1]-1)]])
#         raster::writeRaster(temp_agg, paste0(outfilepath, "MSWEP_karpaten_", j, lc[i], "_temporal_aggregated"),format="GTiff",overwrite=T)
#         
#       }
#     }
#   }
# }
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

spacialproject=function(rst_from,prst_to,outfilepath){
  for (i in seq(1:length(rst_from))){
    mwesp_stck= raster::stack(rst_from[which(i==substr(basename(path = rst_from),10,13))])#aktuell 16,19
    for (j in seq(1:length(prst_to)))
    
    proj_stck= raster::stack(prst_to[which(i==substr(basename(path = prst_to),10,13))])
    
    projectRaster(from=mwesp_stck, to=proj_stck,
                  method="bilinear", 
                  filename=outputfilepath,format="GTiff", overwrite = T) 
    
  }
}
test=projectRaster(from=mswep[[1]], to=big_tile,
                   method="bilinear", 
                   filename="ras_mswep_tempAggregated_projected_blin.tif", overwrite = T)
plot(test)
