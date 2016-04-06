draw_duration_distribution <- function(df,new.data.window = NULL) {
  new.record.failed <- NULL 
  new.record <- NULL
  # Parameter new.data.window determines how new data is defined:
  # when = 1, new data is the last day data
  # when = 7, new data is the last week data and so on and so forth
  df <- df[!is.na(df$duration),]
  if (is.null(df)) return (NULL)
  if (nrow(df)<5) return (NULL)
  # sort out file dash and widget names
  dash.id <- grep("dashboard",names(df))  
  dash.name <- substr(df[1,dash.id],start=0,40)
  widg.id <- grep("widget",names(df))
  widg.name <- as.character(df[1,widg.id])
  cube.id <- grep("cubeName",names(df))
  cube.name <- as.character(df[1,cube.id])
  key.id <- grep("key",names(df))  
  key.name <- df[1,key.id]
  user <- c(unique(df$sisenseuid))[[1]]
  if (length(user) == 2)
  {
    print (user)  
  }
  print(paste("dashboard : ", dash.name,sep=""))
  
  # handle division of data to historical and new
  if (!is.null(new.data.window))
  {
    # write logic for a predefined new data time window
    df$timestamp <- as.POSIXlt(df$timestamp) 
    cutoff.date <- unique(max(df$timestamp)) - new.data.window
    baseline.df <- subset(df, timestamp <= cutoff.date)
    newdates.df <- subset(df, timestamp > cutoff.date)
    minDate <- min(as.Date (newdates.df$timestamp))
    maxDate <- max(as.Date (newdates.df$timestamp))
    
  } else{
    df.sorted <- df[with(df, order(df$timestamp)), ]
    num.row <- nrow(df.sorted)
    baseline.id <- ceiling(num.row*0.8)
    baseline.df <- as.data.frame(df.sorted[1:baseline.id,c("duration","timestamp")]); names(baseline.df)[1] <- "duration"
    newdates.df <- as.data.frame(df.sorted[(baseline.id+1):num.row,c("duration","timestamp","status")]);names(newdates.df)[1] <- "duration"
    minDate <- min(as.Date (newdates.df$timestamp))
    maxDate <- max(as.Date (newdates.df$timestamp))
  }
  
  if (any(newdates.df$status == "failed")) {
    new.record.failed <- c(key.name, 
                    paste("from ",minDate," to ",maxDate,sep=""),
                    "Query Failed",
                    "",
                    user)
  }
  
  if (nrow(newdates.df) < 3 |
      length(nearZeroVar(newdates.df$duration)) >0 |
      length(nearZeroVar(baseline.df$duration))> 0 )
    {
     return (NULL)
    }
  # visualize baseline distribution
  # calculate median and variance
  med.base <- median(baseline.df$duration)
  med.new <- median(newdates.df$duration)
  sd.base <- sd(baseline.df$duration)
  sd.new <- sd(newdates.df$duration)
  # t test
  p.value <- t.test(baseline.df$duration,newdates.df$duration,alternative = "greater")$p.value 
  significance.result <- p.value < 0.05 
  
  # plot.title <- paste("Duration Density of new executions (red) vs. historical execution For Dashboard ",dash.name, sep="")
  # plot.subtitle <- paste("Alert status : ",significance.result," | New Widgets From Last ",new.data.window," days",sep="")
  # t.test.plot <- ggplot(data = baseline.df, aes(x = as.numeric(as.character(duration)))) + geom_density(size=1.5, color = "green") + xlab("query duration") + ylab("density") +
  #   geom_density(aes(x=as.numeric(as.character(duration))), colour="red", size=1.5, data=newdates.df) +
  #   geom_vline(xintercept = med.base,colour="green", linetype = "longdash",size=0.8) +
  #   geom_vline(xintercept = med.new,colour="red", linetype = "longdash",size=0.8) +
  #   ggtitle(bquote(atop(.(plot.title), atop(italic(.(plot.subtitle)), ""))))# +
  # 
    #scale_colour_manual(values=c("historical data "="green", "new data "="red"), name="Densities")
  #ggtitle(paste("Duration Density of new executions (red) vs. historical execution For Dashboard ",dash.name, sep=""))
  #scale_colour_manual(name = 'the colour', 
  # values =c('green'='green','red'='red'), labels = c('hisotry queries','new queries'))
  #id <- grep("duration",names(df))
  
  #names(df)[id] <- "duration"
  #df$duration <- as.numeric(as.character(df$duration))
  #names(df)[id] <- "duration"
  #attach(df)
  
  # calculate median and variance
  #med <- median(duration)
  #sd <- sd(duration)
  
  
  #hist <- ggplot(df, aes(x = as.numeric(as.character(duration)))) + geom_histogram (size=1.5) + xlab("query duration") + ylab("density") +
  # ggtitle(paste("Duration Histogram For Dashboard ",widg.name, sep="")) +
  #geom_vline(xintercept = med,colour="green", linetype = "longdash",size=1.5) +
  #geom_vline(xintercept = med+sd,colour="red",size=1.5) +
  #theme(plot.title = element_text(size=14))
  
  #dens <- ggplot(df, aes(x = as.numeric(as.character(duration)))) + geom_density(size=1.5) + xlab("query duration") + ylab("density") +
  #  ggtitle(paste("Duration Density For Dashboard ",widg.name, sep="")) +
  #  geom_vline(xintercept = med,colour="green", linetype = "longdash",size=1.5) +
  #  geom_vline(xintercept = med+sd,colour="red",size=1.5) +
  #
  #theme(plot.title = element_text(size=14)) 
  
  # save to file
  setwd("/home/sisense/Documents/anomaly/outputs")
  #fname <- substr(df$X56e932620ab266301900093c.Transaction.Dashboard..V2.2..dashboard[1],start=0,25)
  file.name <- str_replace_all(dash.name, "[^[:alnum:]]", " ")
  #ggsave(filename = paste("histogram",file.name,".jpg",sep = ""),plot = hist,device = "jpg")
  #ggsave(filename = paste("density",file.name,".jpg",sep = ""),plot = dens,device = "jpg")
  
  # writing results
  
  #ggsave(filename = paste("density",file.name,".jpg",sep = ""),plot = t.test.plot,device = "jpg",height=9,width=12)
  if (significance.result) { 
    new.record <- c(key.name, 
                    paste("from ",minDate," to ",maxDate,sep=""),
                    "Query_Duration_Deterioration",
                    p.value,
                    user)
  }
    #t.test(baseline.df$duration,newdates.df$duration)$p.value)
    #alerts.df <<- rbind(alerts.df, new.record)
    if (!is.null(new.record.failed) & !is.null(new.record))
      {
        return(list(new.record,new.record.failed))
  } else if (!is.null(new.record.failed) & is.null(new.record))
      {
        return(new.record.failed)  
  } else if (is.null(new.record.failed) & !is.null(new.record))
      {
        return(new.record)  
      }
      
}

