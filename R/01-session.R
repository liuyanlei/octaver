# browseURL("https://github.com/curso-r/stockfish/blob/master/R/fish.R")

#' @importFrom processx process
#'
#'
#'
#' @export
#' @examples
#' oct <- OctaveSession$new()
#' oct$state()
#'
#' oct$eval("2+2")
#' oct$eval("A = 2+2; B = 2;")
#' oct$eval("A")
#' oct$eval("B")
#'
#' oct$terminate()
#' oct$state()
#'
OctaveSession <- R6::R6Class(
  classname = "OctaveSession",

  # Public methods
  public = list(

    #' @field Path to Octave bin directory.
    bin = NULL,

    #' @field process Connection to `{processx}` process running the engine
    process = NULL,

    #' @field output String vector with the output of the last command
    output = NULL,

    #' @field log String vector with the all outputs from the engine
    log = NULL,

    #' @description Start Octave engine
    #'
    #' @param bin Path to Octave bin directory, if \code{NULL} then octaver
    #' attemtpts to find the directory with \code{\link{find_octave}}.
    #' @param params Additional parameters to pass to the initialisation. More
    #' details \url{https://octave.org/doc/v4.2.0/Command-Line-Options.html}.
    #' @param ... further arguments passed to \code{\link{processx::process$new}}
    initialize = function(bin = NULL, params = character(), wait = TRUE, wait_timeout = 3000, ...) {

      # Check for user-supplied executable
      # bin <- if (is.null(bin)) find_octave() else path.expand(bin)
      # self$bin <- bin
      #
      # # Start process
      # self$process <- processx::process$new(bin, args = params, stdin = "|", stdout = "|", stderr = "|", ...)
      #
      # # Record output
      # self$process$poll_io(100)
      # self$output <- self$process$read_output()
      # self$log <- self$output
      # invisible(self)
      oct_init(self, private, bin, params, wait, wait_timeout,...)
    },

    eval = function(code, strip = FALSE, wait = TRUE, print = TRUE) {

      # Send code to engine
      self$process$write_input(paste0(code, "\n"))

      # Read from connection until process stops processing
      output <- c()
      while (TRUE) {

        # Poll IO and read output
        self$process$poll_io(0)
        tmp <- self$process$read_output()

        if (tmp == "") {
          break()
        }

        # Choose separator based on OS
        if (.Platform$OS.type == "windows") sep <- "\r\n" else sep <- "\n"

        # Parse output
        output <- c(output, tmp) #strsplit(tmp, sep, perl = TRUE)[[1]])
        # output <- paste0(output, collapse = "\n") # TODO handle output
      }

      # Update output field and the log
      self$output <- output
      self$log <- c(self$log, output)

      cat(output)
      return(invisible(output))
    },

    get_state = function()
      oct_get_state(self, private),


    #' @details
    #' Create Octave objects
    #'
    #' @param name Name of variable to create.post
    #' @param value Value to assign to variable.
    #' @param type Type of variable to define.
    #'
    #' @examples
    #' \dontrun{
    #' n <- OctaveSession$new()
    #' n$assign(carz, cars)
    #' n$get(carz)
    #' }
    assign = function(name, value){

      if(missing(name))
        stop("Missing `name`", call. = FALSE)
      if(missing(value))
        stop("Missing `value`", call. = FALSE)

      quo_name <- enquo(name)
      name <- as_label(quo_name)

      json_fs <- as_json_file(name, value, type) # write temp file
      self$eval(json_fs$call, print = FALSE) # read temp file
      unlink(json_fs$tempfile, force = TRUE) # delete temp file


      json <- as_json_string(name, value, type)
      self$eval(json, print = FALSE)

      invisible(self)
    },


    kill = function() {
      self$process$kill()
      self$print()
    },
    terminate = function() {
      self$process$kill()
      self$print()
    },

    # state = function() {
    #   if(self$process$is_alive()) {
    #     self$process$get_status()
    #   }else{
    #     "terminated"
    #   }
    # },

    #' @description Print information about engine process.
    #'
    #' @param ... Arguments passed on to `print()`
    print = function(...) {
      cat(
        sep = "",
        "Octave Session, ",
        if (self$process$is_alive()) {
          paste0("alive, ", self$get_state(), ", ")
        } else {
          "finished, "
        },
        "pid ", self$process$get_pid(), ".\n")
      invisible(self)
    },

    finalize = function() {
      unlink(private$tmp_output_file)
      unlink(private$tmp_error_file)
      unlink(private$options$tmp_files, recursive = TRUE)
    }

  ),



  # Private methods
  private = list(

    options = NULL,
    state = NULL,
    started_at = NULL,
    pipe = NULL,

    tmp_output_file = NULL,
    tmp_error_file = NULL

    # # @description Kill engine when object is collected
    # finalize = function() {
    #   tryCatch(
    #     self$run("quit"),
    #     error = function(err) { }
    #   )
    # }
  )
)


handle_res <- function(res){
  cli::cat_line(res)
}

oct_init <- function(self, private, bin, params, wait, wait_timeout, ...) {

  bin <- if (is.null(bin)) find_octave() else path.expand(bin)
  self$bin <- bin

  ## Make child report back when ready
  # private$report_back(201, "ready to go")

  # Start process
  self$process <- processx::process$new(bin, args = params, stdin = "|", stdout = "|", stderr = "|", ...)
  self$output <- self$process$read_output()
  self$log <- self$output

  # private$pipe <- self$process$get_poll_connection()
  private$started_at <- Sys.time()
  private$state <- "starting"

  if (wait) {
    timeout <- wait_timeout
    have_until <- Sys.time() + as.difftime(timeout / 1000, units = "secs")
    pr <- self$process$poll_io(timeout)
    out <- ""
    err <- ""
    while (any(pr == "ready")) {
      if (pr["output"] == "ready") out <- paste0(out, self$process$read_output())
      if (pr["error"] == "ready") err <- paste0(err, self$process$read_error())
      if (pr["process"] == "ready") break
      timeout <- as.double(have_until - Sys.time(), units = "secs") * 1000
      pr <- self$process$poll_io(as.integer(timeout))

    }

    if (pr["process"] == "ready") {
      msg <- self$read()
      out <- paste0(out, msg$stdout)
      err <- paste0(err, msg$stderr)
      if (msg$code != 201) {
        data <- list(
          status = self$process$get_exit_status(),
          stdout = out,
          stderr = err,
          timeout = FALSE
        )
        # throw(new_callr_error(data, "Failed to start R session"))
      }
    } else if (pr["process"] != "ready") {
      # cat("stdout:]\n", out, "\n")
      # cat("stderr:]\n", err, "\n")
      # throw(new_error("Could not start R session, timed out"))
    }
  }

  invisible(self)
}

oct_get_state <- function(self, private) {
  private$state
}
