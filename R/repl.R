
#' Repl octave
#'
#' @export
OctaveREPL <- R6::R6Class(
  "OctaveRepl",
  inherit = OctaveSession,
  public = list(
    np = NULL,
    initialize = function(
      bin = "C:/Octave/Octave-5.1.0.0/mingw64/bin/octave-cli-5.1.0.exe",
      params = ""
    ){
      super$initialize(
        bin
      )
      self$np <- "octave > "
      cat_rule("Welcome to Octave REPL")
      cat_line("Press ESC to quit")

      private$hist <- tempfile()
      file.create(private$hist)

      self$prompt(
        self$np
      )
    },
    prompt = function(
      prompt
    ){
      savehistory()
      on.exit(loadhistory())

      repeat {
        loadhistory(
          private$hist
        )
        x <- readline(self$np)
        write(x, private$hist, append = TRUE)
        process_write(self$handle, paste(x, "\n\n"))
        res <- process_read(self$handle, PIPE_STDOUT, timeout = 0)
        while (length(res) == 0) {
          Sys.sleep(0.1)
          res <- process_read(self$handle, PIPE_STDOUT, timeout = 0)
        }
        np <- res #length(res)
        bod <- res#[-length(res)]
        np <- gsub("> >", ">", np)
        self$np <- res
        # if (!grepl("\\.\\.\\.", np)){
        #   sapply(bod, handle_res)
        #   self$np <- paste("node", np)
        # } else {
        #   self$np <- np
        # }
      }
    }
  ),
  private = list(
    hist = NULL
  )

)
