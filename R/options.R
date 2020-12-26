
r_session_options <- function(...) {
  update_options(r_session_options_default(), ...)
}

update_options <- function(old_opts, ...) {
  new_opts <- list(...)
  stopifnot(is.named(new_opts))
  check_for_option_names(old_opts, new_opts)
  utils::modifyList(old_opts, new_opts)
}

check_for_option_names <- function(old, new) {
  if (length(miss <- setdiff(names(new), names(old)))) {
    throw(new_error("Unknown option", if (length(miss) > 1) "s", ":",
                    enumerate(sQuote(miss))))
  }
}

r_process_options_default <- function() {
  list(
    func = NULL,
    args = list(),
    libpath = .libPaths(),
    repos = default_repos(),
    stdout = "|",
    stderr = "|",
    poll_connection = TRUE,
    error = getOption("callr.error", "error"),
    cmdargs = c("--slave", "--no-save", "--no-restore"),
    system_profile = FALSE,
    user_profile = "project",
    env = character(),
    supervise = FALSE,
    load_hook = default_load_hook(),
    extra = list(),
    package = FALSE
  )
}

r_session_options_default <- function() {
  list(
    func = NULL,
    args = NULL,
    libpath = .libPaths(),
    repos = default_repos(),
    stdout = NULL,
    stderr = NULL,
    error = getOption("callr.error", "error"),
    cmdargs = c(
      if (os_platform() != "windows") "--no-readline",
      "--slave",
      "--no-save",
      "--no-restore"
    ),
    system_profile = FALSE,
    user_profile = "project",
    env = c(TERM = "dumb"),
    supervise = FALSE,
    load_hook = NULL,
    extra = list()
  )
}


