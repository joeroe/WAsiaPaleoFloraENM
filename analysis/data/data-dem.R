# data-dem.R
# Retrieve DEM <http://www.paleoclim.org/> data for W. Asia from OpenTopography
# NOTE: relies on an external API (last run 2024-11-28)
library("elevatr")

srtm_15plus <- get_elev_raster(st_sf(st_as_sfc(w_asia)), prj = 4326, src = "srtm15plus")
writeRaster(srtm_15plus, derived_data("dem", "srtm_15plus_w_asia.tif"))
