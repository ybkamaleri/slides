
library(data.table)
library(highcharter)
library(jsonlite)

# --------------------------------------------------
# 1. Prepare data
# --------------------------------------------------

# Copy datasets to preserve original objects
d_plot   <- copy(d)
d12_plot <- copy(d12)

setorder(d_plot, year)
setorder(d12_plot, year)

# Convert year to JavaScript timestamp (milliseconds)
d_plot[, x := as.numeric(
  as.POSIXct(paste0(year, "-01-01"), tz = "UTC")
) * 1000]

d12_plot[, x := as.numeric(
  as.POSIXct(paste0(year, "-01-01"), tz = "UTC")
) * 1000]


# --------------------------------------------------
# 2. Prepare Highcharts series
# --------------------------------------------------

# Observed rate (common to both periods)
rate_data <- list_parse2(
  d_plot[, .(x, y = rate)]
)

# Original trend: 1996-2025
trend_data <- list_parse2(
  d_plot[, .(x, y = trend)]
)

# Original confidence interval
ci_data <- list_parse2(
  d_plot[, .(x, low = lwr, high = upr)]
)

# Alternative trend: 2012-2025
trend12_data <- list_parse2(
  d12_plot[, .(x, y = trend)]
)

# Alternative confidence interval
ci12_data <- list_parse2(
  d12_plot[, .(x, low = lwr, high = upr)]
)


# --------------------------------------------------
# 3. JavaScript event: switch trend and CI
# --------------------------------------------------

switch_trend <- JS("
function(e) {

  var chart = this.chart;

  // Get the minimum selected year
  var min = (typeof e.min === 'number')
      ? e.min
      : this.dataMin;

  // Determine which trend should be displayed
  var use2012 = min >= Date.UTC(2012, 0, 1) - 86400000;

  var s = chart.series;

  // Series 0: Original confidence interval
  // Series 1: Alternative confidence interval
  // Series 2: Observed rate
  // Series 3: Original trend
  // Series 4: Alternative trend

  if (s.length >= 5) {

    // Switch confidence intervals
    s[0].setVisible(!use2012, false);
    s[1].setVisible(use2012, false);

    // Switch trend lines
    s[3].setVisible(!use2012, false);
    s[4].setVisible(use2012, false);

    // Redraw chart once
    chart.redraw();
  }
}
")


# --------------------------------------------------
# 4. Create Highcharts Stock chart
# --------------------------------------------------

fig_trend <- highchart(type = "stock") %>%

  # Original confidence interval
  hc_add_series(
    name = "95% CI (1996)",
    type = "arearange",
    data = ci_data,
    color = "#90A4AE",
    fillOpacity = 0.25,
    lineWidth = 0,
    zIndex = 0,
    visible = TRUE,
    showInLegend = FALSE,
    marker = list(enabled = FALSE)
  ) %>%

  # Alternative confidence interval
  hc_add_series(
    name = "95% CI (2012)",
    type = "arearange",
    data = ci12_data,
    color = "#FFB74D",
    fillOpacity = 0.25,
    lineWidth = 0,
    zIndex = 1,
    visible = FALSE,
    showInLegend = FALSE,
    marker = list(enabled = FALSE)
  ) %>%

  # Observed rate
  hc_add_series(
    name = "Rate",
    type = "line",
    data = rate_data,
    color = "#1565C0",
    lineWidth = 2,
    zIndex = 3,
    marker = list(
      enabled = TRUE,
      radius = 3
    )
  ) %>%

  # Original trend
  hc_add_series(
    name = "Trend (1996)",
    type = "line",
    data = trend_data,
    color = "#D32F2F",
    lineWidth = 2.5,
    zIndex = 4,
    visible = TRUE,
    marker = list(enabled = FALSE)
  ) %>%

  # Alternative trend
  hc_add_series(
    name = "Trend (2012)",
    type = "line",
    data = trend12_data,
    color = "#2E7D32",
    lineWidth = 2.5,
    zIndex = 5,
    visible = FALSE,
    marker = list(enabled = FALSE)
  ) %>%

  # Chart title
  hc_title(
    text = "Narkotikautløste dødsfall, 1996-2025"
  ) %>%

  hc_subtitle(
    text = "Aldersstandardisert rate for narkotikautløste dødsfall per 100 000 innbyggere"
  ) %>%

  # X-axis
  hc_xAxis(
    type = "datetime",
    title = list(text = "År"),
    labels = list(
      format = "{value:%Y}"
    ),
    events = list(
      afterSetExtremes = switch_trend
    )
  ) %>%

  # Y-axis
  hc_yAxis(
    title = list(text = "Rate"),
    min = 0
  ) %>%

  # Range selector
  hc_rangeSelector(
    enabled = TRUE,
    selected = 0,
    inputEnabled = FALSE,
    zoomText = "",  # Remove redundant "Zoom" label
    buttons = list(
      list(
        type = "all",
        text = "1996-2025"
      ),
      list(
        type = "year",
        count = 13,
        text = "2012-2025"
      )
    )
  ) %>%

  # Tooltip
  hc_tooltip(
    shared = TRUE,
    crosshairs = TRUE,
    xDateFormat = "%Y",
    valueDecimals = 2
  ) %>%

  # Legend
  hc_legend(
    enabled = TRUE,
    align = "center",
    verticalAlign = "bottom"
  ) %>%

  # Chart settings
  hc_chart(
    zoomType = "x",
    backgroundColor = "#FFFFFF"
  )

