# testthat::test_that("Log File Handling in write_log_file_api", {
#   withr::with_tempdir({
#     full_data <- new_data <- data.frame(
#       date_field = as.Date('2023-01-01'),
#       other_field = 1:10
#     )
#     data_type <- "test_type"
#     last_date_in_chunk <- min_date <- max_date <- "2023-01-01"
#     session_end_date <- "2023-01-02"
#
#     # Setup: Creating a new file
#     log_file <- file.path(tempfile(), "log_file.rds")
#
#     # Test: New file creation
#     write_log_file_api(
#       log_file, data_type, full_data, new_data, 'date_field',
#       last_date_in_chunk, min_date, max_date, session_end_date)
#     file_content <- readRDS(log_file)
#
#     testthat::expect_equal(nrow(file_content), 1)
#     testthat::expect_equal(file_content$DataType, data_type)
#
#     # Test: Appending to existing file
#     write_log_file_api(
#       log_file, data_type, full_data, new_data, 'date_field',
#       last_date_in_chunk, min_date, max_date, session_end_date)
#     updated_file_content <- readRDS(log_file)
#     testthat::expect_equal(nrow(updated_file_content), 1)
#   })
# })
#
#
#
#
