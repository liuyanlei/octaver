#' Run Octave
#'
#' @export
#' @examples
#' \dontrun{
#' oct("2+2")
#' }
oct <- function(code, args = character(), spinner = FALSE,
                    echo_cmd = FALSE, echo = FALSE,
                    timeout = Inf, wd = NULL, ...) {
  if (!interactive())
    spinner <- FALSE
  pr <- OctaveSession$new()
  pr$eval(code)
  on.exit(pr$kill(TRUE))

}

#' Run Octave script
#'
#' @export
#' @example
#'\dontrun{
#' oct_script("hello.m")
#' }
oct_script <- function(name) {
  pr <- OctaveSession$new()
  code <- paste0("run('", name, "')")
  pr$eval(code)
  on.exit(pr$kill(TRUE))
}
