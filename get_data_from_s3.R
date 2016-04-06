library(jsonlite)
library(curl)
library(RJSONIO)
url <- "https://s3-eu-west-1.amazonaws.com/es-export-data/logstash-2016.02.15.json"
test <- stream_in(url(url))

con_in <- gzcon(url("http://jeroenooms.github.io/data/nycflights13.json.gz"))
con_out <- file(tmp <- tempfile(), open = "wb")
stream_in(con_in, handler = function(df){
  df <- dplyr::filter(df, distance > 1000)
  df <- dplyr::mutate(df, delta = dep_delay - arr_delay)
  stream_out(df, con_out, pagesize = 1000)
}, pagesize = 5000)
close(con_out)

test <- fromJSON("https://s3-eu-west-1.amazonaws.com/es-export-data/logstash-2016.02.15.json")
names(test)
names(test$source)
