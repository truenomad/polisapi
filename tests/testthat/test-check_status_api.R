testthat::test_that("Check Status API Responses", {
  # Testing for successful status code 200
  expect_null(check_status_api(200))
  # Testing for various error status codes
  expect_error(check_status_api(413))
  # Testing for an unspecified status code
  expect_error(check_status_api(999))
})
