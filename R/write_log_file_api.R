#' Write Update Log File
#'
#' This function serves as a wrapper for updating a log file. It constructs a
#' log  message based on the provided parameters and appends it to an existing
#' log file or creates a new one if it doesn't exist. The function ensures that
#' date-timecolumns are correctly formatted and removes duplicate entries before
#' saving the file.
#'
#' @param log_file_name The name (and path) of the log file to be updated.
#' @param data_type The type of data being logged.
#' @param full_data A data frame representing the full dataset being processed.
#' @param new_data A data frame representing the new data being added.
#' @param date_field The name of the date field in the full_data and new_data
#'        data frames.
#' @param last_date_in_chunk The last date in the current data chunk being
#'        processed.
#' @param min_date The earliest date in the data being processed.
#' @param max_date The latest date in the data being processed.
#' @param session_end_date The end date of the current session.
#'
#' @details The function checks for the existence of the log file. If the file
#'          exists, it appends the new log message. If not, it creates a new log
#'          file. The function constructs the log message from the given
#'          parameters, including data types and date ranges. It also handles
#'          the conversion of specific columns to date format and ensures that
#'          duplicate entries are removed.
#'
#' @examples
#' \dontrun{
#' new_log_message <- data.frame(...) # example log message
#' write_log_file_api(
#'   "api_log.csv", "myDataType", fullData, newData, "dateCol",
#'   "2023-01-01", "2023-01-01", "2023-01-10", "2023-01-10"
#' )
#' }
#' @export

write_log_file_api <- function(log_file_name,
                               data_type,
                               full_data,
                               new_data,
                               date_field,
                               last_date_in_chunk,
                               min_date,
                               max_date,
                               session_end_date) {
  # Construct the log message
  log_message <- data.frame(
    UpdateDate = as.Date(Sys.Date(), "%Y-%m-%d"),
    UpdateTime = format(Sys.time(), "%H:%M:%S %Z"),
    OverallStartDate = min(as.Date(full_data[[date_field]],
      format = "%Y-%m-%d"
    ), na.rm = TRUE),
    SessionStartDate = as.Date(min_date, format = "%Y-%m-%d"),
    SessionEndDate = as.Date(session_end_date, format = "%Y-%m-%d"),
    DataType = as.character(data_type),
    NewRowsAdded = format(nrow(new_data), big.mark = ","),
    stringsAsFactors = FALSE
  )

  # Append or create log file
  if (file.exists(log_file_name)) {
    log_data <- epiCleanr::import(log_file_name)
    log_data <- rbind(log_data, log_message)
  } else {
    log_data <- log_message
  }

  # Convert date-time columns
  date_cols <- c(
    "UpdateDate", "OverallStartDate",
    "SessionStartDate", "SessionEndDate"
  )
  log_data <- log_data |>
    dplyr::mutate(
      dplyr::across(tidyselect::all_of(date_cols), as.Date)
    ) |>
    dplyr::distinct(
      dplyr::across(
        tidyselect::all_of(c(date_cols, "NewRowsAdded"))
      ),
      .keep_all = TRUE
    )

  # Save log file
  epiCleanr::export(log_data, log_file_name)
}
