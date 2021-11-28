# Core Packages -----------------------------------------------------------
install.packages(c("xaringan", "metathis"))
install.packages("xaringanthemer", dependencies = TRUE)


# Extra Packages ----------------------------------------------------------
install.packages("remotes")
remotes::install_github("gadenbuie/xaringanExtra", force = TRUE)

install.packages("fontawesome")

remotes::install_github("helseprofil/orgdata", force = TRUE)
