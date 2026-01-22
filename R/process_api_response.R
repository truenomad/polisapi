#' Process API Response
#'
#' This function processes the response from an API call. It extracts successful
#' responses and parses the JSON content, combining all pages of results into
#' a single data frame.
#'
#' @param response The response object from an API call made using the `httr2`
#'       package, typically from `iterative_api_call()`.
#'
#' @return A data frame containing the combined data from all response pages.
#'
#' @examples
#' \dontrun{
#' # Example usage within a function that makes API calls:
#' response <- iterative_api_call(api_url, token)
#' processed_response <- process_response(response)
#' }
#' @export

process_api_response <- function(response) {
  # extract the main data
  content <- response |>
    httr2::resps_successes() |>
    httr2::resps_data(\(resp) httr2::resp_body_json(resp)$value)

  dplyr::bind_rows(content)
}
