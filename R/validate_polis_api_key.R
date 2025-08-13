#' Validate POLIS API Key
#'
#' This function validates the POLIS API key. If no key is found in the
#' environment or if the provided key is empty, it prompts the user
#' interactively to enter their API key. The function ensures that a valid
#' API key is available before proceeding with API calls.
#'
#' @param polis_api_key API key for authentication. Default is retrieved from
#'                      the environment variable 'POLIS_API_KEY'. An explicit
#'                      API key can be provided if required.
#'
#' @return A character string containing the validated API key.
#'
#' @details The function performs the following steps:
#' \itemize{
#'   \item Checks if the provided API key is empty
#'   \item If empty, warns the user and offers an interactive prompt
#'   \item Validates that the entered key is not empty
#'   \item Sets the environment variable for the current session if a new key is provided
#'   \item Returns the validated API key or aborts with an error if no valid key is provided
#' }
#'
#' @examples
#' \dontrun{
#' # Validate API key from environment
#' api_key <- validate_polis_api_key()
#'
#' # Validate a specific API key
#' api_key <- validate_polis_api_key("your_api_key_here")
#' }
#' @export
validate_polis_api_key <- function(polis_api_key = Sys.getenv("POLIS_API_KEY")) {
  if (polis_api_key == "") {
    cli::cli_alert_warning("No POLIS API key found in environment.")

    response <- readline(
      "Would you like to enter your API key now? (yes/no): ")

    if (tolower(response) %in% c("yes", "y")) {
      key_input <- readline(
        "Please enter your API key without quotations: ")
      if (key_input == "") {
        cli::cli_alert_danger("No key entered. Exiting.")
        cli::cli_abort("POLIS API key is required.")
      }
      Sys.setenv(POLIS_API_KEY = key_input)
      polis_api_key <- key_input
      cli::cli_alert_success("API key has been set for this session.")
    } else {
      cli::cli_alert_danger("Cannot proceed without API key.")
      cli::cli_abort("POLIS API key is required.")
    }
  }

  return(polis_api_key)
}