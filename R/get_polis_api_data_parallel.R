#' Retrieve POLIS Data in Parallel by Date Chunks
#'
#' Splits the requested date range into non-overlapping chunks (e.g.,
#' monthly) and downloads each chunk in parallel using cross-platform PSOCK
#' clusters. This avoids OData continuation-token constraints by
#' parallelizing across independent sub-queries. Results are combined and
#' optionally saved once.
#'
#' Works on macOS and Windows (no forking required).
#'
#' @inheritParams get_polis_api_data
#' @param date_interval A `seq.Date` interval for chunks (e.g., "1 month").
#' @param workers Number of parallel workers. Defaults to
#'   `max(1, parallel::detectCores() - 1)`.
#' @param quiet Logical. If TRUE, suppresses progress messages and
#'   non-critical warnings; also disables chunk-level progress bars.
#'
#' @return A data.frame of POLIS data, or invisible NULL if
#'   `save_polis = TRUE`.
#'
#' @examples
#' \dontrun{
#' df <- get_polis_api_data_parallel(
#'   min_date = "2025-01-01",
#'   data_type = "virus",
#'   region = "Global",
#'   date_interval = "1 month",
#'   workers = 4
#' )
#' }
#'
#' @export
get_polis_api_data_parallel <- function(
  min_date = "2021-01-01",
  max_date = Sys.Date(),
  data_type = "cases",
  region = "Global",
  country_code = NULL,
  select_vars = NULL,
  updated_dates = FALSE,
  polis_api_key = Sys.getenv("POLIS_API_KEY"),
  save_polis = FALSE,
  polis_filname = NULL,
  polis_path = NULL,
  max_polis_archive = 5,
  output_format = "rds",
  log_results = FALSE,
  log_file_path = NULL,
  date_interval = "1 week",
  workers = max(1, parallel::detectCores() - 1),
  quiet = FALSE
) {

  # Validate save_polis parameters up front (same as sequential)
  if (save_polis) {
    if (is.null(polis_filname) || is.null(polis_path)) {
      cli::cli_abort(
        paste0(
          "When save_polis = TRUE, both polis_filname and ",
          "polis_path must be provided."
        )
      )
    }
  }

  # Build date chunks
  min_date <- as.Date(min_date)
  max_date <- as.Date(max_date)
  starts <- seq(min_date, max_date, by = date_interval)
  if (length(starts) == 0L) {
    cli::cli_abort("Invalid date range or interval produced no chunks.")
  }
  ends <- c(starts[-1] - 1, max_date)

  # If only one chunk or workers == 1, run sequentially for simplicity
  if (length(starts) == 1L || workers <= 1L) {
    return(get_polis_api_data(
      min_date = format(starts[1]),
      max_date = format(ends[1]),
      data_type = data_type,
      region = region,
      country_code = country_code,
      select_vars = select_vars,
      updated_dates = updated_dates,
      polis_api_key = polis_api_key,
      save_polis = save_polis,
      polis_filname = polis_filname,
      polis_path = polis_path,
      max_polis_archive = max_polis_archive,
      output_format = output_format,
      log_results = log_results,
      log_file_path = log_file_path,
      quiet = quiet
    ))
  }

  # Parallel PSOCK cluster (cross-platform)
  cl <- parallel::makePSOCKcluster(workers)
  on.exit(try(parallel::stopCluster(cl), silent = TRUE), add = TRUE)

  # Ensure functions are available on workers: prefer local sources if
  # present
  parallel::clusterEvalQ(cl, {
    ok <- FALSE
    if (requireNamespace("polisapi", quietly = TRUE)) {
      suppressPackageStartupMessages(library(polisapi))
      ok <- TRUE
    }
    if (!ok) {
      if (dir.exists("R")) {
        files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
        for (f in files) {
          try(suppressWarnings(source(f)), silent = TRUE)
        }
      }
    }
    NULL
  })

  # Prepare tasks as a data.frame to keep order
  tasks <- data.frame(
    start = starts,
    end = ends
  )

  # Export small objects used inside the worker function
  parallel::clusterExport(
    cl,
    varlist = c(
      "tasks", "data_type", "region", "country_code", "select_vars",
      "updated_dates", "polis_api_key", "log_results", "log_file_path",
      "quiet"
    ),
    envir = environment()
  )

  # Worker function runs one chunk without saving/logging; we combine then
  # save once
  worker_fun <- function(i) {
    # Resolve function and adapt to its signature (quiet may not exist)
    fun <- try(get("get_polis_api_data", inherits = TRUE), silent = TRUE)
    has_quiet <- FALSE
    if (!inherits(fun, "try-error") && is.function(fun)) {
      nm <- names(formals(fun))
      has_quiet <- "quiet" %in% nm
    }
    args <- list(
      min_date = format(tasks$start[i]),
      max_date = format(tasks$end[i]),
      data_type = data_type,
      region = region,
      country_code = country_code,
      select_vars = select_vars,
      updated_dates = updated_dates,
      polis_api_key = polis_api_key,
      save_polis = FALSE,
      log_results = FALSE
    )
    if (isTRUE(has_quiet)) args$quiet <- TRUE
    do.call(fun, args)
  }

  # Execute in parallel with progress
  idxs <- seq_len(nrow(tasks))
  use_pb <- !isTRUE(quiet) &&
    requireNamespace("pbapply", quietly = TRUE)
  if (use_pb) {
    res_list <- pbapply::pblapply(idxs, worker_fun, cl = cl)
  } else {
    # Fallback: batch in groups up to workers and update a CLI progress bar
    res_list <- list()
    show_cli <- !isTRUE(quiet) &&
      requireNamespace("cli", quietly = TRUE)
    pb_id <- NULL
    if (show_cli) {
      pb_id <- cli::cli_progress_bar(
        name = "Downloading 1-month ranges (parallel)",
        total = length(idxs)
      )
    }
    chunk_size <- max(1L, min(length(idxs), workers))
    for (start in seq(1L, length(idxs), by = chunk_size)) {
      j <- idxs[start:min(start + chunk_size - 1L, length(idxs))]
      sub <- parallel::parLapply(cl, j, worker_fun)
      res_list <- c(res_list, sub)
      if (show_cli) {
        cli::cli_progress_update(id = pb_id, set = length(res_list))
      }
    }
    if (show_cli) cli::cli_progress_done(id = pb_id)
  }

  # Combine results
  combined <- dplyr::bind_rows(res_list)

  if (!isTRUE(quiet)) {
    cli::cli_alert_success(
      sprintf(
        "POLIS data downloaded in %d chunk(s) using %d worker(s).",
        nrow(tasks), workers
      )
    )
  }

  # Optional single save and/or logging
  if (save_polis) {
    save_polis_data(
      polis_data = combined,
      polis_path = polis_path,
      filname = polis_filname,
      max_datasets = max_polis_archive,
      output_format = output_format
    )
  }

  if (log_results) {
    if (is.null(log_file_path)) {
      if (!isTRUE(quiet)) {
        cli::cli_alert_warning(
          "No log file name provided. Logging is disabled."
        )
      }
    } else {
      # For logging we need date field and endpoint suffix
      suffix_info <- get_api_date_suffix(data_type)
      endpoint_suffix <- suffix_info$endpoint_suffix
      date_field <- if (updated_dates) {
        suffix_info$date_field
      } else {
        suffix_info$date_fields_initial
      }

      log_file_name <- paste0(
        log_file_path, "/", "polis_data_update_log.rds"
      )
      log_message <- data.frame(
        Region = tools::toTitleCase(region),
        QueryStartDate = as.Date(min_date, format = "%Y-%m-%d"),
        QueryEndDate = as.Date(max_date, format = "%Y-%m-%d"),
        DataStartDate = min(as.Date(combined[[date_field]])),
        DataEndDate = max(as.Date(combined[[date_field]])),
        PolisDataType = as.character(endpoint_suffix),
        NumberOfVariables = ncol(combined),
        NumberOfRows = format(nrow(combined), big.mark = ",")
      )
      if (file.exists(log_file_name)) {
        log_data <- readRDS(log_file_name)
        log_data <- rbind(log_data, log_message)
      } else {
        log_data <- log_message
      }
      saveRDS(log_data, log_file_name)
    }
  }

  if (save_polis) return(invisible(NULL))
  combined
}
