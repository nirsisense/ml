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
source("draw_duration_distribution.R")
# get input from user to assign new data time window parameter in week
new.data.time.windows <- as.integer(config$window)

#setwd("./data")
s3.location <- "/home/sisense/es-saved-searches/responsiveness"
print("Time to retrieve data...")
system.time(s3.duration.data <- get_csv_from_folder(s3.location))
names.data <- c("timestamp","host","cubeName","dashboard","widget","sisenseuid","status","duration","action","sisenseVersion")
colnames(s3.duration.data) <- names.data
#names.df <- c("dashboard","widget","event","query_type","status","cube_name","cube_id","startQueryTimeStamp","endQueryTimeStamp","duration","value","concurrentQuery","status","ts","host")
#duration.data <- read.table(file="durations.csv", sep = "|", quote = "",fill = T, header = T)
#names(duration.data) <- names.df
attach(s3.duration.data)
#duration.data.proj <- duration.data[,c("dashboard","status","@timestamp","duration","concurrentQuery")]
#attach(duration.data.proj) 
s3.duration.data$dashboard <- as.factor(s3.duration.data$dashboard)
s3.duration.data$timestamp <- as.Date(s3.duration.data$timestamp)
s3.duration.data$duration <- as.numeric(as.character(s3.duration.data$duration))
s3.duration.data$key <- paste(host,dashboard,widget,sep="|")

attach(s3.duration.data)
# remove rows with blank widget or cube names
s3.duration.data <- s3.duration.data[!(is.na(s3.duration.data$dashboard) | s3.duration.data$dashboard==""), ]
s3.duration.data <- s3.duration.data[!(is.na(s3.duration.data$widget) | s3.duration.data$widget==""), ]

#duration.data.proj$concurrentQuery <- as.numeric(as.character(duration.data.proj$concurrentQuery))
print("Time to split data (per widget) ...")
system.time(dashboards.groups.list <- split(s3.duration.data, s3.duration.data$key))
print(paste("All in all ...",length(dashboards.groups.list)," widgets will be analyzed", sep=""))
#test.df < - as.data.frame(dashboards.groups.list[c("56e932620ab266301900093c;Transaction Dashboard (V2.2)")])

alert.df <- data.frame(DateRange=as.character(character()),
                 widget=character(), 
                 alertType=character(),
                 alertScore=integer(),
                 user=character())
                  
names(alert.df) <- c("widget","DateRange","alertType","alertScore","user")
setwd("/home/sisense/Documents/anomaly/outputs")
print("Time to filter data...")
system.time(cond <- lapply(dashboards.groups.list, function(x) nrow(x) > 5))
system.time(dashboards.groups.list <- dashboards.groups.list[unlist(cond)])

# call t test analysis and visualizations
print("Time to run statistical analysis")
system.time(alert.list <- lapply(dashboards.groups.list,draw_duration_distribution,new.data.time.windows))
# post process alerts list
#num_elements_list <- sapply(alert.list,length)
alert.list <- alert.list[!is.null(alert.list)]
#alert.list.clean <- alert.list[unlist(sapply(alert.list,function(x) length(x) > 3))]
alert.list.clean <- alert.list[sapply(alert.list, length) == 5]
#alert.list.reg <- alert.list[lapply(alert.list,length)>0]
#alert.list.flattened <- do.call(c, unlist(alert.list, recursive=FALSE))
alert.df.clean <- do.call(rbind.data.frame, alert.list.clean)
names(alert.df.clean) <- c("widgetKey","DateRange","alertType","alertScore","user")
alert.df.clean$alertScore <- as.numeric(as.character(alert.df.clean$alertScore))
alert.df.clean$NormalizedAlertScore <- 1 - 
  (alert.df.clean$alertScore - min(alert.df.clean$alertScore,na.rm = T)) / 
  (max(alert.df.clean$alertScore,na.rm = T) - min(alert.df.clean$alertScore, na.rm = T))
alert.df.clean$alertScore <- NULL
print("writing alerts csv file locally...")
write.csv(x=alert.df.clean, file=paste(Sys.Date(),"_widgets_alerts.csv",sep=""), col.names = T, row.names = F)
print("writing alerts csv file to aws s3")
#system(paste0('aws s3 cp ',alert.df.clean,' s3://my-bucket-name/'))
#system(paste0('rm ',fn))
save.image("/home/sisense/Documents/anomaly/images/duration_data.RData")
  
endTime <- Sys.time()
print (paste("end time = ",endTime, sep="")) 
elapsedTime =difftime(endTime, startTime, units = "hours")
print (paste("total elapsed time in hours = ",elapsedTime, sep=""))  