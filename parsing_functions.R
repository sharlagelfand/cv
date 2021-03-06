# Regex to locate links in text
find_link <- regex("
  \\[   # Grab opening square bracket
  .+?   # Find smallest internal text as possible
  \\]   # Closing square bracket
  \\(   # Opening parenthesis
  .+?   # Link text, again as small as possible
  \\)   # Closing parenthesis
  ",
  comments = TRUE
)

# Function that makes links italic
sanitize_links <- function(text) {
  if (PDF_EXPORT) {
    links <- str_extract_all(text, find_link) %>%
      pluck(1)

    links %>%
      walk(function(link_from_text) {
        title <- link_from_text %>%
          str_extract("\\[.+\\]") %>%
          str_remove_all("\\[|\\]")
        link <- link_from_text %>%
          str_extract("\\(.+\\)") %>%
          str_remove_all("\\(|\\)")

        # Build replacement text
        new_text <- glue("[<i>{title}</i>]({link})")

        # Replace text
        text <<- text %>% str_replace(fixed(link_from_text), new_text)
      })
  }
  text
}

# Take entire positions dataframe and removes the links
# in descending order so links for the same position are
# right next to eachother in number.
strip_links_from_cols <- function(data, cols_to_strip) {
  for (i in 1:nrow(data)) {
    for (col in cols_to_strip) {
      data[i, col] <- sanitize_links(data[i, col])
    }
  }
  data
}

# Take a position dataframe and the section id desired
# and prints the section to markdown.
print_section <- function(position_data, section_id) {
  position_data %>%
    dplyr::filter(section == section_id) %>%
    dplyr::mutate(end = case_when(is.na(end) ~ lubridate::today() + lubridate::days(1),
                                  TRUE ~ end)) %>%
    dplyr::arrange(dplyr::desc(end), dplyr::desc(start)) %>%
    dplyr::mutate(id = 1:dplyr::n()) %>%
    tidyr::pivot_longer(
      starts_with("description"),
      names_to = "description_num",
      values_to = "description"
    ) %>%
    dplyr::filter(!is.na(description) | description_num == "description_1") %>%
    dplyr::group_by(id) %>%
    dplyr::mutate(
      descriptions = list(description),
      no_descriptions = is.na(first(description))
    ) %>%
    dplyr::ungroup() %>%
    dplyr::filter(description_num == "description_1") %>%
    dplyr::mutate_at(dplyr::vars(start, end), .funs = list(month = ~ lubridate::month(.x, label = TRUE, abbr = TRUE), year = ~ lubridate::year(.x))) %>%
    dplyr::mutate(timeline = case_when(end > lubridate::today() & start != end ~ glue::glue("{start_month}. {start_year} - Present"),
                                        simplify_date_to_year ~ glue::glue("{start_year} - {end_year}"),
                                       start == end ~ glue::glue("{start_month}. {start_year}"),
                                       TRUE ~ glue::glue("{start_month}. {start_year} - {end_month}. {end_year}"))) %>%
    dplyr::mutate(
      description_bullets = ifelse(
        no_descriptions,
        " ",
        purrr::map_chr(descriptions, ~ paste("-", ., collapse = "\n"))
      )
    ) %>%
    strip_links_from_cols(c("title", "description_bullets")) %>%
    dplyr::mutate_all(~ ifelse(is.na(.), "N/A", .)) %>%
    glue::glue_data(
      "### {title}",
      "\n\n",
      "{loc}",
      "\n\n",
      "{institution}",
      "\n\n",
      "{timeline}",
      "\n\n",
      "{description_bullets}",
      "\n\n\n",
    )
}
