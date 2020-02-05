# Render CVs

# For online (with links in colour)
rmarkdown::render("index.Rmd", output_file = "index.html", params = list(PDF_EXPORT = FALSE))

# Update on blog :~)
fs::file_copy("index.html", "/Users/sharla/github/sharlaparty/content/cv/index.html", overwrite = TRUE)
usethis::proj_activate("/Users/sharla/github/sharlaparty/")

# For PDF (with black italic links)
rmarkdown::render("index.Rmd", output_file = "cv_for_pdf.html", params = list(PDF_EXPORT = TRUE))
