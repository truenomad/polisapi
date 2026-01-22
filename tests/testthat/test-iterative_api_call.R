testthat::test_that("iterative_api_call constructs request correctly", {
  # Skip on CRAN and CI to avoid external API calls
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test with a simple public API that doesn't require authentication
  url <- "https://fakerapi.it/api/v1/addresses?_quantity=1"

  status_code <- iterative_api_call(url, show_progress = FALSE) |>
    head(1) |>
    httr2::resps_data(\(resp) httr2::resp_status(resp))

  testthat::expect_equal(status_code, 200)
})

testthat::test_that("iterative_api_call handles progress parameter", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  url <- "https://fakerapi.it/api/v1/addresses?_quantity=1"

  # Test with show_progress = FALSE (should not error)
  result <- iterative_api_call(url, show_progress = FALSE)
  testthat::expect_type(result, "list")
})
