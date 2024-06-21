# library(testthat)
# library(mockery)
# library(glue)
# library(epiCleanr)

# Assuming necessary functions are defined or mocked here

# Setup: Mock functions
mock_file_exists <- function(path) TRUE
mock_import_data <- function(path) {
  data.frame(Date = seq(as.Date("2021-01-01"),
                        as.Date("2021-01-10"), by = "day"))
}
mock_get_polis_api_data <- function(...) {
  data.frame(Date = seq(as.Date("2021-01-11"),
                        as.Date("2021-01-20"), by = "day"))
}
mock_export_data <- function(data, path) TRUE
mock_write_log_file_api <- function(log_file_name, log_message) TRUE


test_that("Main update_polis_api_data functionality", {
  mockery::stub(
    update_polis_api_data, "file.exists", mock_file_exists)
  mockery::stub(
    update_polis_api_data, "epiCleanr::import", mock_import_data)
  mockery::stub(
    update_polis_api_data, "get_polis_api_data", mock_get_polis_api_data)
  mockery::stub(
    update_polis_api_data, "epiCleanr::export", mock_export_data)
  mockery::stub(
    update_polis_api_data, "write_log_file_api", mock_write_log_file_api)

  # Test 1: When data is being update
  suppressWarnings(
    result <- update_polis_api_data("2021-01-01", "2021-01-20")
  )
  testthat::expect_equal(nrow(result), 20)

})

#
# test_that("Functionality with save_directly and log_results", {
#
#   withr::with_tempdir({
#
#     # Set up the temporary file path
#     temp_file_path <- tempdir()
#
#     data_file_name <- file.path(temp_file_path, "cases_polis_data.rds")
#     log_file_name <- file.path(temp_file_path, "polis_data_update_log.xlsx")
#
#     # Set up mock files
#     mockery::stub(
#       update_polis_api_data, "file.exists", function(path) FALSE)
#     mockery::stub(
#       update_polis_api_data, "epiCleanr::import", function(path) NULL)
#     mockery::stub(
#       update_polis_api_data, "get_polis_api_data", function(...) {
#         data.frame(
#           Date = seq(as.Date("2021-01-11", format = "%Y-%m-%d"),
#                      as.Date("2021-01-20", format = "%Y-%m-%d"), by = "day"))
#       })
#     mockery::stub(
#       update_polis_api_data,
#       "epiCleanr::export", function(data, data_file_name) TRUE)
#     mockery::stub(
#       update_polis_api_data, "write_log_file_api",
#       function(log_file_name, log_message) TRUE)
#
#     # Execute the function with save_directly and log_results set to TRUE
#     suppressWarnings(
#       result <- update_polis_api_data(
#         min_date = "2021-01-01", max_date = "2021-01-20",
#         data_type = "cases", region = "AFRO",
#         file_path = NULL,
#         save_directly = TRUE, log_results = TRUE
#       )
#     )
#
#     # Check if data and log files were created in the temporary directory
#     expect_true(
#       file.exists(data_file_name))
#     expect_true(
#       file.exists(file.path(temp_file_path, "polis_data_update_log.xlsx")))
#
#   })
# })

