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
