#preludium

dir = "D:/UniData/gis2/data_small/data_small/modis/tiles/c0001-0511_r0001-0522/modis_filled_timeseries"
p =  "^.*_NDVI_.*\\.tif$"
files = list.files(dir, pattern = p, full.names = TRUE)
rst_fn_filled = raster::stack(files)
out = "D:/UniData/gis2/test/"


#climax
wurst = compileOutFilePath(input_filepathes = files, output_subdirectory = "testomat")
deseason(rstack = rst_fn_filled, outFilePath = wurst)
