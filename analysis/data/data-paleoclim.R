# data-paleoclim.R
# Retrieve Paleoclim <http://www.paleoclim.org/> data for W. Asia
# NOTE: relies on an external API (last run 2025-08-08)
library(rpaleoclim)

paleoclim <- map(climate_periods$code, function(period, region) {
  paleoclim(
    period = period,
    resolution = "2_5m",
    region = region,
    cache_path = derived_data("paleoclim", "raw")
  )
}, region = w_eurasia)

# Fix extent of CHELSA 'current' layer
terra::ext(paleoclim[[4]]) <- terra::ext(paleoclim[[1]])

names(paleoclim) <- climate_periods$code

# Write files
walk2(
  paleoclim,
  derived_data("paleoclim", paste0("paleoclim_", names(paleoclim), "_2_5m_w_eurasia.tif")),
  terra::writeRaster,
  datatype = "FLT4S",
  overwrite = TRUE
)
