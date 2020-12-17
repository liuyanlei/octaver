

# p <- processx::process$new("octave-cli", stdin = "|", stdout = "|", stderr = "|")


# p$is_alive()
# p$write_input("1")
#
# p$read_output_lines()
# p$read_all_output()


# run_octave <- function(options) {
#
#   oldwd <- getwd()
#   setwd(options$wd)
#   on.exit(setwd(oldwd), add = TRUE)
#
#   ## We redirect stderr to stdout if either of these are true:
#   ## - stderr is the string "2>&1"
#   ## - both stdout and stderr are non-null, and they are the same
#   stderr_to_stdout <- with(
#     options,
#     (!is.null(stderr) && stderr == "2>&1") ||
#       (!is.null(stdout) && !is.null(stderr) && stdout == stderr)
#   )
#
#   res <- with(
#     options,
#     with_envvar(
#       env,
#       do.call(processx::run, c(list(
#         bin, args = real_cmdargs,
#         stdout_line_callback = real_callback(stdout),
#         stderr_line_callback = real_callback(stderr),
#         stdout_callback = real_block_callback,
#         stderr_callback = real_block_callback,
#         stderr_to_stdout = stderr_to_stdout,
#         echo_cmd = echo, echo = show, spinner = spinner,
#         error_on_status = fail_on_status, timeout = timeout),
#         extra)
#       )
#     )
#   )
#
#   res$command <- c(options$bin, options$real_cmdargs)
#   res
# }
#
# convert_and_check_my_args <- function(options) {
#
#   has <- function(x) x %in% names(options)
#   no <- function(x) ! has(x)
#
#   ## Conversions
#   options <- within(options, {
#     if (has("libpath")) libpath <- as.character(libpath)
#     if (has("repos")) repos <- repos
#     if (has("stdout") && !is.null(stdout)) {
#       stdout <- as.character(stdout)
#     }
#     if (has("stderr") && !is.null(stderr)) {
#       stderr <- as.character(stderr)
#     }
#     if (has("error")) error <- error[1]
#     if (has("cmdargs")) cmdargs <- as.character(cmdargs)
#     if (has("timeout") && !inherits(timeout, "difftime")) {
#       timeout <- as.difftime(
#         as.double(timeout),
#         units = "secs"
#       )
#     }
#     if (no("wd")) wd <- "."
#     if (no("echo")) echo <- FALSE
#     if (no("fail_on_status")) fail_on_status <- FALSE
#     if (no("tmp_files")) tmp_files <- character()
#   })
#
#   ## Checks
#   with(options, stopifnot(
#     no("func") || is.function(func),
#     no("func") || is.list(args),
#     is.character(libpath),
#     no("stdout") || is.null(stdout) || is_string(stdout),
#     no("stderr") || is.null(stderr) || is_string(stderr),
#     no("error") || is_string(error),
#     is.character(cmdargs),
#     no("echo") || is_flag(echo),
#     no("show") || is_flag(show),
#     no("callback") || is.null(callback) || is.function(callback),
#     no("block_callback") || is.null(block_callback) ||
#       is.function(block_callback),
#     no("spinner") || is_flag(spinner),
#     is_flag(system_profile),
#     is_flag(user_profile) || identical(user_profile, "project"),
#     is.character(env),
#     no("timeout") || (length(timeout) == 1 && !is.na(timeout)),
#     no("wd") || is_string(wd),
#     no("fail_on_status") || is_flag(fail_on_status)
#   ))
#
#   options
# }
#
#
# r <- function(func, args = list(), libpath = .libPaths(),
#               repos = default_repos(),
#               stdout = NULL, stderr = NULL,
#               poll_connection = TRUE,
#               error = getOption("callr.error", "error"),
#               cmdargs = c("--slave", "--no-save", "--no-restore"),
#               show = FALSE, callback = NULL,
#               block_callback = NULL, spinner = show && interactive(),
#               system_profile = FALSE, user_profile = "project",
#               env = rcmd_safe_env(), timeout = Inf, ...) {
#
#   ## This contains the context that we set up in steps
#   options <- convert_and_check_my_args(as.list(environment()))
#   options$extra <- list(...)
#   # options$load_hook <- default_load_hook()
#
#   ## This cleans up everything...
#   on.exit(unlink(options$tmp_files, recursive = TRUE), add = TRUE)
#
#   options <- setup_script_files(options)
#   options <- setup_context(options)
#   options <- setup_callbacks(options)
#   options <- setup_r_binary_and_args(options)
#
#   out <- run_r(options)
#
#   get_result(output = out, options)
# }
