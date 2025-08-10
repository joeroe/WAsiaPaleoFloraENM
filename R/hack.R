#' Workaround for broken slice.stars_proxy:
#' https://github.com/r-spatial/stars/issues/751
#' @export
hack = function(.data, ...) {
  collect_stars(.data, match.call(), "slice", ".data", env = parent.frame())
}

collect_stars = function(x, call, fn, args = "x", env, ...) {
  call_list = attr(x, "call_list") %||% list()
  dots = list(...)
  nd = names(dots)
  # I would say now to do
  # env = as.environment(append(as.list(env), dots)) -> but that didn't work.
  # so we iterate over ... :
  for (i in seq_along(dots))
    env[[ nd[i] ]] = dots[[i]]
  args = c(args, nd)
  # set function to call:
  lst = as.list(call)
  if (!missing(fn))
    lst[[1]] = as.name(fn)
  # set argument names:
  if (!missing(fn) && fn == "[") {
    lst[[2]] = as.name(args[1])
    lst[[3]] = as.name(args[2])
    for (i in seq_along(args)[-(1:2)]) {
      if (!args[i] %in% names(lst))
        lst[[ args[i] ]] = as.name(args[i]) # appends
    }
  } else {
    for (i in seq_along(args)) {
      lst[[i+1]] = as.name(args[i])
      names(lst)[[i+1]] = args[i]
    }
  }
  call = as.call(lst)
  environment(call) = env
  structure(x, call_list = c(call_list, call))
}
