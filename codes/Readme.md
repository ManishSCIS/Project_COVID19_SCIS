# CoSymple — COVID-19 Dashboard (India)

CoSymple is an interactive analytical dashboard for COVID-19 data across Indian states/UTs (March 2020 – October 2021), built with R Shiny. Developed at JNU New Delhi under ICMR funding.

**Browser Title:** CoSymple | COVID-19 Dashboard India
**Live App:** [shinyapps.io deployment](https://v3srmu-manishscis.shinyapps.io/MoranIndex/)
**Source Data:** [GitHub Repository](https://github.com/ManishSCIS/Project_COVID19_SCIS)

---

## Running the App

```r
# From R console, set working directory to this folder first
setwd("path/to/codes")
shiny::runApp()
```

To deploy to shinyapps.io:
```r
rsconnect::deployApp()
```

> **Note:** Startup takes 30–60 seconds — `global.R` downloads 3 datasets from GitHub and runs 999 × 3 Monte Carlo Moran's I simulations on startup.

---

## File Structure

```
codes/
├── global.R          # Runs once at startup: loads data, builds all pre-computed objects
├── server.R          # Renders pre-computed objects; reactive forecast and state filter
├── ui.R              # shinydashboard UI with 4 sidebar tabs
├── CLAUDE.md         # Guidance for Claude Code
├── Readme.md         # This file
├── data/
│   ├── data_moran.shp / .dbf / .prj / .shx   # Shapefile for spatial analysis
│   ├── custom_data.shp / .dbf / .prj / .shx   # Custom shapefile
│   └── dataset1.csv / dataset2.csv / dataset3.csv  # Local data copies
└── www/
    ├── conf.png      # Pre-generated choropleth: Confirmed cases
    ├── rec.png       # Pre-generated choropleth: Recovered cases
    ├── dec.png       # Pre-generated choropleth: Deceased cases
    └── act.png       # Pre-generated choropleth: Active cases
```

---

## Dashboard Tabs

### 1. Dashboard
The main overview tab with three inner sub-tabs:

- **Location** — Four value boxes at the top showing all-India totals (Confirmed, Recovered, Active, Deceased). Below, an interactive Leaflet map shows state-wise markers with popup details, placed side-by-side with a bar chart of the Top-5 states.
- **Bar-Charts** — A full-width grouped bar chart showing Confirmed, Recovered, Deceased, and Active counts for all Indian states/UTs by their state code.
- **Data Table** — A sortable, searchable cumulative data table listing all states/UTs with their case counts, arranged by descending confirmed cases.

---

### 2. Forecast
Time series forecasting with four inner sub-tabs:

- **Trend Charts** — A state dropdown (37 states/UTs + India Total) and a Download Data button. Shows two plots: a state-wise trend chart (confirmed, recovered, deceased) for the selected state, and a collapsible all-India trend chart.
- **Forecast Models** — A model dropdown (GRNN, ARIMA, ETS) and a "Days to Forecast" slider (1–100 days). Shows two side-by-side plots:
  - *Forecast with History* — full historical series plus the forecast with confidence bands
  - *Prediction Only* — the forecast period only
- **Model Comparison** — Two components:
  - *Accuracy Table* — RMSE, MAE, MAPE for all three models evaluated on a 30-day holdout test (lower is better)
  - *Comparison Chart* — Overlaid point forecasts from GRNN (blue), ARIMA (red), and ETS (green) for the selected forecast horizon
- **Data Table** — Scrollable raw state-wise daily data table with horizontal scroll support.

---

### 3. Spatial Statistics
Spatial analysis of COVID-19 case distribution with three inner sub-tabs:

- **Spatial-Plots** — Pre-generated choropleth maps for Confirmed & Recovered cases (top box) and Deceased & Active cases (collapsible box). A link button opens an external interactive map page.
- **OLS-Plots** — Three OLS Moran scatter plots (one each for Confirmed, Recovered, and Deceased), each in a collapsible box. Each plot shows the relationship between case counts and their spatially-lagged values with a fitted regression line.
- **Monte-Carlo Test** — Three Monte Carlo simulation plots and their corresponding summary outputs, one for each case type. Tests spatial autocorrelation (Moran's I) using 999 simulations.

---

### 4. Github Repository
A simple page with links to:
- The full source code repository on GitHub
- The downloadable raw datasets used in the dashboard

---

## Key Packages

| Package | Purpose |
|---------|---------|
| `shinydashboard` + `dashboardthemes` | Dashboard layout and theming |
| `leaflet` | Interactive map |
| `plotly` | Interactive charts throughout |
| `tsfgrnn` | GRNN (General Regression Neural Network) forecasting |
| `forecast` | ARIMA (`auto.arima`) and ETS forecasting |
| `spdep` | Spatial weights and Moran's I Monte Carlo simulation |
| `sf` + `tmap` | Shapefile reading and choropleth maps |
| `vars` / `fpp2` | Time series support |

Install all dependencies:
```r
install.packages(c(
  "shiny", "shinydashboard", "dashboardthemes", "flexdashboard",
  "data.table", "sf", "spdep", "tmap", "tidyverse", "dplyr",
  "dbplyr", "ggplot2", "plotly", "readr", "leaflet", "lubridate",
  "tsfgrnn", "forecast", "vars", "fpp2", "rsconnect"
))
```

---

## Responsive Design

The UI is optimised for desktop, tablet, and mobile browsers:
- All plotly charts use `config(responsive=TRUE)` and fill their containers
- Choropleth images scale to screen width (`width: 100%; height: auto`)
- Value box numbers scale fluidly with viewport using CSS `clamp()`
- Side-by-side layouts stack vertically on narrow screens (Bootstrap grid)
- Horizontal scroll prevented on content wrapper; box content clipped cleanly

---

*Project In-charge: Dr. Pallavi Somvanshi, Associate Professor, SCIS, JNU New Delhi*
*Project Assistant: Mr. Manish (Ph.D Scholar), JNU New Delhi*
*Funding: ICMR, New Delhi, India*
