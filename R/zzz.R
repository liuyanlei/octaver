.globals <- new.env(parent = emptyenv())

.pkgenv <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {

  has_subprocess <- requireNamespace("subprocess", quietly = TRUE)
  .pkgenv[["has_subprocess"]] <- has_subprocess

  # if (!has_subprocess())
  #   install_subprocess()

  repos <- getOption("repos")
  repos["kvasilopoulos"] = "https://kvasilopoulos.github.io/drat/"
  options(repos = repos)

  invisible()
}


install_subprocess <- function() {
  install.packages(
    'subprocess',
    repos = 'https://kvasilopoulos.github.io/drat/',
    type = 'source')
}

has_subprocess <- function() {
  .pkgenv$has_subprocess
}

need_subprocess <- function() {
  if (!has_subprocess()) {
    stop_glue(
      " To install run 'install_subprocess()'.")
  }
}
