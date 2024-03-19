#' Save Polis Data to compressed RDS File
#'
#' This function saves a given POLIS data object to an RDS file using a
#' specific naming convention based on the current date. It also manages the
#' retention of only the 5 most recent datasets in the specified directory,
#' removing older datasets if necessary.
#'
#' @param polis_data The POLIS data object to be saved.
#' @param polis_path The directory path where the RDS file will be saved. This
#'   function will check this directory for existing datasets and will maintain
#'   only the 5 most recent datasets, deleting older ones.
#' @param filname The name of the file to be saved.
#' @param max_datasets The max number of datasets to retain in the directory.
#'
#' @return Invisible NULL. This function is used for its side effect of
#'   saving a file and potentially deleting older files, rather than for
#'   returning a value.
#'
#' @examples
#' # Assume `polis_data` is your dataset and `./polis_datasets` is your
#' # target directory
#' # save_polis_data(polis_data, "./polis_datasets")
#'
#' @export
save_polis_data <- function(polis_data, polis_path,
                            filname, max_datasets = 5) {

  cli::cli_process_start("Saving POLIS data into a compressed RDS file.")

  # generate the file name based on the current date
  suffix_name <- sprintf("_%s.rds", format(Sys.Date(), "%Y_%V"))
  full_path <- file.path(polis_path, paste0(filname, suffix_name))

  # save polis list
  saveRDS(polis_data, full_path, compress = "xz")

  cli::cli_process_done(  )

  # Check existing datasets and keep only the 5 most recent
  existing_files <- list.files(polis_path, full.names = TRUE)

  if (length(existing_files) > 5) {
    # Sort files by date, assuming the naming convention holds the date info
    file_dates <- sapply(existing_files, function(x) {
      as.Date(stringr::str_extract(x, "\\d{4}_\\d{2}"), "%Y_%V")
    })

    oldest_files <- existing_files[order(
      file_dates)][1:(length(existing_files)-5)]

    cli::cli_alert_success(
      "Removing {length(oldest_files)} old file(s) to keep top {max_datasets}.")

    suppressMessages(file.remove(oldest_files))
  }
  cli::cli_process_done(  )
}
