# browseURL("https://github.com/curso-r/stockfish/blob/master/R/fish.R")

#' @importFrom processx process
#'
#'
#' @examples
#' oct <- OctaveSession$new()
#' oct$state()
#'
#' oct$terminate()
#' oct$state()
#'
OctaveSession <- R6::R6Class(
  classname = "OctaveSession",

  # Public methods
  public = list(

    #' @field process Connection to `{processx}` process running the engine
    process = NULL,

    #' @field output String vector with the output of the last command
    output = NULL,

    #' @field log String vector with the all outputs from the engine
    log = NULL,

    #' @description Start Stockfish engine
    #'
    #' By default, this function uses the included version of Stockfish. If
    #' you want to run a more recent version, you can pass its executable as
    #' an argument. For more information, see the Bundled Stockfish section of
    #' this documentation.
    #'
    #' @param path Path to Stockfish executable (defaults to bundled version)
    initialize = function(path = NULL, ...) {

      # Check for user-supplied executable
      exe <- if (is.null(path)) find_octave() else path.expand(path)

      # Start process
      self$process <- processx::process$new(exe, stdin = "|", stdout = "|", stderr = "|", ...)

      # Record output
      self$process$poll_io(100)
      self$output <- self$process$read_output()
      self$log <- self$output
    },

    run = function(command, infinite = FALSE) {

      # Send command to engine
      self$process$write_input(paste0(command, "\n"))

      # If command is infinite, let it run without polling
      if (infinite) {
        return(NULL)
      }

      # Read from connection until process stops processing
      output <- c()
      while (TRUE) {

        # Poll IO and read output
        self$process$poll_io(500) # TODO make this an option
        tmp <- self$process$read_output()

        if (tmp == "") {
          break()
        }

        # Choose separator based on OS
        if (.Platform$OS.type == "windows") sep <- "\r\n" else sep <- "\n"

        # Parse output
        output <- c(output, strsplit(tmp, sep, perl = TRUE)[[1]])
        output <- paste0(output, collapse = "") # TODO handle output
      }

      # Update output field and the log
      self$output <- output
      self$log <- c(self$log, output)


      return(output)
    },

    kill = function() {
      self$process$kill()
      self$print()
    },
    terminate = function() {
      self$process$kill()
      self$print()
    },

    state = function() {
      if(self$process$is_alive()) {
        self$process$get_status()
      }else{
        self$print()
        invisible("terminated")
      }
    },

    #' @description Print information about engine process.
    #'
    #' @param ... Arguments passed on to `print()`
    print = function(...) {
      print(self$process, ...)
      # sapply(self$process, handle_res)
    }
  ),

  # Private methods
  private = list(

    # @description Kill engine when object is collected
    finalize = function() {
      tryCatch(
        self$run("quit"),
        error = function(err) { }
      )
    }
  )
)


handle_res <- function(res){
  cli::cat_line(res)
}




#' Repl octave
#'
#'
#' @importFrom cli cat_rule cat_line
#' @export
#'
#' @examples
#' OctaveREPL$new()
#' A = 1;
OctaveREPL <- R6::R6Class(
  "OctaveRepl",
  inherit = OctaveSession,
  public = list(
    np = NULL,
    initialize = function(
      bin = find_octave(),
      params = ""
    ){
      super$initialize(
        bin
      )
      self$np <- "octave > "
      cat_rule("Welcome to Octave REPL")
      cat_line("Press ESC to quit")

      # private$hist <- tempfile()
      # file.create(private$hist)

      self$prompt(
        self$np
      )
    },
    prompt = function(
      prompt
    ){
      # savehistory()
      # on.exit(loadhistory())

      repeat {
        # loadhistory(
        #   private$hist
        # )
        x <- readline(self$np)
        # write(x, private$hist, append = TRUE)

        self$process$write_input(paste0(x, "\n"))

        self$process$poll_io(500)
        res <- self$process$read_output()


        while (length(res) == 0) {
          Sys.sleep(0.1)
          res <- self$process$read_output()
        }
        np <- res#[length(res)]
        bod <- res#[-length(res)]
        if (!grepl("\\.\\.\\.", np)) {
          sapply(bod, handle_res)
          self$np <- paste("octave >")
        } else {
          self$np <- np
        }
      }
    }
  ),
  private = list(
    hist = NULL
  )
)

