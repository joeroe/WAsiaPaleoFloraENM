# enm.R
# Ecological niche modelling functions
# Joe Roe <jwg983@hum.ku.dk>

#' Generate pseudo-absence points
#'
#' @param region  The region in which to generate pseudo-absence points. Must be
#'                an object with an [sf::st_sample()] method, or an object
#'                coercible with [sf::st_bbox] (for much faster sampling from
#'                a rectangular bounding box).
#' @param ...     Name-value pairs of expressions to be added as fixed attributes
#'                of the pseudo-absences. See [dplyr::mutate()].
#' @param N       integer. Number of pseudo-absence points to generate.
#'
#' @return
#' An `sf` object containing `N` random points within `region`, with attributes
#' specified in `...`.
#'
#' @export
#'
#' @examples
background_sample <- function(region, N, coord_x = "x", coord_y = "y", ...) {
  if (inherits(region, c("sf", "sfc", "sfg"))) {
    bg_sample <- sample_sf(region, N, ...)
  }
  else {
    bg_sample <- sample_bbox(region, N, ...)
  }

  if (!is.na(coord_x)) {
    colnames(bg_sample)[colnames(bg_sample) == "X"] <- coord_x
  }
  if (!is.na(coord_y)) {
    colnames(bg_sample)[colnames(bg_sample) == "Y"] <- coord_y
  }

  bg_sample
}

#' @noRd
#' @keywords {internal}
sample_bbox <- function(region, N, ...) {
  region <- sf::st_bbox(region)
  data.frame(
    X = runif(N, region[["xmin"]], region[["xmax"]]),
    Y =  runif(N, region[["ymin"]], region[["ymax"]])
  ) |>
    sf::st_as_sf(coords = c("X", "Y"),
                 crs = sf::st_crs(region),
                 remove = FALSE) |>
    dplyr::mutate(...)
}

#' @noRd
#' @keywords {internal}
sample_sf <- function(region, N, ...) {
  points <- sf::st_sample(region, N)
  sf::st_sf(
    as.data.frame(sf::st_coordinates(points)),
    geometry = points
    ) |>
    dplyr::mutate(...)
}

#' @export
model_response <- function(occ, pred, polyn) {
  if(!raster::compareRaster(occ, pred)) {
    stop("Occurrence and predictor rasters must have the same extent, resolution, and projection.")
  }

  occ <- as.vector(occ)
  pred <- as.vector(pred)
  # poly() can't handle missing values, so trim where predictor variable is NA
  occ <- occ[!is.na(pred)]
  pred <- pred[!is.na(pred)]
  data <- data.frame(pred = pred, occ = occ)

  mod <- glm(occ ~ poly(pred, degree = polyn, raw = TRUE), family = "binomial",
             data = data, na.action = na.exclude, control = list(maxit = 100))

  return(mod)
}

#' Convert log-odds to probability
#'
#' @param x Numeric. Vector of log-odds, e.g. output of a logistic regression.
#'
#' @return Vector of normalised probabilities.
#' @export
logit_to_p <- function(x) {
  return(exp(x) / (1+exp(x)))
}
