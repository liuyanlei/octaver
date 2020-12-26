oct_run <- function(code, args = character(), spinner = FALSE,
                    echo_cmd = FALSE, echo = FALSE,
                    timeout = Inf, wd = NULL, ...) {
  if (!interactive())
    spinner <- FALSE
  pr <- OctaveSession$new()

  pr$eval("A")
  pr$eval("pkg list")
  pr$kill()
  # if (echo) {
  #   stdout_callback <- echo_callback(stdout_callback, "stdout")
  #   stderr_callback <- echo_callback(stderr_callback, "stderr")
  # }
  # runcall <- sys.call()
  # resenv <- new.env(parent = emptyenv())


  pr$eval(code)
  on.exit(pr$kill())
  # if (error_on_status && (is.na(res$status) || res$status != 0)) {
  #   "!DEBUG run() error on status `res$status` for process `pr$get_pid()`"
  #   throw(new_process_error(res, call = sys.call(), echo = echo,
  #                           stderr_to_stdout, res$status, command = command,
  #                           args = args))
  # }
}
