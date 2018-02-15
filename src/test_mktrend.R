
# Testdata MKTrend
# mkTrend test

act_tile_path<- ("F:/modis_carpathian_mountains/data_small/modis/tiles/c0001-0511_r0001-0522/modis_deseasoned")
test_out <- ("F:/modis_carpathian_mountains/data_small/modis/tiles/c0001-0511_r0001-0522/modis_mktrend/mktrend")

fls_stau = paste0(subpath, "MK_", substr(names(rst_dsn)[1], 1, 25),
                  substr(names(rst_dsn)[length(names(rst_dsn))],
                         18, length(names(rst_dsn))))

fls_stau = c(paste0(fls_stau, "_tau.tif"))

rst_fn_list = list.files((act_tile_path),pattern = glob2rx("*.tif"), full.names = TRUE)
rst_fn = raster::stack(rst_fn_list)

mkTrend(input = rst_fn, p = 0.01, prewhitening = TRUE, method = "yuepilon", filename = fls_stau[1])

if (cores > 1L)
  parallel::stopCluster(cl)



