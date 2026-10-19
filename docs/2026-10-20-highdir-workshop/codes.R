# Demo 1 
# ------------------------------------------------------------------------------
# install.packages("highdir")
# remotes::install_github("folkehelsestats/highdir") #dev versjon

library(data.table)
library(highdir)

dt1 <- fread("c://Users//ykama//Git-hdir//dataset//region-data.csv")

spec <- hd_spec(data = dt1,
                x = "region",
                y = "rate",
                n = "n")

opts <- hd_opts(title = "Regioner i Norge", subtitle = "For demonstrasjon")

fig <- hd_make(spec, "column", opts)
fig

fig <- hd_make(spec, "column", opts, mode = "static")
fig

# Tips 1
help(hd_spec)
geom_args("ranked_bar")


# Demo 2
# ------------------------------------------------------------------------------

