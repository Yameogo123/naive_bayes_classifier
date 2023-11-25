## code to prepare `DATASET` dataset goes here

library(readr)


students= readr::read_csv("data-raw/student_portuguese_clean.csv", sep=",")

usethis::use_data(students, overwrite = TRUE, compress = "xz")



