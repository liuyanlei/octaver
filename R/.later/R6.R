
#' importFrom subprocess spawn_process process_read process_write PIPE_STDOUT
#' importFrom subprocess process_state process_kill
#' Octave Session
#'
#' Launch a Octave Session
#'
#' @export
OctaveSession <- R6::R6Class(
  "OctaveSession",
  public = list(
    bin = NULL,
    initialize = function(
      bin = find_octave(),
      params = "",
      ...
    ){
      self$bin <- bin
      self$handle <- subprocess::spawn_process(bin, params)
      subprocess::process_read(self$handle, subprocess::PIPE_STDOUT, timeout = 5000)
    },
    finalize = function(){
      self$kill()
    },
    eval = function(code, wait = TRUE, print = TRUE){
      subprocess::process_write(self$handle, paste(code, "\n"))
      res <- subprocess::process_read(self$handle, subprocess::PIPE_STDOUT, timeout = 0)
      if (wait) {
        while (length(res) == 0) {
          Sys.sleep(0.1)
          res <- subprocess::process_read(self$handle, subprocess::PIPE_STDOUT, timeout = 0)
        }
        if (print) {
          sapply(res, handle_res)
        }
        return(invisible(res))
      }
    },
    state = function(){
      subprocess::process_state(self$handle)
    },
    terminate = function(){
      if (self$state() != "terminated"){
        process_terminate(self$handle)
      } else {
        cli::cat_line("Process not running:")
        self$state()
      }

    },
    kill = function(){
      if (self$state() != "terminated") {
        subprocess::process_kill(self$handle)
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

