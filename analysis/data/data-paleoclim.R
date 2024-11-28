# data-paleoclim.R
# Retrieve Paleoclim <http://www.paleoclim.org/> data for W. Asia
# NOTE: relies on an external API (last run 2024-11-28)
library(rpaleoclim)

paleoclim <- map(names(climate_periods), function(period, region) {
  paleoclim(
    period = period,
    resolution = "2_5m",
    region = region,
    cache_path = derived_data("paleoclim", "raw")
  )
}, region = w_asia)

# Fix extent of CHELSA 'current' layer
terra::ext(paleoclim[[6]]) <- terra::ext(paleoclim[[1]])

names(paleoclim) <- names(climate_periods)

# Write files
walk2(
  paleoclim,
  derived_data("paleoclim", paste0("paleoclim_", names(paleoclim), "_2_5m_w_asia.tif")),
  terra::writeRaster,
  datatype = "FLT4S",
  overwrite = TRUE
)
