testthat::test_that("write_log_file_api creates new log file", {
  withr::with_tempdir({
    # Create test data
    full_data <- data.frame(
      CaseDate = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03")),
      EPID = c("TEST-001", "TEST-002", "TEST-003")
    )
    new_data <- data.frame(
      CaseDate = as.Date("2023-01-03"),
      EPID = "TEST-003"
    )
    data_type <- "cases"
    date_field <- "CaseDate"
    last_date_in_chunk <- as.Date("2023-01-02")
    min_date <- "2023-01-01"
    max_date <- "2023-01-03"
    session_end_date <- as.Date("2023-01-03")

    # Create log file path
    log_file <- file.path(getwd(), "test_log.rds")

    # Test: New file creation
    write_log_file_api(
      log_file, data_type, full_data, new_data, date_field,
      last_date_in_chunk, min_date, max_date, session_end_date
    )

    testthat::expect_true(file.exists(log_file))

    file_content <- readRDS(log_file)
    testthat::expect_equal(nrow(file_content), 1)
    testthat::expect_equal(file_content$DataType, data_type)
  })
})

testthat::test_that("write_log_file_api appends to existing log file", {
  withr::with_tempdir({
    # Create test data
    full_data <- data.frame(
      CaseDate = as.Date(c("2023-01-01", "2023-01-02")),
      EPID = c("TEST-001", "TEST-002")
    )
    new_data <- data.frame(
      CaseDate = as.Date("2023-01-02"),
      EPID = "TEST-002"
    )
    data_type <- "cases"
    date_field <- "CaseDate"
    last_date_in_chunk <- as.Date("2023-01-01")
    min_date <- "2023-01-01"
    max_date <- "2023-01-02"
    session_end_date <- as.Date("2023-01-02")

    log_file <- file.path(getwd(), "test_log.rds")

    # First write
    write_log_file_api(
      log_file, data_type, full_data, new_data, date_field,
      last_date_in_chunk, min_date, max_date, session_end_date
    )

    # Second write (should append but deduplicate by UpdateDate)
    write_log_file_api(
      log_file, data_type, full_data, new_data, date_field,
      last_date_in_chunk, min_date, max_date, session_end_date
    )

    file_content <- readRDS(log_file)
    # Should have 1 row due to deduplication by UpdateDate
    testthat::expect_equal(nrow(file_content), 1)
  })
})
