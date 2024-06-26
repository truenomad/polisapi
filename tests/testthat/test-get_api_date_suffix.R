testthat::test_that("Get API Date Suffix Functionality", {
  # Test for valid data types
  testthat::expect_equal(get_api_date_suffix("cases"),
               list(endpoint_suffix = "Case",
                    date_fields_initial = "CaseDate",
                    date_field = "LastUpdateDate"))
  testthat::expect_equal(get_api_date_suffix("virus"),
               list(endpoint_suffix = "Virus",
                    date_fields_initial = "VirusDate",
                    date_field = "UpdatedDate"))
  # Add more tests for other valid data types

  # Test for an invalid data type
  testthat::expect_error(
    get_api_date_suffix("invalid_type"), "Invalid data_type specified")
})
