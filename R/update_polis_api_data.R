#' Retrieve and Update POLIS Data
#'
#' This function is designed for both the initial retrieval and subsequent
#' updates of POLIS datasets. It intelligently checks for existing data,
#' fetches only new data since the last update, integrates this with the
#' existing data, logs update sessions, and saves the updated dataset to a
#' specified location. It interacts with the POLIS API and allows filtering
#' and selection based on various criteria.
#'
#' @param min_date Start date for data retrieval in 'YYYY-MM-DD' format.
#'                 This date marks the beginning of the dataset to be retrieved.
#' @param max_date End date for data retrieval, default is the current date.
#'                 This date marks the end of the dataset to be retrieved.
#' @param data_type Type of data to retrieve. Each option represents a different
#'                  category of data available from the  POLIS API.
#'                  Supported types include 'cases', 'virus', 'population',
#'                  'env' (Environmental), 'geo' (Geographical), 'geo_synonym',
#'                  'im' (Independent Monitoring), 'activity', 'sub_activ'
#'                  (Sub-activities), and 'lqas' (Lot Quality Assurance
#'                  Sampling), lab_specimen (Human Specimen), lab_specimen_virus
#'                  (Human Specimen Viruses). Default is 'cases'.
#' @param region Region code for data filtering, default is 'AFRO'.
#'               This parameter filters the data by the specified WHO region.
#' @param country_code ISO3 country code to filter the data. Default is NULL.
#' @param select_vars Vector of variables to select, default is NULL (all vars).
#'                    This parameter allows for the selection of specific
#'                    variables from the API response.
#' @param file_path Path for the data and log files, default is a preset
#'                  directory. This defines the storage location for data
#'                  and logs.
#' @param save_directly Boolean indicating whether data should be saved directly.
#'                      Default is TRUE. If FALSE, the function returns a
#'                      data frame of the aggregated data.
#' @param log_results Boolean indicating whether to log update sessions.
#'                    Default is TRUE. This controls the logging of updates.
#' @param polis_api_key API key for authentication, default from environment.
#'                        This is used for accessing and authenticating with
#'                        the API.
#'
#' @return If save_directly is FALSE, returns a data frame of the aggregated
#'         data. Otherwise, the data is saved to the specified file path and
#'         nothing is returned.
#'
#' @examples
#' \dontrun{
#' update_polis_api_data("2021-01-01", "2021-01-31", "cases", "AFRO")
#' }
#' @export

update_polis_api_data <- function(min_date,
                                  max_date = Sys.Date(),
                                  data_type = "cases",
                                  region = "AFRO",
                                  country_code = NULL,
                                  select_vars = NULL,
                                  file_path = NULL,
                                  save_directly = FALSE,
                                  log_results = FALSE,
                                  polis_api_key = NULL) {

  # Construct file names for data and log
  data_file_name <- paste0(file_path, "/", data_type, "_polis_data.rds")
  log_file_name <- paste0(file_path, "/", "polis_data_update_log.xlsx")

  # set up the dates
  date_field <- get_api_date_suffix(data_type)$date_field

  # Load existing data if it exists
  if (file.exists(data_file_name)) {
    full_data <- epiCleanr::import(data_file_name)
    last_date_in_chunk <- as.Date(
      max(full_data[[date_field]], na.rm = T),
      format = "%Y-%m-%d"
    )
  } else {
    full_data <- data.frame()
    last_date_in_chunk <- as.Date(min_date) - 1
  }

  # Retrieve data from the API starting from the day after the last date in
  # the existing data
  min_date <- last_date_in_chunk + 1

  # Retrieve data from the API
  new_data <- get_polis_api_data(
    min_date = min_date, max_date = max_date,
    data_type = data_type, region = region, country_code = country_code,
    select_vars = select_vars, updated_dates = TRUE,
    log_results = FALSE, polis_api_key = polis_api_key,
  )

  # Combine new data with existing data
  if (nrow(new_data) > 0) {
    full_data <- dplyr::bind_rows(full_data, new_data)
  }

  # Log the session details to an Excel file
  if (nrow(full_data) > 0) {
    session_end_date <- min(
      as.Date(max_date),
      max(as.Date(full_data[[date_field]],
                  format = "%Y-%m-%d"
      ), na.rm = TRUE)
    )

    if (save_directly && log_results) {
      write_log_file_api(
        log_file_name, data_type, full_data, new_data, date_field,
        last_date_in_chunk, min_date, max_date, session_end_date
      )
    }

    n_rows <- format(sum(nrow(full_data)), big.mark = ",")

    if (file.exists(data_file_name) & session_end_date > min_date) {
      n_rows <- format(sum(nrow(full_data)), big.mark = ",")

      cat(glue::glue(
        "Hooray! You have updated the {data_type} ",
        "data (N = {n_rows}) from {as.Date(last_date_in_chunk)}",
        " to {session_end_date}.\n"
      ))
    } else if (session_end_date > min_date) {
      cat(glue::glue(
        "Hooray! You have downloaded the complete {data_type} ",
        "data (N = {n_rows}) from {as.Date(min_date)} to ",
        "{session_end_date}.\n"
      ))
    }
  }

  # Save the updated full dataset
  if (save_directly) {
    epiCleanr::export(full_data, data_file_name)
  } else {
    return(full_data)
  }
}
