# Mock the iterative_api_call function
mock_iterative_api_call <- function(api_url, token = NULL) {
  # Mock response data
  mock_data <- data.frame(
    id = 1:5,
    date = seq(as.Date('2021-01-01'), as.Date('2021-01-05'), by="day"),
    cases = sample(100:200, 5)
  )
  jsonlite::toJSON(list(data = mock_data))
}

# Mock the process_api_response function
mock_process_api_response <- function(response) {
  data <- jsonlite::fromJSON(response)
  data$data
}

testthat::test_that("get_polis_api_data returns correct data structure", {
  # Stub the external functions with mocks
  mockery::stub(
    get_polis_api_data, "iterative_api_call", mock_iterative_api_call)
  mockery::stub(
    get_polis_api_data, "process_api_response", mock_process_api_response)

  # Test the function
  result <- get_polis_api_data("2021-01-01",

                               "2021-01-31", "cases", "AFRO")

  # Assertions
  expect_type(result, "list")
  expect_true(all(c("id", "date", "cases") %in% names(result)))
  expect_equal(nrow(result), 5)
})



