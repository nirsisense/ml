s3_handler_data_stream_in <- function(bucket_suffix,url){
  con <- paste(url,bucket_suffix,sep="") 
  data.set <- stream_in(url(con), handler = function(df){
    df <- flatten(df)
    df <-  filter(df,as.numeric(as.character(df$`_source.duration`)) >=0 & !is.na(df$`_source.widget`))
    #df <- dplyr::filter(df, distance > 1000)
    #df <- dplyr::mutate(df, delta = dep_delay - arr_delay)
    stream_out(df)
  }, pagesize = 5000)
  
  return (data.set)
}
s3_curl_pipline <- function(bucket_suffix,url){
  con <- paste(url,bucket_suffix,sep="")
  curl(con) %>%
    fromJSON (flatten = TRUE) %>%
    filter ('_source.duration' > 0) #%>%
    #select ()
}