quarto::quarto_render("rapport.qmd", output_format = "typst")
utils::browseURL("rapport.pdf")

quarto::quarto_render("rapport.qmd", output_format = "html")
utils::browseURL("rapport.html")
