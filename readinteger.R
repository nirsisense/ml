readinteger <- function()
{ 
  n <- readline(prompt="Enter a time window for new executions of widgets in days (i.e. 1 means yesterday's execution will be examined: ")
  n <- as.integer(n)
  if (is.na(n)){
    n <- readinteger()
  }
  return(n)
}