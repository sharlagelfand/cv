# Render CVs

# For online (with links in colour)
rmarkdown::render("index.Rmd", output_file = "index.html", params = list(PDF_EXPORT = FALSE))

# For PDF (with black italic links)
rmarkdown::render("index.Rmd", output_file = "cv_for_pdf.html", params = list(PDF_EXPORT = TRUE))
