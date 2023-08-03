#' Burn points into a raster
#'
#' @param points `sf`.
#' @param raster
#'
#' @return
#' @export
#'
#' @examples
raster_burn <- function(points, raster) {
  points %>%
    sf::as_Spatial() %>%
    raster::rasterize(raster, field = 1, background = 0) %>%
    raster::mask(raster) %>%
    return()
}

#' Buffer a bounding box
#'
#' @add Value to expand the bounding box by, in map units.
#'
#' @export
#'
#' @examples
#' w_asia <- st_bbox(c(xmin = 30, xmax = 50, ymin = 25, ymax = 40))
#' buffer_bbox(w_asia, 10)
buffer_bbox <- function(bbox, add) {
  sf::st_bbox(c(
    xmin = bbox[["xmin"]] - add,
    xmax = bbox[["xmax"]] + add,
    ymin = bbox[["ymin"]] - add,
    ymax = bbox[["ymax"]] + add
  ))
}
