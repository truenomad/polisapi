test_that("validate_polis_api_key returns valid key when provided", {
  # Test with a valid API key
  valid_key <- "test_api_key_123"
  result <- validate_polis_api_key(valid_key)
  expect_equal(result, valid_key)
})

test_that("validate_polis_api_key aborts when empty key and user says no", {
  # Mock readline to simulate user saying "no"
  readline_mock <- mockery::mock("no")
  mockery::stub(validate_polis_api_key, "readline", readline_mock)
  
  expect_error(
    validate_polis_api_key(""),
    "POLIS API key is required"
  )
})

test_that("validate_polis_api_key aborts when empty key entered interactively", {
  # Mock readline to simulate user saying "yes" first, then empty key
  readline_mock <- mockery::mock("yes", "")
  mockery::stub(validate_polis_api_key, "readline", readline_mock)
  
  expect_error(
    validate_polis_api_key(""),
    "POLIS API key is required"
  )
})

test_that("validate_polis_api_key sets and returns key when entered interactively", {
  # Mock readline to simulate user saying "yes" then entering a key
  new_key <- "new_test_key_456"
  readline_mock <- mockery::mock("yes", new_key)
  mockery::stub(validate_polis_api_key, "readline", readline_mock)
  
  # Mock Sys.setenv to avoid actually setting env var
  mockery::stub(validate_polis_api_key, "Sys.setenv", NULL)
  
  result <- validate_polis_api_key("")
  expect_equal(result, new_key)
})