library(highcharter)
library(dplyr)


fig_antall <- hchart(
  numnor,
  type = "area",
  hcaes(x = year, y = antall)
) %>%
  hc_title(
    text = "Antall narkotikautløste dødsfall, 1996–2025"
  ) %>%
  hc_xAxis(
    title = list(text = ""),
    allowDecimals = FALSE,
    tickInterval = 1,
    labels = list(rotation = -90, step = 1)
  ) %>%
  hc_yAxis(
    title = list(text = "Antall dødsfall"),
    min = 0,
    labels = list(  
      format = "{value:.0f}"  #ensure no decimal
    )
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
    valueDecimals = 0,
    pointFormat = paste0(
      "<b>År:</b> {point.x}<br/>",
      "<b>Antall:</b> {point.y:.0f}"
    )
  ) %>%
  hc_legend(
    enabled = FALSE
  ) %>%
  hc_credits(
    enabled = FALSE
  ) |>
  highcharter::hc_colors(highdir::get_palette("hdir"))
