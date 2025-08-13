#' Extract Entity Sets from the POLIS API Metadata
#'
#' This function retrieves and extracts entity sets from the POLIS API metadata
#' URL provided. It parses the XML content to extract the names and entity
#' types of the available data sets.
#'
#' @param url A character string specifying the URL of the POLIS API metadata.
#'
#' @return A data frame containing two columns:
#' \describe{
#'   \item{DataName}{The name of the data set.}
#'   \item{EntityType}{The entity type associated with the data set.}
#' }
#'
#' @examples
#' \dontrun{
#' # Define the URL for the POLIS API metadata
#' polis_api_root_url <-
#'              "https://extranet.who.int/polis/api/v2/$metadata?token="
#' api_token <- Sys.getenv("POLIS_API_KEY")
#' url <- paste0(polis_api_root_url, api_token)
#'
#' # Extract the entity sets
#' xml_df <- extract_entity_sets(url)
#' }
extract_entity_sets <- function(url) {
  response <- httr::GET(url)
  content <- httr::content(response, as = "text")
  xml_content <- xml2::read_xml(content)

  # Get the namespaces
  ns <- xml2::xml_ns(xml_content)

  # Extract EntitySet nodes using the correct namespaces
  entity_sets <- xml_content |>
    xml2::xml_find_all("//d4:EntityContainer/d4:EntitySet", ns = ns)

  # Extract attributes from EntitySet nodes and convert to a data frame
  data.frame(
    `DataName` = xml2::xml_attr(entity_sets, "Name"),
    `EntityType` = xml2::xml_attr(entity_sets, "EntityType"),
    stringsAsFactors = FALSE
  ) |>
    dplyr::group_by(`EntityType`) |>
    dplyr::slice(1) |>
    dplyr::ungroup()
}

#' Get HTTP Status Code for a POLIS API Table
#'
#' This function sends a GET request to a specified POLIS API table and returns
#' the HTTP status code. It includes error handling to manage timeouts and other
#' potential request errors.
#'
#' @param table A character string specifying the name of the table to check.
#' @param api_token A character string of the POLIS API token. Defaults to
#'      `Sys.getenv("POLIS_API_KEY")`.
#'
#' @return An integer representing the HTTP status code, or a character string
#'      ("Timeout" or "Error") if an exception occurs.
#'
#' @examples
#' \dontrun{
#' # Get the status code for the "countries" table
#' status_code <- get_status_code("countries")
#' }
get_status_code <- function(table, api_token = Sys.getenv("POLIS_API_KEY")) {
  # Validate API key
  api_token <- validate_polis_api_key(api_token)
  url <- paste0("https://extranet.who.int/polis/api/v2/", table, "?$top=5")
  tryCatch({
    response <- httr::GET(
      url,
      httr::add_headers("authorization-token" = api_token),
      httr::timeout(10)
    )
    httr::status_code(response)
  }, error = function(e) {
    if (grepl("Timeout was reached", e$message)) {
      return("Timeout")
    } else {
      return("Error")
    }
  })
}

#' Check Availability of POLIS API Tables
#'
#' This function checks the availability of specified tables in the POLIS API
#' by sending GET requests. It reports the HTTP status codes and provides
#' success or error messages using the `cli` package.
#'
#' @param api_token A character string of the POLIS API token. Defaults to
#'    `Sys.getenv("POLIS_API_KEY")`.
#' @param tables_to_check An optional character vector of table names to check.
#'     If `NULL`, all available tables are checked.
#'
#' @return No return value. The function outputs messages to the console
#'    indicating the availability of each table.
#'
#' @examples
#' \dontrun{
#' # Check the availability of specific tables
#' check_tables_availability(
#'   api_token = Sys.getenv("POLIS_API_KEY"),
#'   tables_to_check = c("virus", "case", "population", "humanspecimenviruses",
#'                       "envsample", "synonym", "geography", "lqas",
#'                       "activity", "subactivity", "envirosamplesite",
#'                       "im", "labspecimen")
#' )
#' }
#'@export
check_tables_availability <- function(
    api_token = Sys.getenv("POLIS_API_KEY"),
    tables_to_check = NULL) {

  # Validate API key
  api_token <- validate_polis_api_key(api_token)

  # Get the list of tables
  polis_api_root_url <- "https://extranet.who.int/polis/api/v2/$metadata?token="
  url <- paste0(polis_api_root_url, api_token)

  xml_df <- extract_entity_sets(url)
  tables <- tolower(xml_df$DataName)

  # If specific tables are requested, filter the list
  if (!is.null(tables_to_check)) {
    # Ensure the provided table names are in lowercase
    tables_to_check <- tolower(tables_to_check)
    # Filter tables to only include those specified
    tables <- tables[tables %in% tables_to_check]

    # Warn if any requested tables are not found
    missing_tables <- setdiff(tables_to_check, tables)
    if (length(missing_tables) > 0) {
      cli::cli_alert_warning(
        glue::glue(
          "The following tables were not found and will be skipped:",
          " {paste(missing_tables, collapse = ', ')}")
      )
    }
  }

  # Disable SSL verification and set a timeout
  httr::set_config(httr::config(ssl_verifypeer = 0L))
  options(timeout = 5)

  # Loop through tables and check availability
  for (table in tables) {
    status_code <- get_status_code(table, api_token = api_token)
    if (status_code == 200) {
      cli::cli_alert_success(
        "POLIS table `{table}` is available to download."
      )
    } else {
      cli::cli_alert_danger(
        "POLIS table `{table}` is not available. Status code: {status_code}"
      )
    }
  }
}
