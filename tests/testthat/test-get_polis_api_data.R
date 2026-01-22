# Mock the iterative_api_call function
mock_iterative_api_call <- function(api_url, token = NULL, show_progress = TRUE) {
  # Mock response data
  mock_data <- data.frame(
    id = 1:5,
    date = seq(as.Date('2021-01-01'), as.Date('2021-01-05'), by="day"),
    CaseDate = seq(as.Date('2021-01-01'), as.Date('2021-01-05'), by="day"),
    cases = sample(100:200, 5)
  )
  jsonlite::toJSON(list(data = mock_data))
}

# Mock the process_api_response function
mock_process_api_response <- function(response) {
  data <- jsonlite::fromJSON(response)
  data$data
}

# Mock API key validation
mock_validate_polis_api_key <- function(key) "test_api_key"

testthat::test_that("get_polis_api_data returns correct data structure", {
  # Stub the external functions with mocks
  mockery::stub(
    get_polis_api_data, "validate_polis_api_key", mock_validate_polis_api_key)
  mockery::stub(
    get_polis_api_data, "iterative_api_call", mock_iterative_api_call)
  mockery::stub(
    get_polis_api_data, "process_api_response", mock_process_api_response)

  # Test the function
  result <- get_polis_api_data("2021-01-01",
                               "2021-01-31", "cases", "AFRO")

  # Assertions
  testthat::expect_type(result, "list")
  testthat::expect_true(all(c("id", "date", "cases") %in% names(result)))
  testthat::expect_equal(nrow(result), 5)
})

testthat::test_that("get_polis_api_data validates save_polis parameters", {
  # Should error when save_polis = TRUE but polis_filname is missing
  testthat::expect_error(
    get_polis_api_data(
      min_date = "2024-01-01",
      max_date = "2024-01-31",
      data_type = "cases",
      save_polis = TRUE,
      polis_filname = NULL,
      polis_path = "data/"
    ),
    "polis_filname"
  )

  # Should error when save_polis = TRUE but polis_path is missing
  testthat::expect_error(
    get_polis_api_data(
      min_date = "2024-01-01",
      max_date = "2024-01-31",
      data_type = "cases",
      save_polis = TRUE,
      polis_filname = "test",
      polis_path = NULL
    ),
    "polis_path"
  )
})

testthat::test_that("get_polis_api_data handles different regions", {
  mockery::stub(
    get_polis_api_data, "validate_polis_api_key", mock_validate_polis_api_key)
  mockery::stub(
    get_polis_api_data, "iterative_api_call", mock_iterative_api_call)
  mockery::stub(
    get_polis_api_data, "process_api_response", mock_process_api_response)

  # Test Global region
  result_global <- get_polis_api_data(
    "2021-01-01", "2021-01-31", "cases", "Global", quiet = TRUE
  )
  testthat::expect_s3_class(result_global, "data.frame")

  # Test specific region
  result_afro <- get_polis_api_data(
    "2021-01-01", "2021-01-31", "cases", "AFRO", quiet = TRUE
  )
  testthat::expect_s3_class(result_afro, "data.frame")
})

testthat::test_that("get_polis_api_data handles virus data type region", {
  mockery::stub(
    get_polis_api_data, "validate_polis_api_key", mock_validate_polis_api_key)
  mockery::stub(
    get_polis_api_data, "iterative_api_call", mock_iterative_api_call)
  mockery::stub(
    get_polis_api_data, "process_api_response", mock_process_api_response)

  # Virus data type uses "RegionName" instead of "WHORegion"
  result <- get_polis_api_data(
    "2021-01-01", "2021-01-31", "virus", "AFRO", quiet = TRUE
  )
  testthat::expect_s3_class(result, "data.frame")
})

testthat::test_that("get_polis_api_data handles country_code filter", {
  mockery::stub(
    get_polis_api_data, "validate_polis_api_key", mock_validate_polis_api_key)
  mockery::stub(
    get_polis_api_data, "iterative_api_call", mock_iterative_api_call)
  mockery::stub(
    get_polis_api_data, "process_api_response", mock_process_api_response)

  result <- get_polis_api_data(
    "2021-01-01", "2021-01-31", "cases",
    country_code = "NGA", quiet = TRUE
  )
  testthat::expect_s3_class(result, "data.frame")
})

testthat::test_that("get_polis_api_data handles select_vars", {
  mockery::stub(
    get_polis_api_data, "validate_polis_api_key", mock_validate_polis_api_key)
  mockery::stub(
    get_polis_api_data, "iterative_api_call", mock_iterative_api_call)
  mockery::stub(
    get_polis_api_data, "process_api_response", mock_process_api_response)

  result <- get_polis_api_data(
    "2021-01-01", "2021-01-31", "cases", "AFRO",
    select_vars = c("id", "date"), quiet = TRUE
  )
  testthat::expect_s3_class(result, "data.frame")
})

testthat::test_that("get_polis_api_data handles updated_dates parameter", {
  mockery::stub(
    get_polis_api_data, "validate_polis_api_key", mock_validate_polis_api_key)
  mockery::stub(
    get_polis_api_data, "iterative_api_call", mock_iterative_api_call)
  mockery::stub(
    get_polis_api_data, "process_api_response", mock_process_api_response)

  # Test with updated_dates = TRUE
  result <- get_polis_api_data(
    "2021-01-01", "2021-01-31", "cases", "AFRO",
    updated_dates = TRUE, quiet = TRUE
  )
  testthat::expect_s3_class(result, "data.frame")
})

testthat::test_that("get_polis_api_data logging warns when no path provided", {
  mockery::stub(
    get_polis_api_data, "validate_polis_api_key", mock_validate_polis_api_key)
  mockery::stub(
    get_polis_api_data, "iterative_api_call", mock_iterative_api_call)
  mockery::stub(
    get_polis_api_data, "process_api_response", mock_process_api_response)

  # Should warn when log_results = TRUE but log_file_path = NULL
  testthat::expect_message(
    get_polis_api_data(
      "2021-01-01", "2021-01-31", "cases", "AFRO",
      log_results = TRUE, log_file_path = NULL, quiet = FALSE
    ),
    "No log file"
  )
})

testthat::test_that("get_polis_api_data quiet mode suppresses messages", {
  mockery::stub(
    get_polis_api_data, "validate_polis_api_key", mock_validate_polis_api_key)
  mockery::stub(
    get_polis_api_data, "iterative_api_call", mock_iterative_api_call)
  mockery::stub(
    get_polis_api_data, "process_api_response", mock_process_api_response)

  # With quiet = TRUE, should not output success message
  result <- testthat::expect_silent(
    get_polis_api_data(
      "2021-01-01", "2021-01-31", "cases", "AFRO",
      quiet = TRUE
    )
  )
  testthat::expect_s3_class(result, "data.frame")
})
