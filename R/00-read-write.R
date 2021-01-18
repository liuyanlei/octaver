
assert_mat <- function(x) {
  is_valid_suffix <- endsWith(x, ".mat")
  if (!is_valid_suffix) {
    stop("This is not a proper mat file.", call. = FALSE)
  }
}

recode_msg <- function(msg, search, replace, default = msg) {
  idx <- vector(length = length(search))
  for (i in 1:length(search)) {
    idx[i] <- grepl(search[i], msg)
  }
  if (!any(idx)) {
    return(default)
  }
  replace[idx]
}

recode_msg_write <- function(x) {
  recode_msg(
    x,
    search = c("non-named", "duplicated"),
    replace = c("Non-named variable names.", "Duplicate variable names.")
  )
}

#' Reads a MAT file
#'
#'  This function is a soft-wrapper around \code{\link[R.matlab]{readMat}}.
#'
#' @importFrom R.matlab writeMat
#' @param matfile a MAT file
#' @param ... further arguments passe to \code{\link[R.matlab]{readMat}}.
#' @export
mat_write <- function(matfile, ...) {
  assert_mat(matfile)
  tryCatch(
    R.matlab::writeMat(con = matfile, ...),
    error = function(ex) {
      stop(recode_msg_write(ex$message), call. = FALSE)
    }
  )
}

#' Writes to a MAT file
#'
#'  This function is a soft-wrapper around \code{\link[R.matlab]{writeMat}}.
#'
#' @inheritParams mat_write
#' @param ... further arguments passe to \code{\link[R.matlab]{writeMat}}.
#' @importFrom R.matlab readMat.default
#' @export
mat_read <- function(matfile, ...) {
  assert_mat(matfile)
  R.matlab::readMat.default(con = matfile, ...)
}



# read nested struct mat file ---------------------------------------------


#' @rdname mat_read
mat_read2 <- function(matfile, ...) {
  assert_mat(matfile)
  clean_struct(R.matlab::readMat.default(con = matfile, ...))
}



# single function ---------------------------------------------------------

#' Clean the imported matlab .mat matrix
#'
#' @param x an imported *_results.mat file
#'
#' @importFrom purrr map_if
#'
#' @export
clean_struct <- function(x) {
  as.data.frame(drop(x$tmp))
}



