# writing results of your code to a file is not simple on Windows
# because of issues with Arabic. 

v <- c("ABC", "ابج")

# one approach: use the write_lines or write_file functions from the package readr: 
library(readr)
write_lines(v, "test.txt")  # first argument: character vector, second argument: file path
write_file(paste(v, collapse="\n"), "test.txt")

# This is a workaround (writing a string as bytes):
result <- paste(v, collapse="\n\n") # collapse the vector into a single string
writeBin(charToRaw(result), choose.files(), endian="little")

# alternatively:
#install.packages("enc")  # enc is short for "encoding"
library("enc")
v <- c("ABC", "ابج")
enc::write_lines_enc(v, choose.files()) 

# NB: writeBin takes a character vector with only one element as input;
# write_lines_enc takes a character vector of any size