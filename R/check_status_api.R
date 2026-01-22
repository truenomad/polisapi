#' Check Status of API Response
#'
#' This function checks the API response status code. It handles various HTTP
#' status codes by providing specific error messages. It returns `TRUE` for
#' successful responses (status code 200). For error conditions like 400, 403,
#' 500, etc., it stops execution with an error message, aiding in debugging and
#' issue diagnosis.
#'
#' @param response_status_code The HTTP status code from the API response.
#'
#' @return `TRUE` for a successful response (status code 200). If the status
#'         code indicates an error (e.g., 400, 403, 500), the function stops
#'         and returns a specific error message.
#'
#' @examples
#' \dontrun{
#' response <- check_status_api(300)
#' }
#' @export

check_status_api <- function(response_status_code) {
  code <- httpcode::http_code(response_status_code)

  if (code$status_code != 200) {
    cli::cli_abort(
      glue::glue(
        "{code$status_code}: {code$explanation}",
        "\n For a full explanation of this error call: ",
        "httpcode::http_code({code$status_code}, verbose = TRUE)"
      )
    )
  }


  invisible(TRUE)
}
