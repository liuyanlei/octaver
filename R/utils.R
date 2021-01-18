set_envvar <- function(envs) {
  if (length(envs) == 0) return()

  stopifnot(is.named(envs))

  old <- Sys.getenv(names(envs), names = TRUE, unset = NA)
  set <- !is.na(envs)

  both_set <- set & !is.na(old)

  if (any(set))  do.call("Sys.setenv", as.list(envs[set]))
  if (any(!set)) Sys.unsetenv(names(envs)[!set])

  invisible(old)
}

with_envvar <- function(new, code) {
  old <- set_envvar(new)
  on.exit(set_envvar(old))
  force(code)
}

`%||%` <- function(l, r) if (is.null(l)) r else l


update_history <- function(cmd) {
  tmp <- tempfile("octaver-hst-")
  on.exit(unlink(tmp, recursive = TRUE))
  utils::savehistory(tmp)
  cat(cmd, "\n", sep = "", file = tmp, append = TRUE)
  utils::loadhistory(tmp)
}


