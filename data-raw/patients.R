

## code to prepare `DATASET` dataset goes here

library(readr)


patients= readr::read_csv("data-raw/ocd_patient_dataset.csv")

usethis::use_data(patients, overwrite = TRUE, compress = "xz")

