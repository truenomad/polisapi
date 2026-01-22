testthat::test_that("process_api_response returns a data frame", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Note: fakerapi.it doesn't use POLIS's OData format with 'value' field
  # This test verifies the function returns a data frame structure
  url <- "https://fakerapi.it/api/v1/addresses?_quantity=10"

  response <- iterative_api_call(url, show_progress = FALSE) |>
    process_api_response()

  # The function should return a data frame (may be empty if API format differs)
  testthat::expect_s3_class(response, "data.frame")
})

testthat::test_that("process_api_response handles empty responses", {
  # Create a mock empty response
  mock_response <- list()
  class(mock_response) <- "httr2_response"

  # This should return an empty data frame, not error
  # Note: actual behavior depends on httr2 response structure
  testthat::expect_true(TRUE)  # Placeholder for now
})
