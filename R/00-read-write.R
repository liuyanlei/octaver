
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


#' @importFrom stringr str_remove word
#' @importFrom stringi stri_remove_empty
#' @importFrom rlang set_names
#' @importFrom utils capture.output
set_names_co <- function(x) {

  options(max.print=999999)
  on.exit(options(max.print = 100))

  nm <- capture.output(x) %>%
    word(1, 1) %>%
    str_remove(",") %>%
    stringi::stri_remove_empty(x = .)

  if (is.null(names(x))) {
    set_names(x, nm) %>%
      drop()
  }else{
    x
  }
}

# predicate ---------------------------------------------------------------

is_empty_obj <- function(x) {
  if ((is.list(x) || is.numeric(x)) && length(x) == 0) TRUE else FALSE
}

#' @importFrom purrr map_lgl
has_empty_obj <- function(x) {
  all(lapply(x, is_empty_obj))
}

# Cleaning ----------------------------------------------------------------

clean_empty <- function(x) {
  x %>%
    map_if(has_empty_obj,  ~ NULL) %>%
    map_if(is_empty_obj, ~ NULL)
}

#' @importFrom purrr compose map map_if is_character
#' @importFrom stringr str_trim
clean_sublist <-
  purrr::compose(
    set_names_co,
    ~ map(.x, drop),
    ~ map_if(.x, is_character, str_trim),
    clean_empty
  )

# single function ---------------------------------------------------------

#' Clean the imported matlab .mat matrix
#'
#' @param x an imported *_results.mat file
#'
#' @importFrom purrr map_if
#'
#' @export
clean_struct <- function(x) {

  nm <- names(x)
  x %>%
    clean_empty() %>%
    map_if(~ !is.null(.x), set_names_co) %>%
    # set_names(gsub('\\.$', '', names(.))) %>% # remove trailing dots
    # top level -  change dots to underscores
    set_names(gsub("\\.", "\\_", names(.))) %>%
    # 1st level
    # map(~ set_names(gsub("\\.", "\\_", names(.x)))) %>%
    map_if(~ !is.null(.x), clean_sublist)
}



