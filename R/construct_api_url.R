# Updated R code in construct_api_url.R

# Example of constructing filters with direct date strings
filters <- list(
  date_field = '2025-05-29',  # directly using date string
  another_field = 'some_value',
  count = TRUE,  # updated inline count to count=true
  guid = 'xxxxx'  # changed GUID format
)

# Further filtering logic ...