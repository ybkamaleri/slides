# Demo 1 
# ------------------------------------------------------------------------------
# install.packages("highdir")
# remotes::install_github("folkehelsestats/highdir") #dev versjon

library(data.table)
library(highdir)

survey <- fread("c://Users//ykama//Git-hdir//dataset//survey-data.csv")

spec_col <- hd_spec(survey,
                    x     = "alder",
                    y     = "pct",
                    group = "kjonn",
                    n     = "n")

opts_col <- hd_opts(
  title    = "Alcohol use by age group and kjonn",
  subtitle = "Source: Norwegian Directorate of Health",
  ylim     = c(0, 100),
  yint     = 20,
  ylab     = "Percentage (%)"
)

# Dynamisk (default)
fig <- hd_make(spec_col, "column", opts_col)
fig

fig <- hd_make(spec_col, "column", opts_col, mode = "static")
fig

hd_save(fig, "fig01.html")

# Tips 1
help(hd_spec)


# Demo 2
# ------------------------------------------------------------------------------

dt <- fread("c://Users//ykama//Git-hdir//dataset//region-data.csv")

spec <- hd_spec(dt, x = "fylke", y = "prosent", n = "n")
opts <- hd_opts(title = "Fylker i Norge",
                subtitle = "Demo dataset",
                flip = TRUE)

hd_make(spec, "ranked_bar", opts, vs = "Norge", aim = 50)
hd_make(spec, "ranked_bar", opts, vs = "Norge", aim = 50, mode = "static")

# Tips 2
geom_args("ranked_bar")


# Demo 3
# ------------------------------------------------------------------------------

hd_app()



# Demo 4
# ------------------------------------------------------------------------------
library(data.table)
library(highdir)

dt2 <- fread("c://Users//ykama//Git-hdir//dataset//data-ci-grp.csv")

spec <- hd_spec(
  data  = dt2,
  x = "year",
  y = "adj_mean",
  group = "kjonn2",
)

opts <- hd_opts(
  xlab = " ",
  ylab = " ",
  yint = 10,
)

hd_make(
  spec    = spec,
  opts    = opts,
  type = "arearange",
  mode = "dynamic",
  use_js  = TRUE,
  ymin = "lower_95CI",
  ymax = "upper_95CI",
)


# Demo 5
# ------------------------------------------------------------------------------
library(highdir)

olympics <- data.frame(
    Country   = rep(c("Norway", "Germany", "United States", "Canada"), each = 3),
    Continent = rep(c("Europe", "Europe", "North America", "North America"), each = 3),
    Medal     = rep(c("Gold", "Silver", "Bronze"), times = 4),
    Count     = c(148, 133, 124, 102, 98, 65, 113, 122, 95, 77, 72, 80)
)

# Define Specification and Options
spec_st <- hd_spec(olympics,
    x     = "Medal",
    y     = "Count",
    group = "Country"
)

opts_st <- hd_opts(
    title    = "Olympic Games all-time medal table, grouped by continent",
    subtitle = "Source: Olympics",
    ylab     = "Count medals",
    flip = TRUE
)

hd_make(spec_st, "stacked_column", opts_st, stacking = "percent")
hd_make(spec_st, "stacked_column", opts_st, mode = "static", stacking = "percent")
