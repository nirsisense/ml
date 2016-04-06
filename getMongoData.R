#install.packages("rmongodb")
#install.packages("devtools")
#install_github("rmongodb", "mongosoup")
library(rmongodb)
library(devtools)
#mongo <- mongo.create()
mongo <- mongo.create(host="46.101.122.205:27017",
                      # username="USER", password="XXX",
                      db="monitor")
mongo.is.connected(mongo)
db <- mongo.get.databases(mongo)
mongo.get.database.collections(mongo, db)
mongo.get.err(mongo)
mongo.get.server.err(mongo)
mongo.get.server.err.string(mongo)
mongo.count(mongo, "monitor.monitoring_logs")


#query <- 'db.getCollection(\'monitoring_logs\').find({"widget":{$in:["56dfed49a2988d9019000585;","56d58f5b1dc95f54460002f6;"]}})'
#query <- "widget\":{$in:[\"56dfed49a2988d9019000585;\",\"56d58f5b1dc95f54460002f6;\"]}"
query <- '{"widget":"56dfed49a2988d9019000585;"}'
#query <- '{"widget":{$in:["56dfed49a2988d9019000585;","56d58f5b1dc95f54460002f6;"]}}'
test <- mongo.find.all(mongo, "monitor.monitoring_logs",query=query)

























mongo.destroy(mongo)