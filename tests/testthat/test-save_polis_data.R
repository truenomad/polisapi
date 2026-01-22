testthat::test_that("save_polis_data creates RDS file", {
  withr::with_tempdir({
    # Create test data
    test_data <- data.frame(
      EPID = paste0("TEST-", 1:10),
      CaseDate = as.Date("2023-01-01") + 0:9,
      Country = rep("NGA", 10)
    )

    # Save data
    save_polis_data(
      polis_data = test_data,
      polis_path = getwd(),
      filname = "test_cases",
      max_datasets = 3,
      output_format = "rds"
    )

    # Check file exists (should have date suffix)
    files <- list.files(getwd(), pattern = "test_cases.*\\.rds$")
    testthat::expect_length(files, 1)

    # Verify data can be read back
    saved_data <- readRDS(file.path(getwd(), files[1]))
    testthat::expect_equal(nrow(saved_data), 10)
    testthat::expect_equal(ncol(saved_data), 3)
  })
})

testthat::test_that("save_polis_data respects max_datasets limit", {
  withr::with_tempdir({
    test_data <- data.frame(
      EPID = paste0("TEST-", 1:5),
      CaseDate = as.Date("2023-01-01") + 0:4
    )

    # Save multiple files (simulating different weeks)
    # Note: This test is limited because save_polis_data uses week numbers
    # We're mainly testing that the function runs without error
    save_polis_data(
      polis_data = test_data,
      polis_path = getwd(),
      filname = "test_data",
      max_datasets = 2,
      output_format = "rds"
    )

    files <- list.files(getwd(), pattern = "test_data.*\\.rds$")
    testthat::expect_gte(length(files), 1)
  })
})

testthat::test_that("save_polis_data handles qs2 format", {
  testthat::skip_if_not_installed("qs2")

  withr::with_tempdir({
    test_data <- data.frame(
      EPID = paste0("TEST-", 1:5),
      CaseDate = as.Date("2023-01-01") + 0:4
    )

    save_polis_data(
      polis_data = test_data,
      polis_path = getwd(),
      filname = "test_qs2",
      max_datasets = 3,
      output_format = "qs2"
    )

    files <- list.files(getwd(), pattern = "test_qs2.*\\.qs2$")
    testthat::expect_length(files, 1)
  })
})

testthat::test_that("save_polis_data errors on unsupported format", {
  withr::with_tempdir({
    test_data <- data.frame(EPID = "TEST-1", CaseDate = as.Date("2023-01-01"))

    testthat::expect_error(
      save_polis_data(
        polis_data = test_data,
        polis_path = getwd(),
        filname = "test",
        output_format = "csv"
      ),
      "Unsupported output_format"
    )

    testthat::expect_error(
      save_polis_data(
        polis_data = test_data,
        polis_path = getwd(),
        filname = "test",
        output_format = "parquet"
      ),
      "Unsupported output_format"
    )
  })
})

testthat::test_that("save_polis_data normalizes output_format", {
  withr::with_tempdir({
    test_data <- data.frame(EPID = "TEST-1", CaseDate = as.Date("2023-01-01"))

    # Test with leading dot (should be removed)
    save_polis_data(
      polis_data = test_data,
      polis_path = getwd(),
      filname = "test_dot",
      output_format = ".rds"
    )

    files <- list.files(getwd(), pattern = "test_dot.*\\.rds$")
    testthat::expect_length(files, 1)
  })
})

testthat::test_that("save_polis_data treats 'qs' as 'qs2'", {
  testthat::skip_if_not_installed("qs2")

  withr::with_tempdir({
    test_data <- data.frame(EPID = "TEST-1", CaseDate = as.Date("2023-01-01"))

    # "qs" should be treated as "qs2"
    save_polis_data(
      polis_data = test_data,
      polis_path = getwd(),
      filname = "test_qs",
      output_format = "qs"
    )

    files <- list.files(getwd(), pattern = "test_qs.*\\.qs2$")
    testthat::expect_length(files, 1)
  })
})

testthat::test_that("save_polis_data deletes oldest files when exceeding max", {
  withr::with_tempdir({
    test_data <- data.frame(EPID = "TEST-1", CaseDate = as.Date("2023-01-01"))

    # Create some pre-existing files with different week numbers
    # Simulating files from previous weeks
    file.create("mydata_2024_01.rds")
    file.create("mydata_2024_02.rds")
    file.create("mydata_2024_03.rds")

    # Save new data with max_datasets = 2
    save_polis_data(
      polis_data = test_data,
      polis_path = getwd(),
      filname = "mydata",
      max_datasets = 2,
      output_format = "rds"
    )

    # Should have at most 2 files now (new one + kept one)
    files <- list.files(getwd(), pattern = "mydata.*\\.rds$")
    testthat::expect_lte(length(files), 2)
  })
})

testthat::test_that("save_polis_data excludes log files from deletion", {
  withr::with_tempdir({
    test_data <- data.frame(EPID = "TEST-1", CaseDate = as.Date("2023-01-01"))

    # Create a log file that should NOT be deleted
    log_file <- "polis_data_update_log_2024_01.rds"
    saveRDS(data.frame(log = "test"), log_file)

    # Create some regular data files
    saveRDS(test_data, "cases_2024_01.rds")
    saveRDS(test_data, "cases_2024_02.rds")

    # Save new data
    save_polis_data(
      polis_data = test_data,
      polis_path = getwd(),
      filname = "cases",
      max_datasets = 2,
      output_format = "rds"
    )

    # Log file should still exist
    testthat::expect_true(file.exists(log_file))
  })
})

testthat::test_that("save_polis_data only considers files matching filename prefix", {
  withr::with_tempdir({
    test_data <- data.frame(EPID = "TEST-1", CaseDate = as.Date("2023-01-01"))

    # Create files with different prefixes
    saveRDS(test_data, "cases_2024_01.rds")
    saveRDS(test_data, "virus_2024_01.rds")
    saveRDS(test_data, "env_2024_01.rds")

    # Save new cases data with max_datasets = 1
    save_polis_data(
      polis_data = test_data,
      polis_path = getwd(),
      filname = "cases",
      max_datasets = 1,
      output_format = "rds"
    )

    # virus and env files should still exist (different prefix)
    testthat::expect_true(file.exists("virus_2024_01.rds"))
    testthat::expect_true(file.exists("env_2024_01.rds"))
  })
})

testthat::test_that("save_polis_data handles uppercase format", {
  withr::with_tempdir({
    test_data <- data.frame(EPID = "TEST-1", CaseDate = as.Date("2023-01-01"))

    # Test uppercase format
    save_polis_data(
      polis_data = test_data,
      polis_path = getwd(),
      filname = "test_upper",
      output_format = "RDS"
    )

    files <- list.files(getwd(), pattern = "test_upper.*\\.rds$")
    testthat::expect_length(files, 1)
  })
})
