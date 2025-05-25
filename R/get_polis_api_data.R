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
#'                  Sampling), 'lab_specimen' (Human Specimen),
#'                  'lab_env' (Environmental Sample), 'lab_specimen_virus'
#'                  (Human Specimen Viruses). Default is 'cases'.
#' @param region Region code for data filtering.
#'               Represents the WHO region from which to retrieve the data.
#'               Possible values are AFRO; AMRO; EMRO; EURO; SEARO; WPRO Use
#'               'Global' to retrieve global data. Default is 'AFRO'.
#' @param country_code ISO3 country code to filter the data. Default is NULL.
#' @param select_vars Vector of variables to select from the API response.
#'                    If NULL (default), all variables are selected.
#' @param polis_api_key API key for authentication.
#'                        Default is retrieved from the environment variable
#'                        'POLIS_API_KEY'. An explicit API key can be provided
#'                        if required.
#' @param log_results Logical indicating whether to log the results of the API
#' @param log_file_path Path to the directory where the log file will be saved
#' @param updated_dates Logical indicating whether to use the 'LastUpdateDate'
#' @return A data frame containing the requested data aggregated from all pages
#'         of the API response. Each row represents a record, and columns
#'         correspond to the variables in the dataset.
#'
#' @examples
#' \dontrun{
#' data <- get_polis_api_data("2020-01-01", "2021-01-31", "cases", "AFRO")
#' }
#' @export

get_polis_api_data <- function(min_date = "2021-01-01",
                               max_date = Sys.Date(),
                               data_type = "cases",
                               region = "AFRO",
                               country_code = NULL,
                               select_vars = NULL,
                               updated_dates = FALSE,
                               polis_api_key,
                               log_results = FALSE,
                               log_file_path) {

  # API Endpoint and URL Construction
  api_endpoint <- "https://extranet.who.int/polis/api/v2/"
  endpoint_suffix <- get_api_date_suffix(data_type)$endpoint_suffix

  # set up the dates
  if (updated_dates) {
    date_field <- get_api_date_suffix(data_type)$date_field
  } else {
    date_field <- get_api_date_suffix(data_type)$date_fields_initial
  }

  # set up region field
  if (tolower(region) == "global"  || is.null(region)) {
    region_field <- NULL
  } else {
    region_field <- get_api_date_suffix(data_type)$region_field
    # set up region field name
    region_field <- if (data_type == "virus") "RegionName" else "WHORegion"
  }

  # Construct the full API URL
  api_url <- construct_api_url(
    api_endpoint, endpoint_suffix, min_date, max_date,
    date_field, country_code, region_field, region, select_vars
  )

  # all API iteratively
  response <- iterative_api_call(api_url, token = polis_api_key)

  # process API response
  full_data <- process_api_response(response)

  # log results
  if (log_results) {

    # Check if log file name is provided
    if (is.null(log_file_path)) {
      warning("No log file name provided. Logging is disabled.")
      return(invisible(NULL))
    }

    # set up log file name
    log_file_name <- paste0(log_file_path, "/", "polis_data_update_log.rds")

    # Construct the log message
    log_message <- data.frame(
      Region = tools::toTitleCase(region),
      QueryStartDate = as.Date(min_date, format = "%Y-%m-%d"),
      QueryEndDate = as.Date(max_date, format = "%Y-%m-%d"),
      DataStartDate = min(as.Date(full_data[[date_field]])),
      DataEndDate = max(as.Date(full_data[[date_field]])),
      PolisDataType = as.character(endpoint_suffix),
      NumberOfVariables = ncol(full_data),
      NumberOfRows = format(nrow(full_data), big.mark = ",")
    )

    if (file.exists(log_file_name)) {
      log_data <- readRDS(log_file_name)
      log_data <- rbind(log_data, log_message)
    } else {
      log_data <- log_message
    }

    # Save log file
    saveRDS(log_data, log_file_name)

  }

  return(full_data)
}
