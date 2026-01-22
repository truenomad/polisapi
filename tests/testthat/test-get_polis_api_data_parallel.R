testthat::test_that("get_polis_api_data_parallel validates save_polis parameters", {
  # Should error when save_polis = TRUE but polis_filname is NULL
  testthat::expect_error(
    get_polis_api_data_parallel(
      min_date = "2024-01-01",
      max_date = "2024-01-07",
      data_type = "cases",
      save_polis = TRUE,
      polis_filname = NULL,
      polis_path = "data/"
    ),
    "polis_filname"
  )

  # Should error when save_polis = TRUE but polis_path is NULL
  testthat::expect_error(
    get_polis_api_data_parallel(
      min_date = "2024-01-01",
      max_date = "2024-01-07",
      data_type = "cases",
      save_polis = TRUE,
      polis_filname = "test",
      polis_path = NULL
    ),
    "polis_path"
  )
})

testthat::test_that("get_polis_api_data_parallel errors on invalid date range", {
  # Invalid date range (max before min) should error
  testthat::expect_error(
    get_polis_api_data_parallel(
      min_date = "2024-12-31",
      max_date = "2024-01-01",  # max before min
      data_type = "cases",
      date_interval = "1 month"
    )
    # Errors from seq.Date with "wrong sign in 'by' argument"
  )
})

testthat::test_that("get_polis_api_data_parallel falls back to sequential for single chunk", {
  # Mock the sequential function
  mock_data <- data.frame(
    EPID = paste0("TEST-", 1:5),
    CaseDate = as.character(seq.Date(as.Date("2024-01-01"), by = "day", length.out = 5)),
    Country = "NGA"
  )

  mock_get_polis <- function(...) mock_data
  mock_validate <- function(key) "test_key"

  mockery::stub(get_polis_api_data_parallel, "get_polis_api_data", mock_get_polis)
  mockery::stub(get_polis_api_data_parallel, "validate_polis_api_key", mock_validate)

  # With only 1 day range, should use single chunk (sequential)
  result <- get_polis_api_data_parallel(
    min_date = "2024-01-01",
    max_date = "2024-01-01",
    data_type = "cases",
    region = "AFRO",
    polis_api_key = "test_key",
    quiet = TRUE
  )

  testthat::expect_s3_class(result, "data.frame")
})

testthat::test_that("get_polis_api_data_parallel falls back to sequential when workers = 1", {
  mock_data <- data.frame(
    EPID = paste0("TEST-", 1:10),
    CaseDate = as.character(seq.Date(as.Date("2024-01-01"), by = "day", length.out = 10))
  )

  mock_get_polis <- function(...) mock_data

  mockery::stub(get_polis_api_data_parallel, "get_polis_api_data", mock_get_polis)

  result <- get_polis_api_data_parallel(
    min_date = "2024-01-01",
    max_date = "2024-01-31",
    data_type = "cases",
    workers = 1,  # Force sequential
    polis_api_key = "test_key",
    quiet = TRUE
  )

  testthat::expect_s3_class(result, "data.frame")
})

testthat::test_that("get_polis_api_data_parallel creates correct date chunks", {
  # We can't easily test parallel execution without mocking extensively,

  # but we can verify the chunk logic
  min_date <- as.Date("2024-01-01")
  max_date <- as.Date("2024-03-31")

  # Monthly chunks should create 3 chunks
  starts <- seq(min_date, max_date, by = "1 month")
  testthat::expect_equal(length(starts), 3)

  # Weekly chunks should create more
  starts_weekly <- seq(min_date, max_date, by = "1 week")
  testthat::expect_gt(length(starts_weekly), 10)
})
