# data-soilgrids.R
# Retrieve SoilGrids <https://www.isric.org/explore/soilgrids> data for W. Asia
# Based on https://git.wur.nl/isric/soilgrids/soilgrids.notebooks/-/blob/master/markdown/webdav_from_R_terra.md
# NOTE: relies on an external API (last run 2024-11-28)
library("terra")

soilgrids_vars <- c("clay", "sand", "silt", "phh2o")

soilgrids <- map(soilgrids_vars, function(var, region) {
  base_url <- "https://files.isric.org/soilgrids/latest/data_aggregated/1000m/"
  layer <- paste(var, "0-5cm", "mean", sep="_") # layer of interest

  soilgrid <- rast(paste0("/vsicurl/", base_url, var, "/", layer, "_1000.tif"))
  bbox <- project(ext(region), from = st_crs(region)$wkt, to = crs(soilgrid))
  window(soilgrid) <- bbox

  return(soilgrid)
}, region = w_asia)

names(soilgrids) <- soilgrids_vars

walk2(
  soilgrids,
  derived_data("soilgrids", paste0("soilgrids_", names(soilgrids), "_0-5cm_mean_w_asia.tif")),
  writeRaster,
  datatype = "FLT4S",
  overwrite = TRUE
)

