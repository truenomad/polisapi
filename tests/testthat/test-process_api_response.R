testthat::test_that("Test functionality of process_api_response", {
  url <- "https://fakerapi.it/api/v1/addresses?_quantity=10"

  response <- iterative_api_call(url)  |>
    process_api_response()

  expect_type(response, 'list')
})

