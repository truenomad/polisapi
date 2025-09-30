[![R-CMD-check](https://github.com/truenomad/polisapi/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/truenomad/polisapi/actions/workflows/R-CMD-check.yaml) [![CodeFactor](https://www.codefactor.io/repository/github/truenomad/polisapi/badge)](https://www.codefactor.io/repository/github/truenomad/polisapi) [![codecov](https://codecov.io/gh/truenomad/polisapi/graph/badge.svg?token=69FGYK1HMY)](https://codecov.io/gh/truenomad/polisapi)

# polisapi

## Overview

**polisapi** is a comprehensive R package designed to simplify the process of downloading, updating, and managing data from the Polio Information System ([POLIS](https://extranet.who.int/polis/)) database through its API. POLIS is maintained by the World Health Organization (WHO) and serves as the central data repository supporting the Global Polio Eradication Initiative ([GPEI](https://polioeradication.org/)).

This package provides robust tools for accessing polio-related information, including case data, laboratory specimens, environmental surveillance, vaccination campaigns, and geographical references across endemic and at-risk countries worldwide.

### Key Features

- **Multiple download strategies**: Sequential and parallel data retrieval
- **Smart incremental updates**: Fetch only new data since last download
- **Comprehensive data types**: Access 12+ different POLIS datasets
- **Built-in logging**: Track all data retrieval sessions
- **Flexible data management**: Save data in multiple formats with archiving support
- **Regional filtering**: Download data by WHO region or globally
- **Variable selection**: Choose specific columns to optimize bandwidth
- **Production-ready**: Comprehensive test coverage and CI/CD integration

## Installation

Install the development version directly from GitHub using `devtools` or `remotes`:

``` r
# Using devtools
install.packages("devtools")
devtools::install_github("truenomad/polisapi")

# Or using remotes
install.packages("remotes")
remotes::install_github("truenomad/polisapi")
```

### System Requirements

- R >= 4.1.0
- Active internet connection
- Valid POLIS API access token

## Access and Authentication

Before using the package, you must obtain API access credentials from the POLIS team. Once granted access:

### Setting Up Your API Key

``` r
# Load the package
library(polisapi)

# Method 1: Store securely in .Renviron (recommended)
usethis::edit_r_environ()
# Add this line to your .Renviron file:
# POLIS_API_KEY=your_access_token_here

# Restart R, then access your token:
my_token <- Sys.getenv("POLIS_API_KEY")

# Method 2: Set for current session only
Sys.setenv(POLIS_API_KEY = "your_access_token_here")
```

**Security Note**: Never commit API keys to version control. Always use environment variables or secure credential management systems.

## Core Functions

The package provides three main functions for different use cases:

### 1. Sequential Data Retrieval: `get_polis_api_data()`

Downloads data sequentially from the POLIS API. Best for smaller date ranges or when parallel processing is not needed.

**Use Cases:**
- One-time complete data downloads
- Small to medium date ranges
- Creating data snapshots
- Detailed download logging

**Key Parameters:**
- `min_date`, `max_date`: Date range in 'YYYY-MM-DD' format
- `data_type`: Type of dataset (see Data Types section)
- `region`: WHO region code or 'Global'
- `country_code`: ISO3 country code for filtering
- `select_vars`: Vector of specific variables to retrieve
- `polis_api_key`: Your API authentication token
- `save_polis`: Whether to save data directly to disk
- `log_results`: Enable detailed logging

**Example:**

``` r
# Download case data for African Region
cases_data <- get_polis_api_data(
  min_date = "2023-01-01",
  max_date = "2023-12-31",
  data_type = "cases",
  region = "AFRO",
  polis_api_key = my_token,
  log_results = TRUE,
  log_file_path = "logs/"
)

# Download specific variables only
virus_data <- get_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "virus",
  region = "Global",
  select_vars = c("EPID", "VirusDate", "VirusType"),
  polis_api_key = my_token
)

# Save directly to disk with archiving
get_polis_api_data(
  min_date = "2023-01-01",
  max_date = "2023-12-31",
  data_type = "cases",
  region = "EMRO",
  polis_api_key = my_token,
  save_polis = TRUE,
  polis_filname = "emro_cases",
  polis_path = "data/",
  max_polis_archive = 5,
  output_format = "rds"
)
```

### 2. Parallel Data Retrieval: `get_polis_api_data_parallel()`

Downloads data in parallel by splitting the date range into chunks. Significantly faster for large date ranges and overcomes API pagination limitations.

**Use Cases:**
- Large date ranges (years of data)
- Time-sensitive downloads
- Avoiding API continuation token constraints
- Maximum download speed

**Key Features:**
- Cross-platform support (Windows, macOS, Linux)
- Automatic chunk splitting by time interval
- Configurable worker processes
- Progress tracking
- Automatic result combination

**Additional Parameters:**
- `date_interval`: Chunk size (e.g., "1 week", "1 month")
- `workers`: Number of parallel processes (defaults to cores - 1)
- `quiet`: Suppress progress messages

**Example:**

``` r
# Download 2 years of virus data in parallel
virus_data <- get_polis_api_data_parallel(
  min_date = "2022-01-01",
  max_date = "2023-12-31",
  data_type = "virus",
  region = "Global",
  date_interval = "1 month",
  workers = 4,
  polis_api_key = my_token
)

# Fast download with weekly chunks
env_data <- get_polis_api_data_parallel(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "env",
  region = "SEARO",
  date_interval = "1 week",
  workers = 6,
  polis_api_key = my_token,
  quiet = FALSE
)
```

**Performance Tip**: For date ranges > 6 months, parallel downloading can be 3-5x faster than sequential.

### 3. Incremental Updates: `update_polis_api_data()`

Intelligently updates existing datasets by fetching only new records since the last download. Ideal for maintaining up-to-date local databases.

**Use Cases:**
- Regular automated updates
- Maintaining local data mirrors
- Minimizing API calls and bandwidth
- Scheduled data refreshes

**Key Features:**
- Automatically detects last update date
- Appends only new records
- Maintains data continuity
- Built-in session logging
- Optimized for repeated use

**Example:**

``` r
# Initial download
update_polis_api_data(
  min_date = "2023-01-01",
  max_date = Sys.Date(),
  data_type = "cases",
  region = "AFRO",
  file_path = "data/polis/",
  save_directly = TRUE,
  log_results = TRUE,
  polis_api_key = my_token
)

# Subsequent update (automatically continues from last date)
update_polis_api_data(
  min_date = "2023-01-01",  # Original start date
  max_date = Sys.Date(),
  data_type = "cases",
  region = "AFRO",
  file_path = "data/polis/",  # Same path
  save_directly = TRUE,
  log_results = TRUE,
  polis_api_key = my_token
)

# Update without saving (return data frame)
updated_data <- update_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "virus",
  region = "Global",
  save_directly = FALSE,
  polis_api_key = my_token
)
```

## Data Types

The POLIS API provides access to 12+ comprehensive datasets. Each data type has specific date fields and regional filters:

### Surveillance Data

- **`cases`** - Acute Flaccid Paralysis (AFP) case surveillance data
  - Patient demographics, onset dates, classification, final diagnosis

- **`virus`** - Poliovirus isolation and characterization data
  - Virus type, date, genomic sequencing, lineage information

- **`env`** - Environmental surveillance samples
  - Sample collection sites, dates, poliovirus detection results

- **`lab_specimen`** - Human stool specimen laboratory data
  - Specimen collection, processing, laboratory results

- **`lab_specimen_virus`** - Viruses isolated from human specimens
  - Detailed virus characterization from stool samples

- **`lab_env`** - Environmental sample laboratory data
  - Processing and results of environmental samples

### Geographic References

- **`geo`** - Geographic location master data
  - Administrative boundaries, coordinates, population centers

- **`geo_synonym`** - Alternate location names and spellings
  - Historical names, local language variants, common misspellings

- **`population`** - Population denominators
  - Age-stratified population data for coverage calculations

### Vaccination Campaign Data

- **`activity`** - Supplementary Immunization Activities (SIA)
  - Campaign dates, target populations, vaccine types

- **`sub_activ`** - SIA sub-activity details
  - Administrative unit-level campaign implementation

- **`lqas`** - Lot Quality Assurance Sampling surveys
  - Campaign quality monitoring data, coverage assessments

- **`im`** - Independent Monitoring surveys
  - Post-campaign coverage verification data

### Choosing the Right Data Type

``` r
# Epidemiological analysis
cases <- get_polis_api_data(data_type = "cases", ...)

# Virological surveillance
viruses <- get_polis_api_data(data_type = "virus", ...)

# Environmental surveillance
env_samples <- get_polis_api_data(data_type = "env", ...)

# Campaign monitoring
campaigns <- get_polis_api_data(data_type = "activity", ...)
campaign_quality <- get_polis_api_data(data_type = "lqas", ...)
```

## Regional Filtering

Filter data by WHO regions or retrieve global datasets:

**Available Regions:**
- `AFRO` - African Region
- `AMRO` - Region of the Americas
- `EMRO` - Eastern Mediterranean Region
- `EURO` - European Region
- `SEARO` - South-East Asia Region
- `WPRO` - Western Pacific Region
- `Global` - All regions combined

``` r
# Regional data
afro_data <- get_polis_api_data(
  region = "AFRO",
  data_type = "cases",
  min_date = "2024-01-01",
  polis_api_key = my_token
)

# Global data
global_data <- get_polis_api_data(
  region = "Global",
  data_type = "virus",
  min_date = "2024-01-01",
  polis_api_key = my_token
)

# Country-specific data
pak_data <- get_polis_api_data(
  country_code = "PAK",
  data_type = "cases",
  min_date = "2024-01-01",
  polis_api_key = my_token
)
```

## Advanced Features

### Logging and Audit Trails

Track all data retrieval operations for reproducibility and auditing:

``` r
# Enable logging
data <- get_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "cases",
  region = "Global",
  polis_api_key = my_token,
  log_results = TRUE,
  log_file_path = "logs/"
)

# Log file contains:
# - Query date range
# - Actual data date range
# - Number of records retrieved
# - Number of variables
# - Data type and region
# - Timestamp
```

### Data Archiving

Automatically maintain versioned archives of your data:

``` r
get_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "cases",
  region = "AFRO",
  polis_api_key = my_token,
  save_polis = TRUE,
  polis_filname = "afro_cases",
  polis_path = "data/",
  max_polis_archive = 5,  # Keep 5 most recent versions
  output_format = "rds"   # or "qs2" for faster I/O
)
```

### Variable Selection

Optimize bandwidth by selecting only needed variables:

``` r
# Download only specific columns
slim_data <- get_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "cases",
  region = "Global",
  select_vars = c("EPID", "DateOnset", "Classification", "Country"),
  polis_api_key = my_token
)
```

### Quiet Mode

Suppress progress messages for automated scripts:

``` r
# Silent operation
data <- get_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "virus",
  polis_api_key = my_token,
  quiet = TRUE
)
```

## Workflow Examples

### Weekly Automated Updates

``` r
# scheduled_update.R
library(polisapi)

# Update multiple data types
regions <- c("AFRO", "EMRO", "SEARO")
data_types <- c("cases", "virus", "env")

for (region in regions) {
  for (dtype in data_types) {
    update_polis_api_data(
      min_date = "2024-01-01",
      max_date = Sys.Date(),
      data_type = dtype,
      region = region,
      file_path = paste0("data/", region, "/"),
      save_directly = TRUE,
      log_results = TRUE,
      polis_api_key = Sys.getenv("POLIS_API_KEY")
    )
  }
}
```

### Large Historical Download

``` r
# Download 5 years of global virus data efficiently
historical_virus <- get_polis_api_data_parallel(
  min_date = "2019-01-01",
  max_date = "2023-12-31",
  data_type = "virus",
  region = "Global",
  date_interval = "1 month",
  workers = 8,
  polis_api_key = my_token,
  save_polis = TRUE,
  polis_filname = "global_virus_historical",
  polis_path = "data/historical/",
  log_results = TRUE,
  log_file_path = "logs/"
)
```

### Multi-Region Analysis

``` r
# Compare case data across regions
library(dplyr)
library(purrr)

regions <- c("AFRO", "EMRO", "SEARO")

regional_data <- map_dfr(regions, function(reg) {
  get_polis_api_data(
    min_date = "2024-01-01",
    max_date = Sys.Date(),
    data_type = "cases",
    region = reg,
    polis_api_key = my_token
  ) %>%
    mutate(Region = reg)
})
```

## Error Handling and Troubleshooting

### Common Issues

**API Key Not Found**
``` r
# Error: POLIS_API_KEY not found
# Solution: Check your environment variable
Sys.getenv("POLIS_API_KEY")  # Should return your key
```

**Connection Timeout**
``` r
# For large downloads, use parallel function
data <- get_polis_api_data_parallel(
  ...,
  date_interval = "1 week",  # Smaller chunks
  workers = 4
)
```

**No Data Returned**
``` r
# Check if date range contains data
# Verify region and data_type are correct
# Ensure API key has access to requested data type
```

## Package Architecture

### Internal Functions

The package includes several internal helper functions:

- `validate_polis_api_key()` - Validates API authentication
- `construct_api_url()` - Builds properly formatted API URLs
- `iterative_api_call()` - Handles paginated API responses
- `process_api_response()` - Parses and cleans API responses
- `get_api_date_suffix()` - Maps data types to API endpoints
- `check_status_api()` - Validates API response status
- `save_polis_data()` - Manages data saving and archiving
- `write_log_file_api()` - Creates audit logs
- `check_tables_availability()` - Validates data type availability

### Testing

The package includes comprehensive unit tests covering all major functions:

``` r
# Run all tests
devtools::test()

# Test specific function
testthat::test_file("tests/testthat/test-get_polis_api_data.R")
```

## Dependencies

### Required Packages
- `cli` - User interface messaging
- `dplyr` - Data manipulation
- `glue` - String interpolation
- `httpcode` - HTTP status codes
- `httr2` - HTTP requests
- `stringr` - String operations
- `tidyselect` - Variable selection

### Suggested Packages
- `pbapply` - Progress bars for parallel operations
- `qs2` - Fast data serialization
- `testthat` - Unit testing
- `mockery` - Test mocking
- `usethis` - Development utilities

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass: `devtools::check()`
5. Submit a pull request

## Citation

If you use this package in your research, please cite:

``` r
citation("polisapi")
```

## License

MIT License - see [LICENSE.md](LICENSE.md) for details

## Acknowledgments

- WHO Global Polio Eradication Initiative (GPEI)
- POLIS team at WHO Headquarters
- Contributors and package maintainers

## Support and Contact

**Package Maintainer**: Mohamed A. Yusuf
**Email**: moyusuf@who.int
**GitHub Issues**: [https://github.com/truenomad/polisapi/issues](https://github.com/truenomad/polisapi/issues)

## Related Resources

- [POLIS Portal](https://extranet.who.int/polis/)
- [GPEI Website](https://polioeradication.org/)
- [WHO Polio Information](https://www.who.int/health-topics/poliomyelitis)

---

**Version**: 1.0.0
**Last Updated**: 2025