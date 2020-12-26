

.onAttach <- function(libname, pkgname){
  setHook(packageEvent("octaver", "attach"), function(...) {
    set_octave_engine()
  })
}

.onDetach <- function(libpath) {
  setHook(packageEvent("octaver", "attach"), NULL, "replace")
}

#' Knitr engine for Octave
#'
#' @param bin path to bin
#' @export
set_octave_engine <- function(
  bin = find_octave()
){
  knitr::opts_chunk$set(
    octave = octaver::OctaveSession$new(bin = bin)
  )
  knitr::knit_engines$set(octave = function(
    options
  ) {
    if (options$eval) {
      out <- c()
      for (i in options$code){
        out <- c(out, options$octave$eval(i))
      }
    }
    knitr::engine_output(options, options$code, out)
  })
}
