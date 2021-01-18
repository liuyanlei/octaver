os_type <- function() {
  .Platform$OS.type
}

is_windows <- function () {
  unname(Sys.info()["sysname"] == "Windows")
}


has_IP <- function () {
  if (.Platform$OS.type == "windows") {
    ipmessage <- system("ipconfig", intern = TRUE)
  }
  else {
    ipmessage <- system("ifconfig", intern = TRUE)
  }
  validIP <- "((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)[.]){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
  any(grep(validIP, ipmessage))
}


system_path <- function ()  {
  strsplit(shell("echo %PATH% ", intern = TRUE), ";")[[1]]
}


# octave ------------------------------------------------------------------

#' @export
find_octave <- function(cli = TRUE) {

  if(isTRUE(cli)) {
    x <- Sys.which("octave-cli")
  }else{
    x <- Sys.which("octave")
  }

  if (x == ""){
    stop("Couldn't find Octave.\nPlease provide its path manually.")
    return(NULL)
  } else {
    return(x)
  }
}


has_octave <- function(cli = TRUE) {
  if(isTRUE(cli)) {
    x <- Sys.which("octave-cli")
  }else{
    x <- Sys.which("octave")
  }
  if(x == ""){
    return(FALSE)
  }
  TRUE
}


