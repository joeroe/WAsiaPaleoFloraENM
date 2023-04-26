# enm.R
# Ecological niche modelling functions
# Joe Roe <jwg983@hum.ku.dk>

#' Generate pseudo-absence points
#'
#' @param region  object of class `sf` or `sfc`. The region in which to generate
#'                pseudo-absence points.
#' @param ...     Name-value pairs of expressions to be added as fixed attributes
#'                of the pseudo-absences. See [dplyr::mutate()].
#' @param N       integer. Number of pseudo-absence points to generate.
#'
#' @return
#' @export
#'
#' @examples
generate_psabsences <- function(region, ..., N = 10000) {
  sf::st_sample(region, N) %>%
    as_tibble() %>%
    mutate(...) %>%
    return()
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
