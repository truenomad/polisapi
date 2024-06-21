testthat::test_that("API URL Construction without selection", {

  base = "https://api.example.com/"

  actual_url <- construct_api_url(
    base, "data", "2020-01-01",
    "2020-12-31", "dateField", NULL, "regionField",  "AFRO",
    select_vars = NULL)

  expected_url <- paste0(
    base, "data?$filter=dateField%20ge%20DateTime",
    "'2020-01-01'%20and%20dateField%20le%20DateTime",
    "'2020-12-31'%20and%20regionField%20eq%20'AFRO'")

  testthat::expect_equal(actual_url, expected_url)

}
)

testthat::test_that("API URL Construction without selection", {

  base = "https://api.example.com/"

  actual_url <- construct_api_url(
    base, "data", "2020-01-01",
    "2020-12-31", "dateField", NULL, "regionField","AFRO",
    c("field1", "field2"))

  expected_url <- paste0(
    base, "data?$filter=dateField%20ge%20DateTime",
    "'2020-01-01'%20and%20dateField%20le%20DateTime",
    "'2020-12-31'%20and%20regionField%20eq%20'AFRO'",
    "&$select=field1,field2")

  testthat::expect_equal(actual_url, expected_url)

}
)
