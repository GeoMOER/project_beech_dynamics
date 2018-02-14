path_mswep = paste0(path_data, "/mswep")
mswep_fn = list.files(path_mswep, pattern  = glob2rx("*.tif"), full.names = TRUE)
mswep_rst = stack(mswep_fn)
mswep_rst



m = raster("F:/modis_carpathian_mountains/modis/tiles/c0001-0511_r0001-0522/modis_ndvi/MYD13Q1.A2002185.250m_16_days_NDVI_c0001-0511_r0001-0522.tif")
m_pts = rasterToPoints(m)
plot(m_pts)

head(m_pts)

m_spdf = SpatialPoints(m_pts[, 1:2])
projection(m_spdf) = projection(m)
m_spdf
