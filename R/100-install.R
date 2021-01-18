
#' Install Octave
#'
#' @export
install_octave <- function(keep_install_file = FALSE, download_dir = tempdir(), silent = FALSE, ...) {
  url <- "https://ftpmirror.gnu.org/octave/windows/octave-6.1.0-w64-installer.exe"
  if (silent) {
    installer_option <- "/SILENT"
  }else {
    installer_option <- NULL
  }
  is_installed <- install_url(
    url, keep_install_file = keep_install_file,
    download_dir = download_dir, installer_option = installer_option,
    ...
  )
  if (!did_R_install)
    return(FALSE)

  return(TRUE)
}



install_url <- function(
  url = NULL,
  keep_install_file = FALSE, wait = TRUE, download_dir = tempdir(),
  message = TRUE, installer_option = NULL, download_fun = download.file, ...
) {
  if(!has_IP())
    stop("No Internet Access.", call. = FALSE)

  if(is.null(url))
    stop("Must provide a URL.")

  exe_filename <- file.path(download_dir, basename(url))
  tryCatch(
    download_fun(url, destfile = exe_filename, quiet = FALSE, mode = 'wb'),
    error = function(e) {
      return(invisible(FALSE))
    })

  if(file.exists(exe_filename)) {
    if(message)
      cat("\nThe file was downloaded successfully into:\n", exe_filename, "\n")
  } else {
    if(message)
      cat("\nInstallation failed)\n")
    return(invisible(FALSE))
  }

  if (message)
    cat("\nRunning the installer now...\n")
  if (!is.null(installer_option)) {
    install_cmd <- paste(exe_filename, installer_option)
  }else {
    install_cmd <- exe_filename
  }
  if (is_windows()) {
    shell_output <- shell(install_cmd, wait = wait, ...)
  }else {
    shell_output <- system(install_cmd, wait = wait, ...)
  }

  if(!keep_install_file) {
    if(message)
      cat("\nInstallation status: ", shell_output == 0 ,". Removing the file:\n", exe_filename, "\n")
    unlink(exe_filename, force = TRUE)
  }

  return(TRUE)
}

#' Install Octave pkgs
#'
#'
#' @export
install_pkg <- function(update = TRUE) {

}
