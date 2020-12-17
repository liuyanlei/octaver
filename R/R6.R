# Sys.which("octave-cli")
# bin <- "C:/Octave/Octave-5.1.0.0/mingw64/bin/octave-cli-5.1.0.exe"
# px <- processx::process$new(bin, args = c("--eval", "2+2"), stdout = "|")
# px$read_output()
# https://octave.org/doc/v4.2.1/Command-Line-Options.html

find_octave <- function() {
  Sys.which("octave-cli")
}


#' importFrom subprocess spawn_process process_read process_write PIPE_STDOUT
#' importFrom subprocess process_state process_kill


#' Octave Session
#'
#' Launch a NodeJS Session
#'
#' @export
OctaveSession <- R6::R6Class(
  "OctaveSession",
  public = list(
    bin = NULL,
    handle = NULL,
    initialize = function(
      bin = find_octave(),
      params = "",
      ...
    ){
      self$bin <- bin
      self$handle <- spawn_process(bin, params)
      process_read(self$handle, PIPE_STDOUT, timeout = 5000)
    },
    finalize = function(){
      self$kill()
    },
    eval = function(code, wait = TRUE, print = TRUE){
      process_write(self$handle, paste(code, "\n"))
      res <- process_read(self$handle, PIPE_STDOUT, timeout = 0)
      if (wait) {
        while (length(res) == 0) {
          Sys.sleep(0.1)
          res <- process_read(self$handle, PIPE_STDOUT, timeout = 0)
        }
        if (print) {
          sapply(res, handle_res)
        }
        return(invisible(res))
      }
    },
    state = function(){
      process_state(self$handle)
    },
    kill = function(){
      if (self$state() != "terminated") {
        process_kill(self$handle)
      } else {
        cli::cat_line("Process not running:")
        self$state()
      }
    }
  )
)

handle_res <- function(res){
  if (res == "undefined") {
    res <- crayon::blue(res)
  }
  cli::cat_line(res)
}

#' Repl octave
#'
#'
#' @importFrom cli cat_rule cat_line
#' @export
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
        process_write(self$handle, paste(x, "\n\n"))
        res <- process_read(self$handle, PIPE_STDOUT, timeout = 0)
        while (length(res) == 0) {
          Sys.sleep(0.1)
          res <- process_read(self$handle, PIPE_STDOUT, timeout = 0)
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

