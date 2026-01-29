#' Try API Call with Retry Logic
#'
#' This function attempts to make an API call to a specified URL using the GET
#' method. It includes a retry mechanism, where the request is attempted up to a
#' specified number of times (`max_attempts`) before giving up. If the request
#' is successful and returns a 200 status code, the response is returned. If any
#' errors occur or if a non-200 status code is received, the function will wait
#' for 5 seconds and retry the request. After the maximum number of attempts, if
#' the request still fails, the function stops with an error message.
#'
#' @param url The URL for the API endpoint to which the GET request is made.
#' @param token The authorization token required for the API request.
#' @param max_attempts The maximum number of attempts to make the API call.
#'        Default is 3 attempts.
#' @param show_progress Logical. If TRUE, displays a progress bar across
#'        iterative requests; if FALSE, suppresses progress.
#'
#' @return The response from the API call if successful, or an error message
#'         if all attempts fail.
#'
#' @examples
#' \dontrun{
#' iterative_api_call("https://api.example.com/data", "your_api_token")
#' }
#' @export

iterative_api_call <- function(url, token = NULL, max_attempts = 3, show_progress = TRUE) {
  # Configure the initial request
  req <- httr2::request(url) |>
    httr2::req_headers(`authorization-token` = token) |>
    httr2::req_retry(max_tries = max_attempts) |>
    httr2::req_progress()

  # Checking that the API call is valid
  resp <- req |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform()

  # check status of call
  check_status_api(
    httr2::resp_status(resp)
  )

  # Perform iterative requests with a lambda function for next_req
  httr2::req_perform_iterative(
    req,
    next_req = \(req, resp) {
      next_link <- httr2::resp_body_json(resp)[["@odata.nextLink"]]
      if (is.null(next_link)) {
        return(NULL)
      }
      req |> httr2::req_url(next_link)
    },
    max_reqs = Inf,
    progress = if (isTRUE(show_progress)) list(
      name = "Downloading POLIS pages:",
      clear = TRUE
    ) else NULL
  )
}
