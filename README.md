---
editor_options: 
  markdown: 
    wrap: 72
---

# polisapi

## Overview

This R package designed to simplify the process of downloading data from
the Polio Information System ([POLIS](https://extranet.who.int/polis/))
database through an API, which is part of the World Health Organization
(WHO) and is dedicated to supporting the Global Polio Eradication
Initiative ([GPEI](https://polioeradication.org/)). POLIS serves as a
global repository for Polio-related information, including cases and
vaccination campaigns across the remaining infected and endemic
countries.

## Installation

Install the package directly using devtools.

``` r
# Install devtools if you haven't already
install.packages("devtools")

# Install the POLIS API Downloader package from GitHub
devtools::install_github("truenomad/POLISAPI")
```

## Access and Authentication

Before using the package, individuals need to be granted access by the
POLIS team and provided with an access token. It's advisable to securely
save your access token in the R environment, enhancing security and
facilitating easy access across R scripts and sessions.

``` r
# Load the POLIS API Downloader package
library(POLIS_API)

# Set your access token securely in the R environment
usethis::edit_r_environ()
# Add the following line to your .Renviron file:
# POLIS_ACCESS_TOKEN = "your_access_token"

# Set up your token as object to use later
my_token = Sys.getenv("POLIS_ACCESS_TOKEN")
```

## Usage

The package offers two primary methods for POLIS API interaction:

### 1. Direct Data Retrieval: `get_polis_api_data`

Retrieve data directly from the POLIS API for immediate analysis.

-   Suitable for one-off data extraction or personal data handling.

-   Offers detailed control over data retrieval parameters.

#### Usage Example

``` r
# Fetch case data for a specific period and region
data <- get_polis_api_data(
  min_date = "2021-01-01",    
  max_date = "2021-01-31",
  data_type = "cases",
  region = 'AFRO',
  select_vars = NULL,
  polis_api_key = my_token
)
```

### 2. Data Updates: `update_polis_api_data`

Use this for periodic data updates, minimizing redundant retrievals.

-   Checks for existing data and fetches new records.

-   Features built-in logging for update tracking.

#### Usage Example

``` r
# Periodically update case data for a specific period and region
update_polis_api_data(
  min_date = "2021-01-01",    
  max_date = Sys.Date(),
  data_type = "cases",
  region = 'AFRO',
  select_vars = NULL,
  file_path = my_path_to_save_data,
  save_directly = TRUE,
  log_results = TRUE,
  polis_api_key = my_token
)
```

## Data Types

The POLIS API provides diverse datasets for download:

-   **Cases Data (`"cases"`):** Detailed polioviruses cases data.
-   **Virus Data (`"virus"`):** Virus are all data related with Viruses.
-   **Population Data (`"population"`):** Data on all references
    population used in POLIS.
-   **Environmental Data (`"env"`):** Data on all environmental samples
    collected.
-   **Geographical Data (`"geo"`):** All references places used in
    POLIS.
-   **Geographical Synonym Data (`"geo_synonym"`):** Alternate location
    names.
-   **Independent Monitoring Data (`"im"`):** Describes quality after
    vaccination campaigns.
-   **Activity Data (`"activity"`):** Information all actions taken
    against Poliovirus
-   **Sub-activities Data (`"sub_activ"`):** Details on specific
    sub-activities taken against Poliovirus.
-   **Lot Quality Assurance Sampling Data (`"lqas"`):** Describes
    quality of vaccination campaigns.
-   **Lab Specimen Data (Human & Viruses) (`"lab_specimen"` &
    `"lab_specimen_virus"`):** Details on human specimens and viruses;
    all specimens sent to laboratories to be investigated
