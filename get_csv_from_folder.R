get_csv_from_folder <- function(folder.name){
  setwd(folder.name)
  files = list.files(pattern="*.csv") 
  #files <- files[c(1:3)]
  file.data.list <- lapply(files, function(x) read.table(x, header = F, fill = T, sep=",", quote ="\"", skip = 1))
  #widget.files = do.call(rbind, lapply(files, function(x) read.table(x, stringsAsFactors = FALSE, header = F, fill = T, sep=",", quote ="\"")))
  #widget.data <- do.call(rbind.fill, lapply(files, function(x) read.table(x, stringsAsFactors = FALSE, header = F, fill = T, sep=",", quote ="\"")))
  widget.data <- rbind_all(file.data.list)
  return (widget.data) 
}
get_csv_from_folder_build <- function(folder.name){
  setwd(folder.name)
  files = list.files(pattern="build_duration.csv")
  file.data.list <- lapply(files, function(x) read.table(x, header = T, fill = T, sep=",", quote ="\""))
  #test.file.data <- read.table(files[[1]], stringsAsFactors = FALSE, header = F, fill = T, sep=",", quote=NULL)
  build.data = do.call(rbind, lapply(files, function(x) read.table(x, stringsAsFactors = FALSE, header = T, fill = T, sep=",", quote ="\"")))
  #names(widget.files) <- c('timestamp', 'host', 'cubeName', 'dashboard', 'widget', 'sisenseuid', 'status', 'duration', 'action')
  #DT = do.call(rbind, lapply(files, fread))
  return (build.data)
}