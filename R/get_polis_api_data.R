#' Retrieve Data from POLIS API
#'
#' This function serves as a gateway to retrieve various types of health-related
#' data from the POLIS API. It simplifies the process of querying the API by
#' handling authentication, constructing the request URL, and iterating over
#' paginated results. The function is versatile, allowing for data retrieval
#' based on a range of parameters such as date range, data type, region, and
#' specific variables. It automates the handling of API responses, including
#' status checking and data aggregation, and returns the results in a
#' convenient data frame format. The function is designed to be robust,
#' providing informative error messages in case of missing API keys or
#' unsuccessful API calls.
#'
#' @param min_date Start date for data retrieval in 'YYYY-MM-DD' format.
#'                 Specifies the earliest date of the data to be fetched.
#'                 Required parameter.
#' @param max_date End date for data retrieval in 'YYYY-MM-DD' format.
#'                 Defaults to the current system date. Specifies the latest
#'                 date of the data to be fetched.
#' @param data_type Type of data to retrieve.
#'                  Supported types include 'cases', 'virus', 'population',
#'                  'env' (Environmental), 'geo' (Geographical), 'geo_synonym',
#'                  'im' (Independent Monitoring), 'activity', 'sub_activ'
#'                  (Sub-activities), and 'lqas' (Lot Quality Assurance
#'                  Sampling), lab_specimen (Human Specimen), lab_specimen_virus
#'                  (Human Specimen Viruses). Default is 'cases'.
#' @param region Region code for data filtering.
#'               Represents the WHO region from which to retrieve the data.
#'               Default is 'AFRO' (African Region).
#' @param select_vars Vector of variables to select from the API response.
#'                    If NULL (default), all variables are selected.
#' @param polis_api_key API key for authentication.
#'                        Default is retrieved from the environment variable
#'                        'POLIS_API_KEY'. An explicit API key can be provided
#'                        if required.
#'
#' @return A data frame containing the requested data aggregated from all pages
#'         of the API response. Each row represents a record, and columns
#'         correspond to the variables in the dataset.
#'
#' @examples
#' \dontrun{
#' data <- get_polis_api_data("2021-01-01", "2021-01-31", "cases", "AFRO")
#' }
#' @export

get_polis_api_data <- function(min_date,
                               max_date = Sys.Date(),
                               data_type = "cases",
                               region = "AFRO",
                               select_vars = NULL,
                               polis_api_key) {
  # API Endpoint and URL Construction
  api_endpoint <- "https://extranet.who.int/polis/api/v2/"
  endpoint_suffix <- get_api_date_suffix(data_type)$endpoint_suffix

  # set up the dates
  date_field <- get_api_date_suffix(data_type)$date_field

  # set up region field name
  region_field <- if (data_type == "virus") "RegionName" else "WHORegion"

  # Construct the full API URL
  api_url <- construct_api_url(
    api_endpoint, endpoint_suffix, min_date, max_date,
    date_field, region_field, region, select_vars
  )

  # all API iteratively
  response <- iterative_api_call(api_url, token = polis_api_key)

  # process API response
  full_data <- process_api_response(response)

  return(full_data)
}
