# data-dem.R
# Retrieve DEM <http://www.paleoclim.org/> data for W. Asia
# Requires OpenTopography <https://opentopography.org> API key set in the
#   environment and system installation of WhiteBox Tools
#   <https://www.whiteboxgeo.com/>
#
# NOTE: relies on an external API (last run 2024-11-28)
library("elevatr")
library("whitebox")

srtm_15plus <- get_elev_raster(st_sf(st_as_sfc(w_asia)), prj = 4326, src = "srtm15plus")
writeRaster(srtm_15plus, derived_data("dem", "srtm_15plus_w_asia.tif"))

dem <- wbt_file_path(derived_data("dem", "srtm_15plus_w_asia.tif"))

# Slope
slope <- wbt_file_path(derived_data("dem", "srtm_15plus_w_asia_slope.tif"))
wbt_slope(dem, slope, compress_rasters = TRUE)

# Aspect
aspect <- wbt_file_path(derived_data("dem", "srtm_15plus_w_asia_aspect.tif"))
wbt_aspect(dem, aspect, compress_rasters = TRUE)

# Topographic wetness
sca <- wbt_file_path(fs::file_temp("sca", ex = "tif"))
wbt_flow_accumulation_full_workflow(
  dem,
  out_dem = fs::file_temp("dem", ext = "tif"),
  out_pntr = fs::file_temp("pntr", ext = "tif"),
  out_accum = sca,
  out_type = "Specific Contributing Area",
  compress_rasters = TRUE
)

wetness <- wbt_file_path(derived_data("dem", "srtm_15plus_w_asia_wetness.tif"))
wbt_wetness_index(sca, slope, wetness, compress_rasters = TRUE)
