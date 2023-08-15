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
#' of the accepted usage. Otherwise, `name`
#'
#' @export
gbif_accepted_name <- function(name) {
  gbif <- rgbif::name_backbone(name)
  if (gbif$matchType != "EXACT") NA_character_
  else if (gbif$synonym) name_usage(gbif$acceptedUsageKey)$data$canonicalName
  else gbif$canonicalName
}
