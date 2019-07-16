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
