#---------------------------------------------------------------------------------------------#
######project temporal aggregated data#####
#load ndvi raster tiles over total study area 

list_prst_to = list.files(input_path, pattern = glob2rx("*.tif"), full.names = TRUE)

list_rst_from = list.files(paste0(filepath_base, "/data/output_mswep_test/"), pattern = glob2rx("*.tif"), full.names = TRUE)

outfilepath = paste0(filepath_base, "/data/output_proj_test/")

areaname= "kpa"

###function
spatialproject = function(list_rst_from, list_prst_to, outfilepath, areaname=NULL){
  years=as.numeric(substr(basename(path = list_rst_from),16,19))#10, 13 noch ändern
  
  for (i in years){
    mswep_stack=raster::stack(list_rst_from[which(i==substr(basename(path = list_rst_from),16,19))])
    
    proj_tile=raster(list_prst_to[1])
    
    projectRaster(from=mswep_stack, to=proj_tile,
                  method="bilinear", 
                  filename=paste0(outfilepath, "MSWEP_",areaname, i,"_projected"),
                  format="GTiff", overwrite = T, bylayer=F) 
    
  }
}

#function call
spatialproject(list_rst_from, list_prst_to, outfilepath, areaname= "kpa")