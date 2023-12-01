testthat::test_that("Get the correct response and status code form API call", {
  url <- "https://fakerapi.it/api/v1/addresses?_quantity=1"

  status_code <- iterative_api_call(url) |>
    head(1) |>
    httr2::resps_data(\(resp) httr2::resp_status(resp))

  expect_equal(status_code, 200)
})


