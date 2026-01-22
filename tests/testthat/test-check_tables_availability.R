testthat::test_that("extract_entity_sets parses XML correctly", {
  # Create a mock XML response
  mock_xml <- '<?xml version="1.0" encoding="utf-8"?>
    <edmx:Edmx xmlns:edmx="http://schemas.microsoft.com/ado/2007/06/edmx">
      <edmx:DataServices>
        <Schema xmlns="http://schemas.microsoft.com/ado/2009/11/edm">
          <EntitySet Name="Case" EntityType="POLIS.Case" />
          <EntitySet Name="Virus" EntityType="POLIS.Virus" />
          <EntitySet Name="Activity" EntityType="POLIS.Activity" />
        </Schema>
      </edmx:DataServices>
    </edmx:Edmx>'

  # Mock the HTTP response
  mock_response <- list(
    status_code = 200,
    content = charToRaw(mock_xml)
  )
  class(mock_response) <- "response"

  mock_get <- function(...) mock_response
  mock_content <- function(resp, as = "text") mock_xml

  mockery::stub(extract_entity_sets, "httr::GET", mock_get)
  mockery::stub(extract_entity_sets, "httr::content", mock_content)

  result <- extract_entity_sets("https://test.url")

  testthat::expect_s3_class(result, "data.frame")
  testthat::expect_true("DataName" %in% names(result))
  testthat::expect_true("EntityType" %in% names(result))
})

testthat::test_that("get_status_code returns status for valid table", {
  # Mock successful response
  mock_response <- list(status_code = 200)
  class(mock_response) <- "response"

  mock_get <- function(...) mock_response
  mock_status <- function(resp) 200

  mockery::stub(get_status_code, "httr::GET", mock_get)
  mockery::stub(get_status_code, "httr::status_code", mock_status)

  result <- get_status_code("case", api_token = "test_token")

  testthat::expect_equal(result, 200)
})

testthat::test_that("get_status_code handles timeout", {
  # Mock timeout error
  mock_get <- function(...) {
    stop(simpleError("Timeout was reached"))
  }

  mockery::stub(get_status_code, "httr::GET", mock_get)

  result <- get_status_code("case", api_token = "test_token")

  testthat::expect_equal(result, "Timeout")
})

testthat::test_that("get_status_code handles other errors", {
  # Mock generic error
  mock_get <- function(...) {
    stop(simpleError("Connection failed"))
  }

  mockery::stub(get_status_code, "httr::GET", mock_get)

  result <- get_status_code("case", api_token = "test_token")

  testthat::expect_equal(result, "Error")
})

testthat::test_that("check_tables_availability filters tables correctly", {
  # Mock extract_entity_sets to return sample tables
 mock_xml_df <- data.frame(
    DataName = c("Case", "Virus", "Activity", "Population"),
    EntityType = c("POLIS.Case", "POLIS.Virus", "POLIS.Activity", "POLIS.Population")
  )

  mock_status <- function(table, api_token) 200

  mockery::stub(check_tables_availability, "extract_entity_sets", function(...) mock_xml_df)
  mockery::stub(check_tables_availability, "get_status_code", mock_status)

  # Test with specific tables_to_check
  # This should filter to only requested tables
  testthat::expect_message(
    check_tables_availability(
      api_token = "test_token",
      tables_to_check = c("case", "virus")
    ),
    "available"
  )
})

testthat::test_that("check_tables_availability warns about missing tables", {
  mock_xml_df <- data.frame(
    DataName = c("Case", "Virus"),
    EntityType = c("POLIS.Case", "POLIS.Virus")
  )

  mock_status <- function(table, api_token) 200

  mockery::stub(check_tables_availability, "extract_entity_sets", function(...) mock_xml_df)
  mockery::stub(check_tables_availability, "get_status_code", mock_status)

  # Request a table that doesn't exist
  testthat::expect_message(
    check_tables_availability(
      api_token = "test_token",
      tables_to_check = c("case", "nonexistent_table")
    ),
    "not found"
  )
})

testthat::test_that("check_tables_availability restores timeout option", {
  mock_xml_df <- data.frame(
    DataName = c("Case"),
    EntityType = c("POLIS.Case")
  )

  mock_status <- function(table, api_token) 200

  mockery::stub(check_tables_availability, "extract_entity_sets", function(...) mock_xml_df)
  mockery::stub(check_tables_availability, "get_status_code", mock_status)

  old_timeout <- getOption("timeout")

  check_tables_availability(
    api_token = "test_token",
    tables_to_check = c("case")
  )

  # Timeout should be restored
  testthat::expect_equal(getOption("timeout"), old_timeout)
})
