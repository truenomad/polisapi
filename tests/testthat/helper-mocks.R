# Test helper functions for polisapi package
# These helpers provide mock data and utilities for testing

#' Create a mock API response object
#'
#' @param data A data frame to include as the response data
#' @param status_code HTTP status code (default 200)
#' @return A mock response object compatible with httr2
create_mock_response <- function(data = NULL, status_code = 200) {
  if (is.null(data)) {
    data <- data.frame(
      id = 1:5,
      name = paste0("item_", 1:5),
      date = as.character(Sys.Date() - 0:4)
    )
  }

  list(
    status_code = status_code,
    data = data
  )
}

#' Create mock POLIS case data
#'
#' @param n Number of rows to generate
#' @return A data frame mimicking POLIS case data structure
create_mock_case_data <- function(n = 10) {
  data.frame(
    EPID = paste0("TEST-", seq_len(n)),
    CaseDate = as.character(seq.Date(Sys.Date() - n, by = "day", length.out = n)),
    LastUpdateDate = as.character(Sys.Date()),
    Country = sample(c("NGA", "PAK", "AFG"), n, replace = TRUE),
    WHORegion = sample(c("AFRO", "EMRO", "SEARO"), n, replace = TRUE),
    Classification = sample(c("cVDPV", "WPV", "Compatible"), n, replace = TRUE)
  )
}

#' Create mock POLIS virus data
#'
#' @param n Number of rows to generate
#' @return A data frame mimicking POLIS virus data structure
create_mock_virus_data <- function(n = 10) {
  data.frame(
    EPID = paste0("VIR-", seq_len(n)),
    VirusDate = as.character(seq.Date(Sys.Date() - n, by = "day", length.out = n)),
    UpdatedDate = as.character(Sys.Date()),
    VirusType = sample(c("WPV1", "cVDPV2", "VDPV3"), n, replace = TRUE),
    RegionName = sample(c("AFRO", "EMRO", "SEARO"), n, replace = TRUE)
  )
}

#' Mock validate_polis_api_key function
#'
#' @param key API key to validate
#' @return Returns a test key
mock_validate_api_key <- function(key) {
  "test_api_key_12345"
}

#' Mock iterative_api_call function
#'
#' @param url URL to call
#' @param token API token
#' @param max_attempts Max retry attempts
#' @param show_progress Show progress bar
#' @return Mock response list
mock_iterative_api_call <- function(url, token = NULL, max_attempts = 3,
                                     show_progress = TRUE) {
  # Return a list structure similar to httr2::req_perform_iterative
  list(
    list(
      body = list(value = create_mock_case_data(5))
    )
  )
}
