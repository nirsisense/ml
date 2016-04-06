pkgTest <- function(x)
{
  if (!require(x,character.only = TRUE))
  {
    install.packages(x,dep=TRUE,repos = 'http://star-www.st-andrews.ac.uk/cran/')
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}