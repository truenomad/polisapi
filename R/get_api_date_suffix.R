#' Get Date Field and Endpoint Suffix Based on Data Type
#'
#' This function returns the appropriate endpoint suffix and date field name
#' for a given data type. It is specifically designed to work with the POLIS API
#' data retrieval system. The function takes a data type as input and returns a
#' list containing the corresponding endpoint suffix and date field. It ensures
#' that the data type provided is valid and returns an error message if not.
#'
#' @param data_type A string specifying the type of data for which information
#'                  is needed. Valid data types include 'cases', 'virus',
#'                  'population', 'env', 'geo', 'geo_synonym', 'im', 'activity',
#'                  'lab_specimen', 'lab_specimen_virus', 'sub_activ', and
#'                  'lqas'.
#'
#' @return A list with two elements: 'endpoint_suffix', which is the suffix for
#'         the API endpoint corresponding to the data type, and 'date_field',
#'         which is the name of the date field relevant to the data type.
#'
#' @examples
#' result <- get_api_date_suffix("cases")
#' endpoint_suffix <- result$endpoint_suffix
#' date_field <- result$date_field
#' @export

get_api_date_suffix <- function(data_type) {
  # Define endpoint suffixes and date fields in named lists
  endpoint_suffixes <- c(
    cases = "Case", virus = "Virus",
    population = "Population", env = "EnvSample",
    geo = "Geography", geo_synonym = "Synonym",
    lab_specimen = "LabSpecimen",
    lab_specimen_virus = "HumanSpecimenViruses",
    im = "Im", activity = "Activity",
    sub_activ = "SubActivity", lqas = "Lqas"
  )

  # Define date fields for each data type
  # for initial data
  date_fields_initial <- c(
    cases = "CaseDate",
    virus = "VirusDate",
    population = "CreatedDate",
    env = "CollectionDate",
    geo = "CreatedDate",
    geo_synonym = "UpdatedDate",
    im = "PublishDate",
    activity = "ActivityDateFrom",
    lab_specimen_virus = "PublishDate",
    lab_specimen = "LastUpdateDate",
    sub_activ = "DateFrom",
    lqas = "Start"
  )

  # Define date fields for each data type
 # for updated data
  date_fields <- c(
    cases = "LastUpdateDate",
    virus = "UpdatedDate", population = "UpdatedDate",
    env = "LastUpdateDate", geo = "UpdatedDate",
    geo_synonym = "UpdatedDate",
    im = "PublishDate", activity = "LastUpdateDate",
    lab_specimen_virus = "PublishDate",
    lab_specimen = "LastUpdateDate",
    sub_activ = "UpdatedDate", lqas = "Start"
  )

  # Check if the provided data type is valid
  if (!data_type %in% names(endpoint_suffixes)) {
    stop("Invalid data_type specified")
  }

  # Return endpoint suffix and date field
  list(
    endpoint_suffix = endpoint_suffixes[[data_type]],
    date_fields_initial = date_fields_initial[[data_type]],
    date_field = date_fields[[data_type]]
  )
}
