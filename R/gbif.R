# gbif.R
# Functions for working with data from the GBIF API

#' Accepted name of a taxon
#'
#' Resolves the accepted name of a given taxon according to the GBIF Backbone
#' Taxonomy.
#'
#' @param name Character. Name of a taxon.
#'
#' @return
#' If the GBIF Backbone Taxonomy considers `name` a synonym, the canonical name
#' of the accepted usage. Otherwise, `name`.
#'
#' @export
gbif_accepted_name <- function(name) {
  gbif <- rgbif::name_backbone(name)
  if (gbif$matchType != "EXACT") NA_character_
  else if (gbif$synonym) name_usage(gbif$acceptedUsageKey)$data$canonicalName
  else gbif$canonicalName
}

#' Acquire GBIF occurrence data for a given taxon
#'
#' @export
gbif_data <- function(scientificName, ...) {
  gbif_data <- rgbif::occ_data(scientificName = scientificName, ...)
  gbif_data$data
}

#' Clean GBIF data
#'
#' A collection of functions for cleaning occurrence data from GBIF.
#'
#' @param data Table of occurrence data retrieved with [rgbif::occ_data()]
#' @param threshold For `gbif_drop_imprecise_coords()`, the minimum acceptable
#'   coordinate uncertainty (in meters).
#' @param shorten If `TRUE`, `gbif_standardise_names()` shorten long column
#'   names in addition to converting them to snake case, e.g. `decimalLongitude`
#'   to `longitude`.
#'
#' @return
#' Modified version of `data`.
#'
#' @rdname gbif_clean
#' @export
gbif_drop_imprecise_coords <- function(data, threshold = 5000) {
  if (!"coordinateUncertaintyInMeters" %in% names(data)) return(data)
  dplyr::filter(data, .data$coordinateUncertaintyInMeters < threshold |
                  is.na(.data$coordinateUncertaintyInMeters))
}

#' @rdname gbif_clean
#' @export
gbif_drop_duplicate_coords <- function(data) {
  dplyr::distinct(data, .data$decimalLongitude, .data$decimalLatitude,
                  .keep_all = TRUE)
}

#' @rdname gbif_clean
#' @export
gbif_drop_fossils <- function(data) {
  dplyr::filter(data, .data$basisOfRecord != "FOSSIL_SPECIMEN")
}

#' @rdname gbif_clean
#' @export
gbif_standardise_names <- function(data, shorten = TRUE) {
  colnames(data) <- snakecase::to_snake_case(colnames(data))
  if (isTRUE(shorten)) data <- gbif_shorten_names(data)
  return(data)
}

#' @noRd
#' @keywords internal
gbif_shorten_names <- function(data) {
    dplyr::rename(
      data,
      longitude = "decimal_longitude",
      latitude = "decimal_latitude"
    )
}

#' Convert GBIF occurrence data to sf
#'
#' Converts occurrence data retrieved with [rgbif::occ_data()] to a
#' [sf::sf]-format simple features object with point geometry.
#'
#' Assumes that `data` has been pre-processed with [gbif_standardise_names()]
#' and does not include rows with missing coordinates.
#'
#' @param data Table of occurrence data retrieved with [rgbif::occ_data()]
#'
#' @return
#' An [sf::sf] object.
#'
#' @export
gbif_to_sf <- function(data) {
  sf::st_as_sf(data, coords = c("longitude", "latitude"),
               crs = 4326, remove = FALSE)
}
