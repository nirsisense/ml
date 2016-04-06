print ("START") 
startTime <- Sys.time()
print (paste("start time = ",startTime, sep=""))
setwd("/home/sisense/Documents/anomaly")
print(getwd())
source("pkgTest.R")
pkgTest("ggplot2")
pkgTest("stringr")
pkgTest("devtools")
pkgTest("caret")
pkgTest("data.table")
pkgTest("yaml")
pkgTest("plyr")
pkgTest("dplyr")
pkgTest("devtools")
config = yaml.load_file("conf.yml")
source("get_csv_from_folder.R")
source("readinteger.R")
source("build_draw_duration_distribution.R")
# get input from user to assign new data time window parameter in week
new.data.time.windows <- as.integer(config$window)

# temp location
location <- "/home/sisense/Documents/anomaly/data"
print("Time to retrieve data...")
system.time(build.data <- get_csv_from_folder_build(location))
names.data <- c("id"	,"Date"	,"ip"	,"eCube"	,"AdminEmail"	,"action"	,"ver"	,"duration")
colnames(build.data) <- names.data
#names.df <- c("dashboard","widget","event","query_type","status","cube_name","cube_id","startQueryTimeStamp","endQueryTimeStamp","duration","value","concurrentQuery","status","ts","host")
#duration.data <- read.table(file="durations.csv", sep = "|", quote = "",fill = T, header = T)
#names(duration.data) <- names.df
attach(build.data)
#duration.data.proj <- duration.data[,c("dashboard","status","@timestamp","duration","concurrentQuery")]
#attach(duration.data.proj) 
build.data$Date <- as.Date(build.data$Date, "%m/%d/%y")
build.data$duration <- as.numeric(as.character(build.data$duration))
build.data$key <- paste(ip,eCube,ver,sep="|")

attach(build.data)
# remove rows with blank widget or cube names
build.data <- build.data[!(is.na(build.data$eCube) | build.data$eCube == ""), ]
build.data <- build.data[!(is.na(build.data$ver) | build.data$ver ==""), ]

print("Time to split data (per build) ...")
system.time(build.groups.list <- split(build.data, build.data$key))
print(paste("All in all ...",length(build.groups.list)," builds will be analyzed", sep=""))

alert.df <- data.frame(DateRange=as.character(character()),
                 build=character(), 
                 alertType=character(),
                 alertScore=integer(),
                 user=character())
                  
names(alert.df) <- c("build","DateRange","alertType","alertScore","user")
setwd("/home/sisense/Documents/anomaly/outputs")
print("Time to filter data...")
system.time(cond <- lapply(build.groups.list, function(x) nrow(x) > 5))
system.time(build.groups.list <- build.groups.list[unlist(cond)])

# call t test analysis and visualizations
print("Time to run statistical analysis...")
system.time(alert.list <- lapply(build.groups.list,build_draw_duration_distribution,new.data.time.windows))
# post process alerts list
#num_elements_list <- sapply(alert.list,length)
alert.list <- alert.list[!is.null(alert.list)]
#alert.list.clean <- alert.list[unlist(sapply(alert.list,function(x) length(x) > 3))]
alert.list.clean <- alert.list[sapply(alert.list, length) == 5]
#alert.list.reg <- alert.list[lapply(alert.list,length)>0]
#alert.list.flattened <- do.call(c, unlist(alert.list, recursive=FALSE))
alert.df.clean <- do.call(rbind.data.frame, alert.list.clean)
names(alert.df.clean) <- c("buildtKey","DateRange","alertType","alertScore","user")
alert.df.clean$alertScore <- as.numeric(as.character(alert.df.clean$alertScore))
alert.df.clean$NormalizedAlertScore <- 1 - 
  (alert.df.clean$alertScore - min(alert.df.clean$alertScore,na.rm = T)) / 
  (max(alert.df.clean$alertScore,na.rm = T) - min(alert.df.clean$alertScore, na.rm = T))
alert.df.clean$alertScore <- NULL
print("writing build alerts csv file locally...")
write.csv(x=alert.df.clean, file=paste(Sys.Date(),"_builds_alerts.csv",sep=""), col.names = T, row.names = F)
print("writing alerts csv file to aws s3")
#system(paste0('aws s3 cp ',alert.df.clean,' s3://my-bucket-name/'))
#system(paste0('rm ',fn))
save.image("/home/sisense/Documents/anomaly/images/duration_data.RData")
  
endTime <- Sys.time()
print (paste("end time = ",endTime, sep="")) 
elapsedTime =difftime(endTime, startTime, units = "hours")
print (paste("total elapsed time in hours = ",elapsedTime, sep=""))  