#' Construct API URL
#'
#' This function constructs a URL for making an API call. It takes various
#' parameters such as the API endpoint, endpoint suffix, date range, region, and
#' selected variables, and combines them to form a complete and well-formatted
#' API URL. The function handles the inclusion of date filters, region filters,
#' and selection of specific fields in the query, and ensures proper URL
#' encoding.
#'
#' @param endpoint The base URL of the API endpoint.
#' @param suffix Additional path appended to the endpoint to specify the
#'        API resource.
#' @param min_date The minimum date for the date range filter.
#' @param max_date The maximum date for the date range filter.
#' @param date_field The field name in the API corresponding to the date.
#' @param region_field The field name in the API corresponding to the region.
#' @param region The specific region to filter the data. If NULL or empty,
#'        no region filter is applied.
#' @param select_vars A vector of field names to be included in the API
#'        response. If NULL or empty, no selective fields are applied.
#'
#' @return A string containing the fully constructed API URL.
#'
#' @examples
#' construct_api_url(
#'   "https://api.example.com/", "data", "2020-01-01", "2020-12-31",
#'   "dateField", "regionField", "AFRO", c("field1", "field2")
#' )
#' @export

construct_api_url <- function(endpoint, suffix, min_date, max_date,
                              date_field, region_field, region, select_vars) {
  # Base URL construction
  base_url <- paste0(endpoint, suffix)

  # Date filter
  date_filter <- glue::glue(
    "{date_field} ge DateTime'{min_date}' and ",
    "{date_field} le DateTime'{max_date}'"
  )

  # Region filter
  region_filter <- ""
  if (!is.null(region) && region != "" &&
    !(suffix %in% c("HumanSpecimenViruses", "Im"))) {
    region_filter <- glue::glue(" and {region_field} eq '{region}'")
  }

  # Combine date and region filters
  filter_query <- paste(date_filter, region_filter, sep = "")

  # Select query for additional fields
  select_query <- ""
  if (!is.null(select_vars) && length(select_vars) > 0) {
    select_query <- paste0("$select=", paste(select_vars, collapse = ","))
  }

  # Construct final query string
  query_string <- ""
  if (select_query != "") {
    query_string <- paste(filter_query, select_query, sep = "&")
  } else {
    query_string <- filter_query
  }

  # Construct the full API URL
  api_url <- paste0(base_url, "?$filter=", utils::URLencode(query_string))

  return(api_url)
}
