[![R-CMD-check](https://github.com/truenomad/polisapi/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/truenomad/polisapi/actions/workflows/R-CMD-check.yaml) [![CodeFactor](https://www.codefactor.io/repository/github/truenomad/polisapi/badge)](https://www.codefactor.io/repository/github/truenomad/polisapi) [![codecov](https://codecov.io/gh/truenomad/polisapi/graph/badge.svg?token=69FGYK1HMY)](https://codecov.io/gh/truenomad/polisapi)

# polisapi

An R package for downloading data from the WHO Polio Information System ([POLIS](https://extranet.who.int/polis/)) database.

## Quick Start

```r
# Install
remotes::install_github("truenomad/polisapi")

# Set your API key
library(polisapi)
Sys.setenv(POLIS_API_KEY = "your_api_key_here")

# Download case data
cases <- get_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "cases",
  region = "AFRO"
)
```

## Installation

```r
# Using remotes
install.packages("remotes")
remotes::install_github("truenomad/polisapi")
```

**Requirements:** R >= 4.1.0, internet connection, POLIS API token

## Setting Up Your API Key

```r
# Recommended: Store in .Renviron
usethis::edit_r_environ()
# Add: POLIS_API_KEY=your_token_here
# Restart R

# Or set for current session
Sys.setenv(POLIS_API_KEY = "your_token_here")
```

## Core Functions

### 1. `get_polis_api_data()` - Sequential Download

Best for smaller datasets and one-time downloads.

```r
# Basic download
cases <- get_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "cases",
  region = "AFRO"
)

# Download specific variables only
virus <- get_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "virus",
  region = "Global",
  select_vars = c("EPID", "VirusDate", "VirusType")
)

# Download by country
pak_cases <- get_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "cases",
  country_code = "PAK"
)

# Save directly to disk with logging
get_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "cases",
  region = "EMRO",
  save_polis = TRUE,
  polis_filname = "emro_cases",
  polis_path = "data/",
  log_results = TRUE,
  log_file_path = "logs/"
)
```

### 2. `get_polis_api_data_parallel()` - Fast Parallel Download

3-5x faster for large date ranges. Splits requests into chunks and downloads in parallel.

```r
# Download 2 years of data in parallel
virus_data <- get_polis_api_data_parallel(
  min_date = "2022-01-01",
  max_date = "2023-12-31",
  data_type = "virus",
  region = "Global",
  date_interval = "1 month",  # Split into monthly chunks
  workers = 4                 # Number of parallel processes
)

# Fast download with weekly chunks
env_data <- get_polis_api_data_parallel(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "env",
  region = "SEARO",
  date_interval = "1 week",
  workers = 6
)
```

### 3. `update_polis_api_data()` - Incremental Updates

Fetches only new records since the last download. Ideal for scheduled updates.

```r
# Initial download and save
update_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "cases",
  region = "AFRO",
  file_path = "data/polis/",
  save_directly = TRUE,
  log_results = TRUE
)

# Run again later - automatically fetches only new data
update_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "cases",
  region = "AFRO",
  file_path = "data/polis/",
  save_directly = TRUE
)
```

### 4. `check_tables_availability()` - Check API Access

Verify which POLIS tables you can access.

```r
# Check all available tables
check_tables_availability()

# Check specific tables
check_tables_availability(
  tables_to_check = c("case", "virus", "activity")
)
```

## Available Data Types

| Type                 | Description                           |
| -------------------- | ------------------------------------- |
| `cases`              | AFP case surveillance data            |
| `virus`              | Poliovirus isolation data             |
| `env`                | Environmental surveillance samples    |
| `lab_specimen`       | Human stool specimen lab data         |
| `lab_specimen_virus` | Viruses from human specimens          |
| `lab_env`            | Environmental sample lab data         |
| `geo`                | Geographic location data              |
| `geo_synonym`        | Alternate location names              |
| `population`         | Population denominators               |
| `activity`           | Supplementary immunization activities |
| `sub_activ`          | SIA sub-activity details              |
| `lqas`               | Lot quality assurance sampling        |
| `im`                 | Independent monitoring surveys        |

## WHO Regions

- `AFRO` - African Region
- `AMRO` - Americas
- `EMRO` - Eastern Mediterranean
- `EURO` - European Region
- `SEARO` - South-East Asia
- `WPRO` - Western Pacific
- `Global` - All regions

## Common Workflows

### Weekly Automated Updates

```r
library(polisapi)

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
      log_results = TRUE
    )
  }
}
```

### Download Historical Data

```r
# 5 years of global virus data
historical <- get_polis_api_data_parallel(
  min_date = "2019-01-01",
  max_date = "2023-12-31",
  data_type = "virus",
  region = "Global",
  date_interval = "1 month",
  workers = 8,
  save_polis = TRUE,
  polis_filname = "virus_historical",
  polis_path = "data/"
)
```

### Multi-Region Comparison

```r
library(dplyr)
library(purrr)

regions <- c("AFRO", "EMRO", "SEARO")

all_cases <- map_dfr(regions, function(reg) {
  get_polis_api_data(
    min_date = "2024-01-01",
    max_date = Sys.Date(),
    data_type = "cases",
    region = reg
  ) |> mutate(Region = reg)
})
```

### Combine Case and Virus Data

```r
# Get cases and viruses for the same period
cases <- get_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "cases",
  region = "AFRO"
)

viruses <- get_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "virus",
  region = "AFRO"
)

# Join by EPID
case_virus <- dplyr::left_join(cases, viruses, by = "EPID")
```

### Download Campaign Data with Coverage

```r
# Get SIA activities
activities <- get_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "activity",
  region = "AFRO"
)

# Get LQAS quality data
lqas <- get_polis_api_data(
  min_date = "2024-01-01",
  max_date = Sys.Date(),
  data_type = "lqas",
  region = "AFRO"
)
```

## Troubleshooting

**API Key Not Found**

```r
Sys.getenv("POLIS_API_KEY")  # Should return your key
```

**Connection Timeout** - Use parallel download with smaller chunks:

```r
get_polis_api_data_parallel(..., date_interval = "1 week", workers = 4)
```

**No Data Returned** - Verify date range, region, and data_type are correct.

## License

MIT License

## Contact

**Maintainer**: Mohamed A. Yusuf
**Issues**: https://github.com/truenomad/polisapi/issues

---

**Version**: 1.1.0 | **Last Updated**: January 2026
