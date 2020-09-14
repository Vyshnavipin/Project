library(xlsx)
library(tidyr)
library(ggplot2)
library(reshape2)
library(dplyr)
library(viridis)
library(dichromat)
library(RColorBrewer)

setwd("E:/sensitivity/sens")

fileDDMA_2 <- "thresh_2.xlsx"
fileDDMA_4 <- "thresh_4.xlsx"
fileDDMA_6 <- "thresh_6.xlsx"
fileDDMA_8 <- "thresh_8.xlsx"


data_exp_DDMA2 <- readxl::read_excel(fileDDMA_2, sheet = "values_2")
data_set_DDMA2 <- readxl::read_excel(fileDDMA_2, sheet = "run_2")
data_exp_DDMA4 <- readxl::read_excel(fileDDMA_4, sheet = "values_4")
data_set_DDMA4 <- readxl::read_excel(fileDDMA_4, sheet = "run_4")
data_exp_DDMA6 <- readxl::read_excel(fileDDMA_6, sheet = "values_6")
data_set_DDMA6 <- readxl::read_excel(fileDDMA_6, sheet = "run_6")
data_exp_DDMA8 <- readxl::read_excel(fileDDMA_8, sheet = "values_8")
data_set_DDMA8 <- readxl::read_excel(fileDDMA_8, sheet = "run_8")

listDATA <- list(data_exp_DDMA2, data_set_DDMA2, 
                 data_exp_DDMA4, data_set_DDMA4, 
                 data_exp_DDMA6, data_set_DDMA6, 
                 data_exp_DDMA8, data_set_DDMA8)
save(listDATA, file = "listDATA.Rdata")

load("listDATA.Rdata")

data_exp_DDMA2 <- listDATA[[1]]
data_set_DDMA2 <- listDATA[[2]]
data_exp_DDMA4 <- listDATA[[3]]
data_set_DDMA4 <- listDATA[[4]]
data_exp_DDMA6 <- listDATA[[5]]
data_set_DDMA6 <- listDATA[[6]]
data_exp_DDMA8 <- listDATA[[7]]
data_set_DDMA8 <- listDATA[[8]]

####  organize for DDMA2
toLong <- colnames(data_exp_DDMA2) #column names of Runs
data_exp_DDMA2$yearnow <- as.numeric(data_exp_DDMA2$yearnow_1)
data_exp_DDMA2$weeknow <-as.numeric(data_exp_DDMA2$weeknow_1)
remWeekDay <- c(paste("yearnow_", 1:288, sep = ""), paste("weeknow_", 1:288, sep = "")) # remove all the other yearnows and weeknows
ttt <- colnames(data_exp_DDMA2)[!colnames(data_exp_DDMA2) %in% remWeekDay]
data_exp_DDMA2 <- data_exp_DDMA2[, ttt]
data_long_exp_DDMA2 <- melt(data_exp_DDMA2, id.vars=c("yearnow", "weeknow"))
data_long_exp_DDMA2 <- data_long_exp_DDMA2[-1, ]

data_long_exp_DDMA2$variableID <- gsub("_[0-9]*$", "", data_long_exp_DDMA2$variable)
data_long_exp_DDMA2$run_number <- gsub("_|[a-z]*| ", "", data_long_exp_DDMA2$variable)
data_long_exp_DDMA2 <- merge(data_long_exp_DDMA2, data_set_DDMA2, by = "run_number", all.x = T)

data_long_expSocDim2 <- data_long_exp_DDMA2 %>% filter(variableID == "social_dim") # social dimension
data_long_expSocDim2$value <- as.numeric(data_long_expSocDim2$value)

data_long_expTechDim2 <- data_long_exp_DDMA2 %>% filter(variableID == "technical_dim") # technical dimension
data_long_expTechDim2$value1 <- as.numeric(data_long_expTechDim2$value1)

data_long_expEcoDim2 <- data_long_exp_DDMA2 %>% filter(variableID == "economic_dimension") # economic dimension
data_long_expEcoDim2$value2 <- as.numeric(data_long_expEcoDim2$value2)

data_long_expEnvDim2 <- data_long_exp_DDMA2 %>% filter(variableID == "environmental_dimension") # environmental dimension
data_long_expEnvDim2$value3 <- as.numeric(data_long_expEnvDim2$value3)

#### Threshold skillset
data_long_expSocDim2A <- data_long_expSocDim2 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Social_dimension = mean(value, na.rm = T))

data_long_expTechDim2A <- data_long_expTechDim2 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim2A <- data_long_expEcoDim2 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim2A <- data_long_expEnvDim2 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

### Governemnt_cont
data_long_expSocDim2A_GC <- data_long_expSocDim2 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Social_dimension = mean(value, na.rm = T))

data_long_expTechDim2A_GC <- data_long_expTechDim2 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim2A_GC <- data_long_expEcoDim2 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim2A_GC <- data_long_expEnvDim2 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

###Government_join
data_long_expSocDim2A_GJ <- data_long_expSocDim2 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(avKPI = mean(value, na.rm = T))

data_long_expTechDim2A_GJ <- data_long_expTechDim2 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim2A_GJ <- data_long_expEcoDim2 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim2A_GJ <- data_long_expEnvDim2 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

### Citizen_Cont
data_long_expSocDim2A_CC <- data_long_expSocDim2 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(avKPI = mean(value, na.rm = T))

data_long_expTechDim2A_CC <- data_long_expTechDim2 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim2A_CC <- data_long_expEcoDim2 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim2A_CC <- data_long_expEnvDim2 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

### Citizen_ join
data_long_expSocDim2A_CJ <- data_long_expSocDim2 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(avKPI = mean(value, na.rm = T))

data_long_expTechDim2A_CJ <- data_long_expTechDim2 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim2A_CJ <- data_long_expEcoDim2 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim2A_CJ <- data_long_expEnvDim2 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(Environmental_dimension = mean(value, na.rm = T))


save(data_long_expSocDim2A, file = "data_long_expSocDim2A.Rdata")
####  organize for DDMA4
toLong <- colnames(data_exp_DDMA4) #column names of Runs
data_exp_DDMA4$yearnow <- as.numeric(data_exp_DDMA4$yearnow_1)
data_exp_DDMA4$weeknow <-as.numeric(data_exp_DDMA4$weeknow_1)
remWeekDay <- c(paste("yearnow_", 1:288, sep = ""), paste("weeknow_", 1:288, sep = "")) # remove all the other yearnows and weeknows
ttt <- colnames(data_exp_DDMA4)[!colnames(data_exp_DDMA4) %in% remWeekDay]
data_exp_DDMA4 <- data_exp_DDMA4[, ttt]
data_long_exp_DDMA4 <- melt(data_exp_DDMA4, id.vars=c("yearnow", "weeknow"))
data_long_exp_DDMA4 <- data_long_exp_DDMA4[-1, ]

data_long_exp_DDMA4$variableID <- gsub("_[0-9]*$", "", data_long_exp_DDMA4$variable)
data_long_exp_DDMA4$run_number <- gsub("_|[a-z]*| ", "", data_long_exp_DDMA4$variable)
data_long_exp_DDMA4 <- merge(data_long_exp_DDMA4, data_set_DDMA4, by = "run_number", all.x = T)


data_long_expSocDim4 <- data_long_exp_DDMA4 %>% filter(variableID == "social_dim") # social dimension
data_long_expSocDim4$value <- as.numeric(data_long_expSocDim4$value)

data_long_expTechDim4 <- data_long_exp_DDMA4 %>% filter(variableID == "technical_dim") # technical dimension
data_long_expTechDim4$value1 <- as.numeric(data_long_expTechDim4$value1)

data_long_expEcoDim4 <- data_long_exp_DDMA4 %>% filter(variableID == "economic_dimension") # economic dimension
data_long_expEcoDim2$value4 <- as.numeric(data_long_expEcoDim4$value2)

data_long_expEnvDim4 <- data_long_exp_DDMA4 %>% filter(variableID == "environmental_dimension") # environmental dimension
data_long_expEnvDim4$value3 <- as.numeric(data_long_expEnvDim4$value3)

#### Threshold skillset
data_long_expSocDim4A <- data_long_expSocDim4 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Social_dimension = mean(value, na.rm = T))

data_long_expTechDim4A <- data_long_expTechDim4 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim4A <- data_long_expEcoDim4 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim4A <- data_long_expEnvDim4 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

### Governemnt_cont
data_long_expSocDim4A_GC <- data_long_expSocDim4 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Social_dimension = mean(value, na.rm = T))

data_long_expTechDim4A_GC <- data_long_expTechDim4 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim4A_GC <- data_long_expEcoDim4 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim4A_GC <- data_long_expEnvDim4 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

###Government_join
data_long_expSocDim4A_GJ <- data_long_expSocDim4 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(avKPI = mean(value, na.rm = T))

data_long_expTechDim4A_GJ <- data_long_expTechDim4 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim4A_GJ <- data_long_expEcoDim4 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim4A_GJ <- data_long_expEnvDim4 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

### Citizen_Cont
data_long_expSocDim4A_CC <- data_long_expSocDim4 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(avKPI = mean(value, na.rm = T))

data_long_expTechDim4A_CC <- data_long_expTechDim4 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim4A_CC <- data_long_expEcoDim4 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim4A_CC <- data_long_expEnvDim4 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

### Citizen_ join
data_long_expSocDim4A_CJ <- data_long_expSocDim4 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(avKPI = mean(value, na.rm = T))

data_long_expTechDim4A_CJ <- data_long_expTechDim4 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim4A_CJ <- data_long_expEcoDim4 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim4A_CJ <- data_long_expEnvDim4 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

save(data_long_expSocDim4A, file = "data_long_expSocDim4A.Rdata")

####  organize for DDMA6
toLong <- colnames(data_exp_DDMA6) #column names of Runs
data_exp_DDMA6$yearnow <- as.numeric(data_exp_DDMA6$yearnow_1)
data_exp_DDMA6$weeknow <-as.numeric(data_exp_DDMA6$weeknow_1)
remWeekDay <- c(paste("yearnow_", 1:288, sep = ""), paste("weeknow_", 1:288, sep = "")) # remove all the other yearnows and weeknows
ttt <- colnames(data_exp_DDMA6)[!colnames(data_exp_DDMA6) %in% remWeekDay]
data_exp_DDMA6 <- data_exp_DDMA6[, ttt]
data_long_exp_DDMA6 <- melt(data_exp_DDMA6, id.vars=c("yearnow", "weeknow"))
data_long_exp_DDMA6 <- data_long_exp_DDMA6[-1, ]

data_long_exp_DDMA6$variableID <- gsub("_[0-9]*$", "", data_long_exp_DDMA6$variable)
data_long_exp_DDMA6$run_number <- gsub("_|[a-z]*| ", "", data_long_exp_DDMA6$variable)
data_long_exp_DDMA6 <- merge(data_long_exp_DDMA6, data_set_DDMA6, by = "run_number", all.x = T)

data_long_expSocDim6 <- data_long_exp_DDMA6 %>% filter(variableID == "social_dim") # social dimension
data_long_expSocDim6$value <- as.numeric(data_long_expSocDim6$value)

data_long_expTechDim6 <- data_long_exp_DDMA6 %>% filter(variableID == "technical_dim") # technical dimension
data_long_expTechDim6$value1 <- as.numeric(data_long_expTechDim6$value1)

data_long_expEcoDim6 <- data_long_exp_DDMA6 %>% filter(variableID == "economic_dimension") # economic dimension
data_long_expEcoDim2$value2 <- as.numeric(data_long_expEcoDim6$value2)

data_long_expEnvDim6 <- data_long_exp_DDMA6 %>% filter(variableID == "environmental_dimension") # environmental dimension
data_long_expEnvDim6$value3 <- as.numeric(data_long_expEnvDim6$value3)

#### Threshold skillset
data_long_expSocDim6A <- data_long_expSocDim6 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Social_dimension = mean(value, na.rm = T))

data_long_expTechDim6A <- data_long_expTechDim6 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim6A <- data_long_expEcoDim6 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim6A <- data_long_expEnvDim6 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

### Governemnt_cont
data_long_expSocDim6A_GC <- data_long_expSocDim6 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Social_dimension = mean(value, na.rm = T))

data_long_expTechDim6A_GC <- data_long_expTechDim6 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim6A_GC <- data_long_expEcoDim6 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim6A_GC <- data_long_expEnvDim6 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

###Government_join
data_long_expSocDim6A_GJ <- data_long_expSocDim6 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(avKPI = mean(value, na.rm = T))

data_long_expTechDim6A_GJ <- data_long_expTechDim6 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim6A_GJ <- data_long_expEcoDim6 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim6A_GJ <- data_long_expEnvDim6 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

### Citizen_Cont
data_long_expSocDim6A_CC <- data_long_expSocDim6 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(avKPI = mean(value, na.rm = T))

data_long_expTechDim6A_CC <- data_long_expTechDim6 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim6A_CC <- data_long_expEcoDim6 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim6A_CC <- data_long_expEnvDim6 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

### Citizen_ join
data_long_expSocDim6A_CJ <- data_long_expSocDim6 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(avKPI = mean(value, na.rm = T))

data_long_expTechDim6A_CJ <- data_long_expTechDim6 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim6A_CJ <- data_long_expEcoDim6 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim6A_CJ <- data_long_expEnvDim6 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(Environmental_dimension = mean(value, na.rm = T))


save(data_long_expSocDim6A, file = "data_long_expSocDim6A.Rdata")
####  organize for DDMA8
toLong <- colnames(data_exp_DDMA8) #column names of Runs
data_exp_DDMA8$yearnow <- as.numeric(data_exp_DDMA8$yearnow_1)
data_exp_DDMA8$weeknow <- as.numeric(data_exp_DDMA8$weeknow_1)
remWeekDay <- c(paste("yearnow_", 1:288, sep = ""), paste("weeknow_", 1:288, sep = "")) # remove all the other yearnows and weeknows
ttt <- colnames(data_exp_DDMA8)[!colnames(data_exp_DDMA8) %in% remWeekDay]
data_exp_DDMA8 <- data_exp_DDMA8[, ttt]
data_long_exp_DDMA8 <- melt(data_exp_DDMA8, id.vars=c("yearnow", "weeknow"))
data_long_exp_DDMA8 <- data_long_exp_DDMA8[-1, ]

data_long_exp_DDMA8$variableID <- gsub("_[0-9]*$", "", data_long_exp_DDMA8$variable)
data_long_exp_DDMA8$run_number <- gsub("_|[a-z]*| ", "", data_long_exp_DDMA8$variable)
data_long_exp_DDMA8 <- merge(data_long_exp_DDMA8, data_set_DDMA8, by = "run_number", all.x = T)

data_long_expSocDim8 <- data_long_exp_DDMA8 %>% filter(variableID == "social_dim") # social dimension
data_long_expSocDim8$value <- as.numeric(data_long_expSocDim8$value)

data_long_expTechDim8 <- data_long_exp_DDMA8 %>% filter(variableID == "technical_dim") # technical dimension
data_long_expTechDim8$value1 <- as.numeric(data_long_expTechDim8$value1)

data_long_expEcoDim8 <- data_long_exp_DDMA8 %>% filter(variableID == "economic_dimension") # economic dimension
data_long_expEcoDim8$value2 <- as.numeric(data_long_expEcoDim8$value2)

data_long_expEnvDim8 <- data_long_exp_DDMA8 %>% filter(variableID == "environmental_dimension") # environmental dimension
data_long_expEnvDim8$value3 <- as.numeric(data_long_expEnvDim8$value3)

#### Threshold skillset
data_long_expSocDim8A <- data_long_expSocDim8 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Social_dimension = mean(value, na.rm = T))

data_long_expTechDim8A <- data_long_expTechDim8 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim8A <- data_long_expEcoDim8 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim8A <- data_long_expEnvDim8 %>% 
  group_by(run_number, yearnow, weeknow, thresh_skillset) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

### Governemnt_cont
data_long_expSocDim8A_GC <- data_long_expSocDim8 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Social_dimension = mean(value, na.rm = T))

data_long_expTechDim8A_GC <- data_long_expTechDim8 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim8A_GC <- data_long_expEcoDim8 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim8A_GC <- data_long_expEnvDim8 %>% 
  group_by(run_number, yearnow, weeknow, gov_cont) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

###Government_join
data_long_expSocDim8A_GJ <- data_long_expSocDim8 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(avKPI = mean(value, na.rm = T))

data_long_expTechDim8A_GJ <- data_long_expTechDim8 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim8A_GJ <- data_long_expEcoDim8 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim8A_GJ <- data_long_expEnvDim8 %>% 
  group_by(run_number, yearnow, weeknow, gov_join) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

### Citizen_Cont
data_long_expSocDim8A_CC <- data_long_expSocDim8 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(avKPI = mean(value, na.rm = T))

data_long_expTechDim8A_CC <- data_long_expTechDim8 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim8A_CC <- data_long_expEcoDim8 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim8A_CC <- data_long_expEnvDim8 %>% 
  group_by(run_number, yearnow, weeknow, citizen_cont) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

### Citizen_ join
data_long_expSocDim8A_CJ <- data_long_expSocDim8 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(avKPI = mean(value, na.rm = T))

data_long_expTechDim8A_CJ <- data_long_expTechDim8 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim8A_CJ <- data_long_expEcoDim8 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim8A_CJ <- data_long_expEnvDim8 %>% 
  group_by(run_number, yearnow, weeknow, citizen_join) %>% summarise(Environmental_dimension = mean(value, na.rm = T))


save(data_long_expSocDim8A, file = "data_long_expSocDim8A.Rdata")

data_long_expSocDimA <- rbind(data_long_expSocDim2A, # social
                              data_long_expSocDim4A,
                              data_long_expSocDim6A,
                              data_long_expSocDim8A)

data_long_expTechDimA <- rbind(data_long_expTechDim2A, # technical
                              data_long_expTechDim4A,
                              data_long_expTechDim6A,
                              data_long_expTechDim8A)

data_long_expEcoDimA <- rbind(data_long_expEcoDim2A, # economic
                              data_long_expEcoDim4A,
                              data_long_expEcoDim6A,
                              data_long_expEcoDim8A)

data_long_expEnvDimA <- rbind(data_long_expEnvDim2A, # environmental
                              data_long_expEnvDim4A,
                              data_long_expEnvDim6A,
                              data_long_expEnvDim8A)

# Gov_cont
data_long_expSocDimA_GC <- rbind(data_long_expSocDim2A_GC,
                                 data_long_expSocDim4A_GC,
                                 data_long_expSocDim6A_GC,
                                 data_long_expSocDim8A_GC)

data_long_expTechDimA_GC <- rbind(data_long_expTechDim2A_GC,
                                 data_long_expTechDim4A_GC,
                                 data_long_expTechDim6A_GC,
                                 data_long_expTechDim8A_GC)

data_long_expEcoDimA_GC <- rbind(data_long_expEcoDim2A_GC,
                                 data_long_expEcoDim4A_GC,
                                 data_long_expEcoDim6A_GC,
                                 data_long_expEcoDim8A_GC)

data_long_expEnvDimA_GC <- rbind(data_long_expEnvDim2A_GC,
                                 data_long_expEnvDim4A_GC,
                                 data_long_expEnvDim6A_GC,
                                 data_long_expEnvDim8A_GC)

# Government_Join
data_long_expSocDimA_GJ <- rbind(data_long_expSocDim2A_GJ,
                                 data_long_expSocDim4A_GJ,
                                 data_long_expSocDim6A_GJ,
                                 data_long_expSocDim8A_GJ)

data_long_expTechDimA_GJ <- rbind(data_long_expTechDim2A_GJ,
                                  data_long_expTechDim4A_GJ,
                                  data_long_expTechDim6A_GJ,
                                  data_long_expTechDim8A_GJ)

data_long_expEcoDimA_GJ <- rbind(data_long_expEcoDim2A_GJ,
                                 data_long_expEcoDim4A_GJ,
                                 data_long_expEcoDim6A_GJ,
                                 data_long_expEcoDim8A_GJ)

data_long_expEnvDimA_GJ <- rbind(data_long_expEnvDim2A_GJ,
                                 data_long_expEnvDim4A_GJ,
                                 data_long_expEnvDim6A_GJ,
                                 data_long_expEnvDim8A_GJ)

# Citizen_cont
data_long_expSocDimA_CC <- rbind(data_long_expSocDim2A_CC,
                                 data_long_expSocDim4A_CC,
                                 data_long_expSocDim6A_CC,
                                 data_long_expSocDim8A_CC)

data_long_expTechDimA_CC <- rbind(data_long_expTechDim2A_CC,
                                  data_long_expTechDim4A_CC,
                                  data_long_expTechDim6A_CC,
                                  data_long_expTechDim8A_CC)

data_long_expEcoDimA_CC <- rbind(data_long_expEcoDim2A_CC,
                                 data_long_expEcoDim4A_CC,
                                 data_long_expEcoDim6A_CC,
                                 data_long_expEcoDim8A_CC)

data_long_expEnvDimA_CC <- rbind(data_long_expEnvDim2A_CC,
                                 data_long_expEnvDim4A_CC,
                                 data_long_expEnvDim6A_CC,
                                 data_long_expEnvDim8A_CC)


# Citizen_Join
data_long_expSocDimA_CJ <- rbind(data_long_expSocDim2A_CJ,
                                 data_long_expSocDim4A_CJ,
                                 data_long_expSocDim6A_CJ,
                                 data_long_expSocDim8A_CJ)

data_long_expTechDimA_CJ <- rbind(data_long_expTechDim2A_CJ,
                                  data_long_expTechDim4A_CJ,
                                  data_long_expTechDim6A_CJ,
                                  data_long_expTechDim8A_CJ)

data_long_expEcoDimA_CJ <- rbind(data_long_expEcoDim2A_CJ,
                                 data_long_expEcoDim4A_CJ,
                                 data_long_expEcoDim6A_CJ,
                                 data_long_expEcoDim8A_CJ)

data_long_expEnvDimA_CJ <- rbind(data_long_expEnvDim2A_CJ,
                                 data_long_expEnvDim4A_CJ,
                                 data_long_expEnvDim6A_CJ,
                                 data_long_expEnvDim8A_CJ)

save(data_long_expSocDimA, file = "data_long_expSocDimA.Rdata")
load("data_long_expSocDimA (1).Rdata")
# data_long_expSocDimA <- rbind(data_long_expSocDimA, data_long_expSocDim8A)
# save(data_long_expSocDimA, file = "data_long_expSocDimA.Rdata")

# # boxplot 
##### threshold and KPIs
data_long_expSocDimA$thresh_skillset <- as.factor(data_long_expSocDimA$thresh_skillset)
data_long_expTechDimA$thresh_skillset <- as.factor(data_long_expTechDimA$thresh_skillset)
data_long_expEcoDimA$thresh_skillset <- as.factor(data_long_expEcoDimA$thresh_skillset)
data_long_expEnvDimA$thresh_skillset <- as.factor(data_long_expEnvDimA$thresh_skillset)

## Government_cont
data_long_expSocDimA_GC$gov_cont <- as.factor(data_long_expSocDimA_GC$gov_cont)
data_long_expTechDimA_GC$gov_cont <- as.factor(data_long_expTechDimA_GC$gov_cont)
data_long_expEcoDimA_GC$gov_cont <- as.factor(data_long_expEcoDimA_GC$gov_cont)
data_long_expEnvDimA_GC$gov_cont <- as.factor(data_long_expEnvDimA_GC$gov_cont)

## Citizen_cont
data_long_expSocDimA_CC$citizen_cont <- as.factor(data_long_expSocDimA_CC$citizen_cont)
data_long_expTechDimA_CC$citizen_cont <- as.factor(data_long_expTechDimA_CC$citizen_cont)
data_long_expEcoDimA_CC$citizen_cont <- as.factor(data_long_expEcoDimA_CC$citizen_cont)
data_long_expEnvDimA_CC$citizen_cont <- as.factor(data_long_expEnvDimA_CC$citizen_cont)

## Government_join
data_long_expSocDimA_GJ$gov_join <- as.factor(data_long_expSocDimA_GJ$gov_join)
data_long_expTechDimA_GJ$gov_join <- as.factor(data_long_expTechDimA_GJ$gov_join)
data_long_expEcoDimA_GJ$gov_join <- as.factor(data_long_expEcoDimA_GJ$gov_join)
data_long_expEnvDimA_GJ$gov_join <- as.factor(data_long_expEnvDimA_GJ$gov_join)

## Citizen_join
data_long_expSocDimA_CJ$citizen_join <- as.factor(data_long_expSocDimA_CJ$citizen_join)
data_long_expTechDimA_CJ$citizen_join <- as.factor(data_long_expTechDimA_cJ$citizen_join)
data_long_expEcoDimA_CJ$citizen_join <- as.factor(data_long_expEcoDimA_CJ$citizen_join)
data_long_expEnvDimA_CJ$citizen_join <- as.factor(data_long_expEnvDimA_CJ$citizen_join)

# Thresh vs social
data_long_expSocDimA %>% group_by(thresh_skillset) %>% summarise(aver = mean(Social_dimension), 
                                                                 median = median(Social_dimension), 
                                                                 stdev  =  sd(Social_dimension),
                                                                 q25 = quantile(Social_dimension, 0.25), 
                                                                 q50 = quantile(Social_dimension, 0.50),
                                                                 q75 = quantile(Social_dimension, 0.75),
                                                                 VC = stdev/aver) # variance coeficient: 
p3 <- ggplot(data_long_expSocDimA, aes(x=thresh_skillset, y = Social_dimension)) + 
  geom_boxplot() +
  ggtitle("Threshold vs social dimension ")
ggsave("Thresh vs social.png", plot = p3, width = 25, height = 20)

# Thresh vs technical
data_long_expTechDimA %>% group_by(thresh_skillset) %>% summarise(aver = mean(Technical_dimension), 
                                                                 median = median(Technical_dimension), 
                                                                 stdev  =  sd(Technical_dimension),
                                                                 q25 = quantile(Technical_dimension, 0.25), 
                                                                 q50 = quantile(Technical_dimension, 0.50),
                                                                 q75 = quantile(Technical_dimension, 0.75),
                                                                 VC = stdev/aver) # variance coeficient: 
p4 <- ggplot(data_long_expTechDimA, aes(x=thresh_skillset, y = Technical_dimension)) + 
  geom_boxplot() +
  ggtitle("Threshold vs technical dimension ")
ggsave("Thresh vs Technical.png", plot = p4, width = 25, height = 20)

# Thresh vs eco
data_long_expEcoDimA %>% group_by(thresh_skillset) %>% summarise(aver = mean(Economic_dimension), 
                                                                 median = median(Economic_dimension), 
                                                                 stdev  =  sd(Economic_dimension),
                                                                 q25 = quantile(Economic_dimension, 0.25), 
                                                                 q50 = quantile(Economic_dimension, 0.50),
                                                                 q75 = quantile(Economic_dimension, 0.75),
                                                                 VC = stdev/aver) # variance coeficient: 
p5 <- ggplot(data_long_expEcoDimA, aes(x=thresh_skillset, y = Economic_dimension)) + 
  geom_boxplot() +
  ggtitle("Threshold vs economic dimension ")
ggsave("Thresh vs economic.png", plot = p5, width = 25, height = 20)

# Thresh vs env
data_long_expEnvDimA %>% group_by(thresh_skillset) %>% summarise(aver = mean(Environmental_dimension), 
                                                                 median = median(Environmental_dimension), 
                                                                 stdev  =  sd(Environmental_dimension),
                                                                 q25 = quantile(Environmental_dimension, 0.25), 
                                                                 q50 = quantile(Environmental_dimension, 0.50),
                                                                 q75 = quantile(Environmental_dimension, 0.75),
                                                                 VC = stdev/aver) # variance coeficient: 
p6 <- ggplot(data_long_expEnvDimA, aes(x=thresh_skillset, y = Environmental_dimension)) + 
  geom_boxplot() +
  ggtitle("Threshold vs Environmental dimension ")
ggsave("Thresh vs Environmental.png", plot = p6, width = 25, height = 20)

# Government join
# GJ vs social
data_long_expSocDimA_GJ %>% group_by(gov_join) %>% summarise(aver = mean(Social_dimension), 
                                                                 median = median(Social_dimension), 
                                                                 stdev  =  sd(Social_dimension),
                                                                 q25 = quantile(Social_dimension, 0.25), 
                                                                 q50 = quantile(Social_dimension, 0.50),
                                                                 q75 = quantile(Social_dimension, 0.75),
                                                                 VC = stdev/aver) # variance coeficient: 
p7 <- ggplot(data_long_expSocDimA_GJ, aes(x=gov_join, y = Social_dimension)) + 
  geom_boxplot() +
  ggtitle("government join vs social dimension ")
ggsave("GJ vs social.png", plot = p7, width = 25, height = 20)

# GJ vs technical
data_long_expTechDimA_GJ %>% group_by(gov_join) %>% summarise(aver = mean(Technical_dimension), 
                                                                  median = median(Technical_dimension), 
                                                                  stdev  =  sd(Technical_dimension),
                                                                  q25 = quantile(Technical_dimension, 0.25), 
                                                                  q50 = quantile(Technical_dimension, 0.50),
                                                                  q75 = quantile(Technical_dimension, 0.75),
                                                                  VC = stdev/aver) # variance coeficient: 
p8 <- ggplot(data_long_expTechDimA_GJ, aes(x=gov_join, y = Technical_dimension)) + 
  geom_boxplot() +
  ggtitle("GJ vs technical dimension ")
ggsave("GJ vs Technical.png", plot = p8, width = 25, height = 20)

# GJ vs eco
data_long_expEcoDimA_GJ %>% group_by(gov_join) %>% summarise(aver = mean(Economic_dimension), 
                                                                 median = median(Economic_dimension), 
                                                                 stdev  =  sd(Economic_dimension),
                                                                 q25 = quantile(Economic_dimension, 0.25), 
                                                                 q50 = quantile(Economic_dimension, 0.50),
                                                                 q75 = quantile(Economic_dimension, 0.75),
                                                                 VC = stdev/aver) # variance coeficient: 
p9 <- ggplot(data_long_expEcoDimA_GJ, aes(x=gov_join, y = Economic_dimension)) + 
  geom_boxplot() +
  ggtitle("GJ vs economic dimension ")
ggsave("GJ vs economic.png", plot = p9, width = 25, height = 20)

# GJ vs env
data_long_expEnvDimA_GJ %>% group_by(gov_join) %>% summarise(aver = mean(Environmental_dimension), 
                                                                 median = median(Environmental_dimension), 
                                                                 stdev  =  sd(Environmental_dimension),
                                                                 q25 = quantile(Environmental_dimension, 0.25), 
                                                                 q50 = quantile(Environmental_dimension, 0.50),
                                                                 q75 = quantile(Environmental_dimension, 0.75),
                                                                 VC = stdev/aver) # variance coeficient: 
p10 <- ggplot(data_long_expEnvDimA_GJ, aes(x=gov_join, y = Environmental_dimension)) + 
  geom_boxplot() +
  ggtitle("GJ vs Environmental dimension ")
ggsave("GJ vs Environmental.png", plot = p10, width = 25, height = 20)

## Citizen join vs KPIs
# CJ vs social
data_long_expSocDimA_CJ %>% group_by(citizen_join) %>% summarise(aver = mean(Social_dimension), 
                                                             median = median(Social_dimension), 
                                                             stdev  =  sd(Social_dimension),
                                                             q25 = quantile(Social_dimension, 0.25), 
                                                             q50 = quantile(Social_dimension, 0.50),
                                                             q75 = quantile(Social_dimension, 0.75),
                                                             VC = stdev/aver) # variance coeficient: 
p11 <- ggplot(data_long_expSocDimA_CJ, aes(x=citizen_join, y = Social_dimension)) + 
  geom_boxplot() +
  ggtitle("citizen join vs social dimension ")
ggsave("CJ vs social.png", plot = p11, width = 25, height = 20)

# GJ vs technical
data_long_expTechDimA_CJ %>% group_by(citizen_join) %>% summarise(aver = mean(Technical_dimension), 
                                                              median = median(Technical_dimension), 
                                                              stdev  =  sd(Technical_dimension),
                                                              q25 = quantile(Technical_dimension, 0.25), 
                                                              q50 = quantile(Technical_dimension, 0.50),
                                                              q75 = quantile(Technical_dimension, 0.75),
                                                              VC = stdev/aver) # variance coeficient: 
p12 <- ggplot(data_long_expTechDimA_CJ, aes(x=citizen_join, y = Technical_dimension)) + 
  geom_boxplot() +
  ggtitle("CJ vs technical dimension ")
ggsave("CJ vs Technical.png", plot = p12, width = 25, height = 20)

# CJ vs eco
data_long_expEcoDimA_CJ %>% group_by(citizen_join) %>% summarise(aver = mean(Economic_dimension), 
                                                             median = median(Economic_dimension), 
                                                             stdev  =  sd(Economic_dimension),
                                                             q25 = quantile(Economic_dimension, 0.25), 
                                                             q50 = quantile(Economic_dimension, 0.50),
                                                             q75 = quantile(Economic_dimension, 0.75),
                                                             VC = stdev/aver) # variance coeficient: 
p13 <- ggplot(data_long_expEcoDimA_CJ, aes(x=citizen_join, y = Economic_dimension)) + 
  geom_boxplot() +
  ggtitle("GJ vs economic dimension ")
ggsave("GJ vs economic.png", plot = p13, width = 25, height = 20)

# CJ vs env
data_long_expEnvDimA_CJ %>% group_by(citizen_join) %>% summarise(aver = mean(Environmental_dimension), 
                                                             median = median(Environmental_dimension), 
                                                             stdev  =  sd(Environmental_dimension),
                                                             q25 = quantile(Environmental_dimension, 0.25), 
                                                             q50 = quantile(Environmental_dimension, 0.50),
                                                             q75 = quantile(Environmental_dimension, 0.75),
                                                             VC = stdev/aver) # variance coeficient: 
p13 <- ggplot(data_long_expEnvDimA_CJ, aes(x=citizen_join, y = Environmental_dimension)) + 
  geom_boxplot() +
  ggtitle("CJ vs Environmental dimension ")
ggsave("CJ vs Environmental.png", plot = p13, width = 25, height = 20)

# Government cont
# GC vs social
data_long_expSocDimA_GC %>% group_by(gov_cont) %>% summarise(aver = mean(Social_dimension), 
                                                             median = median(Social_dimension), 
                                                             stdev  =  sd(Social_dimension),
                                                             q25 = quantile(Social_dimension, 0.25), 
                                                             q50 = quantile(Social_dimension, 0.50),
                                                             q75 = quantile(Social_dimension, 0.75),
                                                             VC = stdev/aver) # variance coeficient: 
p14 <- ggplot(data_long_expSocDimA_GC, aes(x=gov_cont, y = Social_dimension)) + 
  geom_boxplot() +
  ggtitle("government cont vs social dimension ")
ggsave("GC vs social.png", plot = p14, width = 25, height = 20)

# GC vs technical
data_long_expTechDimA_GC %>% group_by(gov_cont) %>% summarise(aver = mean(Technical_dimension), 
                                                              median = median(Technical_dimension), 
                                                              stdev  =  sd(Technical_dimension),
                                                              q25 = quantile(Technical_dimension, 0.25), 
                                                              q50 = quantile(Technical_dimension, 0.50),
                                                              q75 = quantile(Technical_dimension, 0.75),
                                                              VC = stdev/aver) # variance coeficient: 
p15 <- ggplot(data_long_expTechDimA_GC, aes(x=gov_cont, y = Technical_dimension)) + 
  geom_boxplot() +
  ggtitle("GC vs technical dimension ")
ggsave("GC vs Technical.png", plot = p15, width = 25, height = 20)

# GC vs eco
data_long_expEcoDimA_GC %>% group_by(gov_cont) %>% summarise(aver = mean(Economic_dimension), 
                                                             median = median(Economic_dimension), 
                                                             stdev  =  sd(Economic_dimension),
                                                             q25 = quantile(Economic_dimension, 0.25), 
                                                             q50 = quantile(Economic_dimension, 0.50),
                                                             q75 = quantile(Economic_dimension, 0.75),
                                                             VC = stdev/aver) # variance coeficient: 
p16 <- ggplot(data_long_expEcoDimA_GC, aes(x=gov_cont, y = Economic_dimension)) + 
  geom_boxplot() +
  ggtitle("GC vs economic dimension ")
ggsave("GC vs economic.png", plot = p16, width = 25, height = 20)

# GC vs env
data_long_expEnvDimA_GC %>% group_by(gov_cont) %>% summarise(aver = mean(Environmental_dimension), 
                                                             median = median(Environmental_dimension), 
                                                             stdev  =  sd(Environmental_dimension),
                                                             q25 = quantile(Environmental_dimension, 0.25), 
                                                             q50 = quantile(Environmental_dimension, 0.50),
                                                             q75 = quantile(Environmental_dimension, 0.75),
                                                             VC = stdev/aver) # variance coeficient: 
p17 <- ggplot(data_long_expEnvDimA_GC, aes(x=gov_cont, y = Environmental_dimension)) + 
  geom_boxplot() +
  ggtitle("GC vs Environmental dimension ")
ggsave("GC vs Environmental.png", plot = p17, width = 25, height = 20)

# Citizen cont
# GC vs social
data_long_expSocDimA_CC %>% group_by(citizen_cont) %>% summarise(aver = mean(Social_dimension), 
                                                             median = median(Social_dimension), 
                                                             stdev  =  sd(Social_dimension),
                                                             q25 = quantile(Social_dimension, 0.25), 
                                                             q50 = quantile(Social_dimension, 0.50),
                                                             q75 = quantile(Social_dimension, 0.75),
                                                             VC = stdev/aver) # variance coeficient: 
p18 <- ggplot(data_long_expSocDimA_CC, aes(x=citizen_cont, y = Social_dimension)) + 
  geom_boxplot() +
  ggtitle("citizen cont vs social dimension ")
ggsave("citizen Cont vs social.png", plot = p18, width = 25, height = 20)

# GC vs technical
data_long_expTechDimA_CC %>% group_by(citizen_cont) %>% summarise(aver = mean(Technical_dimension), 
                                                              median = median(Technical_dimension), 
                                                              stdev  =  sd(Technical_dimension),
                                                              q25 = quantile(Technical_dimension, 0.25), 
                                                              q50 = quantile(Technical_dimension, 0.50),
                                                              q75 = quantile(Technical_dimension, 0.75),
                                                              VC = stdev/aver) # variance coeficient: 
p19 <- ggplot(data_long_expTechDimA_CC, aes(x=citizen_cont, y = Technical_dimension)) + 
  geom_boxplot() +
  ggtitle("CC vs technical dimension ")
ggsave("CC vs Technical.png", plot = p19, width = 25, height = 20)

# CC vs eco
data_long_expEcoDimA_CC %>% group_by(citizen_cont) %>% summarise(aver = mean(Economic_dimension), 
                                                             median = median(Economic_dimension), 
                                                             stdev  =  sd(Economic_dimension),
                                                             q25 = quantile(Economic_dimension, 0.25), 
                                                             q50 = quantile(Economic_dimension, 0.50),
                                                             q75 = quantile(Economic_dimension, 0.75),
                                                             VC = stdev/aver) # variance coeficient: 
p20 <- ggplot(data_long_expEcoDimA_CC, aes(x=citizen_cont, y = Economic_dimension)) + 
  geom_boxplot() +
  ggtitle("CC vs economic dimension ")
ggsave("CC vs economic.png", plot = p20, width = 25, height = 20)

# CC vs env
data_long_expEnvDimA_CC %>% group_by(citizen_cont) %>% summarise(aver = mean(Environmental_dimension), 
                                                             median = median(Environmental_dimension), 
                                                             stdev  =  sd(Environmental_dimension),
                                                             q25 = quantile(Environmental_dimension, 0.25), 
                                                             q50 = quantile(Environmental_dimension, 0.50),
                                                             q75 = quantile(Environmental_dimension, 0.75),
                                                             VC = stdev/aver) # variance coeficient: 
p21 <- ggplot(data_long_expEnvDimA_CC, aes(x=citizen_cont, y = Environmental_dimension)) + 
  geom_boxplot() +
  ggtitle("CC vs Environmental dimension ")
ggsave("CC vs Environmental.png", plot = p21, width = 25, height = 20)





