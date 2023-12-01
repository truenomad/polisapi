#' Process API Response
#'
#' This function processes the response from an API call. It checks the status
#' code of the response; if the status code is 200, indicating a successful
#' response, it parses the content of the response using.
#'
#' @param response The response object from an API call made using the `httr2`
#'       package.
#'
#' @return A `dataframe`, which is the parsed data from the response If the
#'         response is unsuccessful, both elements of the list are NULL.
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
