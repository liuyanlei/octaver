

#' Repl octave
#'
#'
#' @importFrom cli cat_rule cat_line
#' @export
#'
#' @examples
#' \dontrun{
#' OctaveREPL$new()
#' A = 1;
#' A
#' }
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
      cat_rule(left = "Welcome to Octave REPL", right = "Press ESC to quit")

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
        write(x, private$hist, append = TRUE)

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
