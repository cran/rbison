## ----echo=FALSE---------------------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  fig.width = 6,
  fig.height = 4,
  comment = "#>",
  collapse = TRUE,
  warning = FALSE,
  message = FALSE,
  purl = NOT_CRAN,
  eval = NOT_CRAN
)

