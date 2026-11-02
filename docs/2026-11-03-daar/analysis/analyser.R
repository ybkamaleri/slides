
library(data.table)
library(highcharter)
library(rio)
library(highdir)


path24 <- "C:\\Users\\ykama\\OneDrive - Helsedirektoratet\\dataset\\daar\\data2024"
path <- "C:\\Users\\ykama\\OneDrive - Helsedirektoratet\\dataset\\daar\\data2025"

## Antall og rater
## ---------------
filRate24 <- "Narkotikautløste dødsfall etter bofylke og dødsårsak, rater norge fylke.csv"
filRate <- "Narkotikautløste dødsfall etter bofylke og dødsårsak, rater.csv"

filN <- "Hovedkategorier 1996-2025.xlsx"


drate24 <- fread(file.path(path24, filRate24), encoding = "Latin-1")
# dnum24 <- setDT(rio::import(file.path(path24, filN24), encoding = "Latin-1"))
drate <- fread(file.path(path, filRate), encoding = "Latin-1")
# dnum <- (file.path(path, filN), encoding = "Latin-1")
dnum <- setDT(rio::import(file.path(path, filN), encoding = "Latin-1"))

keep_country <- function(dt, col = c("rate", "n")) {
  data.table::copy(dt)
  dt <- dt[Bofylke == "Hele landet", c(1, 4)]
  data.table::setnames(dt, c("year", col))
  return(dt)
}

ratenor24 <- keep_country(drate24, "rate")
ratenor   <- keep_country(drate, "rate")
numnor    <- dnum[, 1:2]

data.table::setnames(numnor, c("year", "antall"))
numnor[, antall := round(antall, 0)]

## Beholder den nyeste data fra 2025
yrmin <- ratenor[, min(year)]
ratenor24 <- ratenor24[year < yrmin]

ratenor <- rbindlist(list(ratenor24, ratenor), use.names = TRUE)

pred_rate <- function(dt){
  data.table::copy(dt)
  model <- stats::lm(rate ~ year, data = dt)
  dt[, trend := stats::predict(model)]

  dt[, c("lwr", "upr") :=
         as.data.table(
           stats::predict(
             model,
             newdata = .SD,
             interval = "confidence"
           )
         )[, .(lwr, upr)]]
}

d <- pred_rate(ratenor)
vars <- c("rate", "trend")
d[, (vars) := lapply(.SD, function(x) round(x, 1)), .SDcols = vars]
# dtrate <- melt(d, id.vars = "year", measure.vars = vars)


d12 <- pred_rate(ratenor[year > 2011])
vars <- c("rate", "trend")
d12[, (vars) := lapply(.SD, function(x) round(x, 1)), .SDcols = vars]
# dtrate12 <- melt(d12, id.vars = "year", measure.vars = vars)


## Geografisk fordeling
## --------------------

filFylkeN <- "Narkotikautløste dødsfall etter bofylke og dødsårsak, antall.csv"
filFylkeR <- "Narkotikautløste dødsfall etter bofylke og dødsårsak, rater.csv"

fnum <- setDT(rio::import(file.path(path, filFylkeN), encoding = "Latin-1"))
frate <- setDT(rio::import(file.path(path, filFylkeR), encoding = "Latin-1"))

fn <- fnum[, c(1,2,4)]
fr <- frate[, c(1,2,4)]

data.table::setnames(fn, c("year", "fylke", "antall"))
data.table::setnames(fr, c("year", "fylke", "rate")) #Aldersstandardisert per 100 000

fn[is.na(antall), antall  := 0] #anonymisert eller skjult pga. andre årsaker
fr[is.na(rate), rate  := 0] #anonymisert eller skjult pga. andre årsaker

fn <- fn[fylke != "Hele landet"]
fr <- fr[fylke != "Hele landet"]

