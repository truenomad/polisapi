# polisapi 1.1.0

## New Features

- Initial release of the polisapi package
- Sequential data retrieval via `get_polis_api_data()`
- Parallel downloads via `get_polis_api_data_parallel()` for faster large-scale retrieval
- Incremental updates via `update_polis_api_data()` to fetch only new data
- Support for 12+ POLIS data types including:
  - Case data (`cases`)
  - Virus isolates (`virus`)
  - Population data (`population`)
  - Environmental surveillance (`env`)
  - Geographic data (`geo`, `geo_synonym`)
  - Laboratory specimens (`lab_specimen`, `lab_env`, `lab_specimen_virus`)
  - Campaign activities (`activity`, `sub_activ`)
  - Independent monitoring (`im`)
  - LQAS data (`lqas`)
- Regional filtering by WHO region (AFRO, AMRO, EMRO, EURO, SEARO, WPRO)
- Variable selection to optimize bandwidth
- Built-in logging for tracking data retrieval sessions
- Data archiving with configurable retention

## API Changes (January 2026)

- Updated OData date filter syntax for POLIS .NET upgrade compatibility
- Date filters now use simplified format: `field ge 2025-01-01` (previously `field ge DateTime'2025-01-01'`)
