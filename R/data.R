# data.R


# Occurrence data (GBIF) --------------------------------------------------

#' Fetch GBIF data
#'
#' A simplified interface to [dismo::gbif()] with caching.
#'
#' @param genus       Character. Genus name.
#' @param species     Character. Species name. Use '*' for fuzzy matching.
#' @param ext         `extent` object. Geographic extent of records to return.
#' @param cache_path  Character. Path to cache data. Downloaded data is cached as
#'                    a CSV with an automatically generated filename.
#' @param redownload  Logical. If `TRUE`, cached data will be ignored. Default: `FALSE`.
#'
#' @details
#'
#' The return value is always read from the cached file to ensure consistency.
#' See [dismo::gbif()] for more details.
#'
#' @return  A `tibble` of downloaded GBIF records.
#'
#' @export
fetch_gbif <- function(genus, species, ext, cache_path, redownload = FALSE) {
  if(species != "*") {
    cache_file <- file.path(cache_path, paste0("gbif_", tolower(genus), "_",
                                               tolower(species), ".csv"))
  }
  else {
    cache_file <- file.path(cache_path, paste0("gbif_", tolower(genus), ".csv"))
  }
  cache_file <- stringr::str_remove(cache_file, "\\*")

  if (!file.exists(cache_file) | redownload == TRUE) {
    message("Downloading '", genus, " ", species, "' from GBIF...")
    dismo::gbif(genus, species, ext) %>%
      tibble::as_tibble() %>%
      dplyr::select(gbifID, genus, species, lon, lat, basisOfRecord) %>%
      readr::write_csv(cache_file)
  }

  message("Reading ", cache_file)
  return(readr::read_csv(cache_file))
}

# Bioclimatic data --------------------------------------------------------

#' Regional Bioclimatic Variables
#'
#' Downloads WorldClim data and derives bioclimatic variables for an arbitrary
#' region (or extent).
#'
#' @param extent      A [raster::Extent] object specifying the region of interest,
#'                    or an object (e.g. matrix, Spatial*) that can be passed to
#'                    [raster::extent()]
#' @param resolution  Numeric. Must be 0.5, 2.5, 5 or 10 (minutes of arc). Default: 0.5.
#' @param cache_path  Character. Path to directory to cache downloaded rasters.
#' @param quiet       Logical. If `TRUE`, suppresses information messages. Default: `FALSE`.
#'
#' @return
#' @export
#'
#' @examples
get_bioclim <- function(extent, resolution = 0.5, cache_path = getwd(), quiet = FALSE) {
  if (!checkmate::assert(checkmate::check_class(extent, "Extent"))) {
    extent <- raster::extent(extent)
  }
  if (!resolution %in% c(0.5, 2.5, 5, 10)) {
    stop("resolution argument must be 0.5, 2.5, 5 or 10 (minutes of arc).")
  }
  checkmate::assert_path_for_output(cache_path, overwrite = TRUE)
  if (!quiet) message("WorldClim downloads will be cached in ", normalizePath(cache_path))

  # Download WorldClim data
  if (resolution > 0.5) {
    tmin <- raster::getData("worldclim", path = cache_path, var = "tmin", res = resolution)
    tmax <- raster::getData("worldclim", path = cache_path, var = "tmax", res = resolution)
    prec <- raster::getData("worldclim", path = cache_path, var = "prec", res = resolution)
  }
  else {
    lons <- seq(from = 30 * floor(raster::xmin(extent) / 30),
                to = 30 * ceiling(raster::xmax(extent) / 30), by = 15) %>%
      subset(. %% 30 != 0)
    lats <- seq(from = 30 * floor(raster::ymin(extent) / 30),
                to = 30 * ceiling(raster::ymax(extent) / 30), by = 15) %>%
      subset(. %% 30 != 0)

    purrr::map2(lons, lats,
                ~ raster::getData("worldclim", path = cache_path, var = "tmin",
                                  res = resolution, lon = .x, lat = .y)) -> tmin
    purrr::map2(lons, lats,
                ~ raster::getData("worldclim", path = cache_path, var = "tmax",
                                  res = resolution, lon = .x, lat = .y)) -> tmax
    purrr::map2(lons, lats,
                ~ raster::getData("worldclim", path = cache_path, var = "prec",
                                  res = resolution, lon = .x, lat = .y)) -> prec

    # TODO: This is very slow. Use gdal instead?
    if (any(lapply(list(tmin, tmax, prec), length) > 1)) {
      if (!quiet) message("Merging raster tiles. This may take some time.")
    }
    tmin <- merge_if_needed(tmin)
    tmax <- merge_if_needed(tmax)
    prec <- merge_if_needed(prec)
  }

  # Clip to extent
  if (!quiet) message("Cropping WorldClim data to extent...")
  tmin <- raster::crop(tmin, extent)
  tmax <- raster::crop(tmax, extent)
  prec <- raster::crop(prec, extent)

  # Derive bioclimatic variables and return as tibble
  if (!quiet) message("Calculating bioclimatic variables...")
  bio <- dismo::biovars(prec, tmin, tmax)
  return(bio)
}

#' Merge Raster* objects (if necessary)
#'
#' Utility function for merging a list of Raster* objects. If passed a list of
#' length 1, simply extracts and returns the first element.
#'
#' @param rasters List of `Raster*` objects.
#'
#' @return
merge_if_needed <- function(rasters) {
  if (length(rasters) > 1) {
    do.call(raster::merge, rasters) %>%
      return()
  }
  else {
    return(rasters[[1]])
  }
}
