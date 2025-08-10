# data-soilgrids.R
# Retrieve SoilGrids <https://www.isric.org/explore/soilgrids> data for W. Asia
# Based on https://git.wur.nl/isric/soilgrids/soilgrids.notebooks/-/blob/master/markdown/webdav_from_R_terra.md
# NOTE: relies on an external API (last run 2025-08-08)
library("fs")
library("purrr")
library("sf")
library("terra")
library("whitebox")
library("BadiaPaleoFloraENM")

soilgrids_vars <- c("clay", "sand", "silt", "phh2o")

soilgrids <- map(soilgrids_vars, function(var, region) {
  base_url <- "https://files.isric.org/soilgrids/latest/data_aggregated/1000m/"
  layer <- paste(var, "0-5cm", "mean", sep="_") # layer of interest

  soilgrid <- rast(paste0("/vsicurl/", base_url, var, "/", layer, "_1000.tif"))
  bbox <- project(ext(region), from = st_crs(region)$wkt, to = crs(soilgrid))
  window(soilgrid) <- bbox

  return(soilgrid)
}, region = w_eurasia)

names(soilgrids) <- soilgrids_vars

# Write
temp_path <- dir_create(path_temp("soilgrids"))
walk2(
  soilgrids,
  path(temp_path, paste0("soilgrids_", names(soilgrids), "_0-5cm_mean_w_eurasia.tif")),
  writeRaster,
  datatype = "FLT4S",
  overwrite = TRUE
)

# Fill NA holes (mostly modern reservoirs) using IDW
walk2(
  dir_ls(temp_path),
  derived_data("soilgrids", path_file(dir_ls(temp_path))),
  wbt_fill_missing_data
)
