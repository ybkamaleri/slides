
library(highcharter)
library(dplyr)

fig_rate <- hchart(
  ratenor,
  type = "area",
  hcaes(x = year, y = rate)
) %>%
  hc_title(
    text = "Aldersstandardisert rate for narkotikautløste dødsfall per 100 000 innbyggere, 1996–2018"
  ) %>%
  hc_xAxis(
    title = list(text = ""),
    allowDecimals = FALSE,
    tickInterval = 1,
    labels = list(rotation = -90, step = 1)
  ) %>%
  hc_yAxis(
    title = list(text = "Antall dødsfall per 100 000 innbyggere"),
    min = 0
  ) %>%
  hc_plotOptions(
    area = list(
      fillOpacity = 0.30,
      marker = list(
        enabled = TRUE,
        radius = 3
      ),
      lineWidth = 2
    )
  ) %>%
  hc_tooltip(
    useHTML = TRUE,
    headerFormat = "",
    pointFormat = paste0(
      "<b>År:</b> {point.x}<br/>",
      "<b>Rate:</b> {point.y:.2f}"
    )
  ) %>%
  hc_legend(
    enabled = FALSE
  ) %>%
  hc_credits(
    enabled = FALSE
  ) |>
  highcharter::hc_colors(highdir::get_palette("hdir"))
