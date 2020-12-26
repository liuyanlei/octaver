os_type <- function() {
  .Platform$OS.type
}

#' @export
find_octave <- function() {
  x <- Sys.which("octave-cli")

  if (x == ""){
    stop("Couldn't find NodeJS.\nPlease provide its path manually.")
    return(NULL)
  } else {
    return(x)
  }
}


has_octave <- function() {

}

install_octave <- function() {

}

install_pkg <- function(update = TRUE) {

}


