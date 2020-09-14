library(xlsx)
library(tidyr)
library(ggplot2)
library(reshape2)
library(dplyr)
library(viridis)
library(dichromat)
library(RColorBrewer)
install.packages("GGally")
install.packages("ggplot2")
install.packages("rlang")a
install.packages("PerformanceAnalytics")
install.packages("ggpubr")
library(GGally)
library(PerformanceAnalytics)
library(ggpubr)
install.packages("writexl")
library(writexl)

setwd("E:/final_data")

fileDDMA_2 <- "file_2.xlsx"
fileDDMA_3 <- "file_3.xlsx"
fileDDMA_4 <- "file_4.xlsx"
res_2 <- "resilience_2.xlsx"
res_3 <- "resilience_3.xlsx"
res_4 <- "resilience_4.xlsx"


# read files
data_exp_DDMA2 <- readxl::read_excel(fileDDMA_2, sheet = "Run_DDMA_2")
data_set_DDMA2 <- readxl::read_excel(fileDDMA_2, sheet = "Policy_DDMA_2")
data_exp_DDMA3 <- readxl::read_excel(fileDDMA_3, sheet = "Run_DDMA_3")
data_set_DDMA3 <- readxl::read_excel(fileDDMA_3, sheet = "Policy_DDMA_3")
data_exp_DDMA4 <- readxl::read_excel(fileDDMA_4, sheet = "Run_DDMA_4")
data_set_DDMA4 <- readxl::read_excel(fileDDMA_4, sheet = "Policy_DDMA_4")
res2 <- readxl::read_excel(res_2, sheet = "Run_DDMA_2")
res3 <- readxl::read_excel(res_3, sheet = "Run_DDMA_3")
res4 <- readxl::read_excel(res_4, sheet = "Run_DDMA_4")

####  organize for DDMA2
toLong <- colnames(data_exp_DDMA2) #column names of Runs
data_exp_DDMA2$yearnow <- as.numeric(data_exp_DDMA2$yearnow_1)
data_exp_DDMA2$weeknow <-as.numeric(data_exp_DDMA2$weeknow_1)
remWeekDay <- c(paste("yearnow_", 1:90, sep = ""), paste("weeknow_", 1:90, sep = "")) # remove all the other yearnows and weeknows
ttt <- colnames(data_exp_DDMA2)[!colnames(data_exp_DDMA2) %in% remWeekDay]
data_exp_DDMA2 <- data_exp_DDMA2[, ttt]
data_long_exp_DDMA2 <- melt(data_exp_DDMA2, id.vars=c("yearnow", "weeknow"))
data_long_exp_DDMA2 <- data_long_exp_DDMA2[-1, ]

data_long_exp_DDMA2$weeknow2 <- ifelse(data_long_exp_DDMA2$yearnow == 1, data_long_exp_DDMA2$weeknow,
                                               ifelse(data_long_exp_DDMA2$yearnow == 2, data_long_exp_DDMA2$weeknow + 52, NA
                                                      ))

data_long_exp_DDMA2$variableID <- gsub("_[0-9]*$", "", data_long_exp_DDMA2$variable)
data_long_exp_DDMA2$run_number <- gsub("_|[a-z]*| ", "", data_long_exp_DDMA2$variable)
data_long_exp_DDMA2 <- merge(data_long_exp_DDMA2, data_set_DDMA2, by = "run_number", all.x = T)

data_long_expSocDim2 <- data_long_exp_DDMA2 %>% filter(variableID == "social_dim") # social dimension
data_long_expSocDim2$value <- as.numeric(data_long_expSocDim2$value)

data_long_expTechDim2 <- data_long_exp_DDMA2 %>% filter(variableID == "technical_dim") # technical dimension
data_long_expTechDim2$value <- as.numeric(data_long_expTechDim2$value)

data_long_expEcoDim2 <- data_long_exp_DDMA2 %>% filter(variableID == "economic_dimension") # economic dimension
data_long_expEcoDim2$value <- as.numeric(data_long_expEcoDim2$value)

data_long_expEnvDim2 <- data_long_exp_DDMA2 %>% filter(variableID == "environmental_dimension") # environmental dimension
data_long_expEnvDim2$value <- as.numeric(data_long_expEnvDim2$value)

data_long_expOppDim2 <- data_long_exp_DDMA2 %>% filter(variableID == "opportunistic") # opportunistic
data_long_expOppDim2$value <- as.numeric(data_long_expEnvDim2$value)


data_long_expIncDim2 <- data_long_exp_DDMA2 %>% filter(variableID == "increment_energy") # increment energy
data_long_expIncDim2$value <- as.numeric(data_long_expIncDim2$value)

### organize res 2
toLong <- colnames(res2) #column names of Runs
res2$yearnow <- as.numeric(res2$yearnow_1)
res2$weeknow2 <-as.numeric(res2$weeknow_1)
remWeekDay <- c(paste("yearnow_", 1:90, sep = ""), paste("weeknow_", 1:90, sep = "")) # remove all the other yearnows and weeknows
ttt <- colnames(res2)[!colnames(res2) %in% remWeekDay]
res2 <- res2[, ttt]
res_long_DDMA2 <- melt(res2, id.vars=c("yearnow", "weeknow2"))
res_long_DDMA2 <- res_long_DDMA2[-1, ]
res_long_DDMA2$variableID <- gsub("_[0-9]*$", "", res_long_DDMA2$variable)
res_long_DDMA2$run_number <- gsub("_|[a-z]*| ", "", res_long_DDMA2$variable)
res_long_DDMA2 <- merge(res_long_DDMA2, data_set_DDMA2, by = "run_number", all.x = T)

resDim2 <- res_long_DDMA2 %>% filter(variableID == "resilience") # resilience
resDim2$value <- as.numeric(resDim2$value)

## aggregated
data_long_expSocDim2A <- data_long_expSocDim2 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Social_dimension = mean(value, na.rm = T))

data_long_expTechDim2A <- data_long_expTechDim2 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim2A <- data_long_expEcoDim2 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim2A <- data_long_expEnvDim2 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

data_long_expOppDim2A <- data_long_expOppDim2 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Opportunistic = mean(value, na.rm = T))

data_long_expIncDim2A <- data_long_expIncDim2 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(increment_energy = mean(value, na.rm = T))

 resDim2A <- resDim2 %>% 
   group_by(run_number, yearnow, weeknow2) %>% summarise(resilience = mean(value, na.rm = T))

####  organize for DDMA3
toLong <- colnames(data_exp_DDMA3) #column names of Runs
data_exp_DDMA3$yearnow <- as.numeric(data_exp_DDMA3$yearnow_1)
data_exp_DDMA3$weeknow <-as.numeric(data_exp_DDMA3$weeknow_1)

remWeekDay <- c(paste("yearnow_", 1:90, sep = ""), paste("weeknow_", 1:90, sep = "")) # remove all the other yearnows and weeknows
ttt <- colnames(data_exp_DDMA3)[!colnames(data_exp_DDMA3) %in% remWeekDay]
data_exp_DDMA3 <- data_exp_DDMA3[, ttt]
data_long_exp_DDMA3 <- melt(data_exp_DDMA3, id.vars=c("yearnow", "weeknow"))
data_long_exp_DDMA3 <- data_long_exp_DDMA3[-1, ]

data_long_exp_DDMA3$weeknow2 <- ifelse(data_long_exp_DDMA3$yearnow == 1, data_long_exp_DDMA3$weeknow,
                                       ifelse(data_long_exp_DDMA3$yearnow == 2, data_long_exp_DDMA3$weeknow + 52, NA
                                       ))

data_long_exp_DDMA3$variableID <- gsub("_[0-9]*$", "", data_long_exp_DDMA3$variable)
data_long_exp_DDMA3$run_number <- gsub("_|[a-z]*| ", "", data_long_exp_DDMA3$variable)
data_long_exp_DDMA3 <- merge(data_long_exp_DDMA3, data_set_DDMA3, by = "run_number", all.x = T)


data_long_expSocDim3 <- data_long_exp_DDMA3 %>% filter(variableID == "social_dim") # social dimension
data_long_expSocDim3$value <- as.numeric(data_long_expSocDim3$value)

data_long_expTechDim3 <- data_long_exp_DDMA3 %>% filter(variableID == "technical_dim") # technical dimension
data_long_expTechDim3$value <- as.numeric(data_long_expTechDim3$value)

data_long_expEcoDim3 <- data_long_exp_DDMA3 %>% filter(variableID == "economic_dimension") # economic dimension
data_long_expEcoDim3$value <- as.numeric(data_long_expEcoDim3$value)

data_long_expEnvDim3 <- data_long_exp_DDMA3 %>% filter(variableID == "environmental_dimension") # environmental dimension
data_long_expEnvDim3$value <- as.numeric(data_long_expEnvDim3$value)

data_long_expOppDim3 <- data_long_exp_DDMA3 %>% filter(variableID == "opportunistic") # opportunistic
data_long_expOppDim3$value <- as.numeric(data_long_expEnvDim3$value)

data_long_expIncDim3 <- data_long_exp_DDMA3 %>% filter(variableID == "increment_energy") # increment energy
data_long_expIncDim3$value <- as.numeric(data_long_expIncDim3$value)

### organize res 3
toLong <- colnames(res3) #column names of Runs
res3$yearnow <- as.numeric(res3$yearnow_1)
res3$weeknow2 <-as.numeric(res3$weeknow_1)
remWeekDay <- c(paste("yearnow_", 1:90, sep = ""), paste("weeknow_", 1:90, sep = "")) # remove all the other yearnows and weeknows
ttt <- colnames(res3)[!colnames(res3) %in% remWeekDay]
res3 <- res3[, ttt]
res_long_DDMA3 <- melt(res3, id.vars=c("yearnow", "weeknow2"))
res_long_DDMA3 <- res_long_DDMA3[-1, ]
res_long_DDMA3$variableID <- gsub("_[0-9]*$", "", res_long_DDMA3$variable)
res_long_DDMA3$run_number <- gsub("_|[a-z]*| ", "", res_long_DDMA3$variable)
res_long_DDMA3 <- merge(res_long_DDMA3, data_set_DDMA3, by = "run_number", all.x = T)

resDim3 <- res_long_DDMA3%>% filter(variableID == "resilience") # resilience
resDim3$value <- as.numeric(resDim3$value)

## aggregated
data_long_expSocDim3A <- data_long_expSocDim3 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Social_dimension = mean(value, na.rm = T))

data_long_expTechDim3A <- data_long_expTechDim3 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim3A <- data_long_expEcoDim3 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim3A <- data_long_expEnvDim3 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

data_long_expOppDim3A <- data_long_expOppDim3 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Opportunistic = mean(value, na.rm = T))

data_long_expIncDim3A <- data_long_expIncDim3 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(increment_energy = mean(value, na.rm = T))

resDim3A <- resDim3 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(resilience = mean(value, na.rm = T))

####  organize for DDMA4
toLong <- colnames(data_exp_DDMA4) #column names of Runs
data_exp_DDMA4$yearnow <- as.numeric(data_exp_DDMA4$yearnow_1)
data_exp_DDMA4$weeknow <-as.numeric(data_exp_DDMA4$weeknow_1)
remWeekDay <- c(paste("yearnow_", 1:90, sep = ""), paste("weeknow_", 1:90, sep = "")) # remove all the other yearnows and weeknows
ttt <- colnames(data_exp_DDMA4)[!colnames(data_exp_DDMA4) %in% remWeekDay]
data_exp_DDMA4 <- data_exp_DDMA4[, ttt]
data_long_exp_DDMA4 <- melt(data_exp_DDMA4, id.vars=c("yearnow", "weeknow"))
data_long_exp_DDMA4 <- data_long_exp_DDMA4[-1, ]

data_long_exp_DDMA4$weeknow2 <- ifelse(data_long_exp_DDMA4$yearnow == 1, data_long_exp_DDMA4$weeknow,
                                       ifelse(data_long_exp_DDMA4$yearnow == 2, data_long_exp_DDMA4$weeknow + 52, NA
                                       ))

data_long_exp_DDMA4$variableID <- gsub("_[0-9]*$", "", data_long_exp_DDMA4$variable)
data_long_exp_DDMA4$run_number <- gsub("_|[a-z]*| ", "", data_long_exp_DDMA4$variable)
data_long_exp_DDMA4 <- merge(data_long_exp_DDMA4, data_set_DDMA4, by = "run_number", all.x = T)


data_long_expSocDim4 <- data_long_exp_DDMA4 %>% filter(variableID == "social_dim") # social dimension
data_long_expSocDim4$value <- as.numeric(data_long_expSocDim4$value)

data_long_expTechDim4 <- data_long_exp_DDMA4 %>% filter(variableID == "technical_dim") # technical dimension
data_long_expTechDim4$value <- as.numeric(data_long_expTechDim4$value)

data_long_expEcoDim4 <- data_long_exp_DDMA4 %>% filter(variableID == "economic_dimension") # economic dimension
data_long_expEcoDim4$value <- as.numeric(data_long_expEcoDim4$value)

data_long_expEnvDim4 <- data_long_exp_DDMA4 %>% filter(variableID == "environmental_dimension") # environmental dimension
data_long_expEnvDim4$value <- as.numeric(data_long_expEnvDim4$value)

data_long_expOppDim4 <- data_long_exp_DDMA4 %>% filter(variableID == "opportunistic") # opportunistic
data_long_expOppDim4$value <- as.numeric(data_long_expOppDim4$value)

data_long_expIncDim4 <- data_long_exp_DDMA4 %>% filter(variableID == "increment_energy") # increment energy
data_long_expIncDim4$value <- as.numeric(data_long_expIncDim4$value)

### organize res 4
toLong <- colnames(res4) #column names of Runs
res4$yearnow <- as.numeric(res4$yearnow_1)
res4$weeknow2 <-as.numeric(res4$weeknow_1)
remWeekDay <- c(paste("yearnow_", 1:90, sep = ""), paste("weeknow_", 1:90, sep = "")) # remove all the other yearnows and weeknows
ttt <- colnames(res4)[!colnames(res4) %in% remWeekDay]
res4 <- res4[, ttt]
res_long_DDMA4 <- melt(res4, id.vars=c("yearnow", "weeknow2"))
res_long_DDMA4 <- res_long_DDMA4[-1, ]
res_long_DDMA4$variableID <- gsub("_[0-9]*$", "", res_long_DDMA4$variable)
res_long_DDMA4$run_number <- gsub("_|[a-z]*| ", "", res_long_DDMA4$variable)
res_long_DDMA4 <- merge(res_long_DDMA4, data_set_DDMA4, by = "run_number", all.x = T)

resDim4 <- res_long_DDMA4 %>% filter(variableID == "resilience") # resilience
resDim4$value <- as.numeric(resDim4$value)

## aggregated
data_long_expSocDim4A <- data_long_expSocDim4 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Social_dimension = mean(value, na.rm = T))

data_long_expTechDim4A <- data_long_expTechDim4 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Technical_dimension = mean(value, na.rm = T))

data_long_expEcoDim4A <- data_long_expEcoDim4 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Economic_dimension = mean(value, na.rm = T))

data_long_expEnvDim4A <- data_long_expEnvDim4 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Environmental_dimension = mean(value, na.rm = T))

data_long_expOppDim4A <- data_long_expOppDim4 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(Opportunistic = mean(value, na.rm = T))

data_long_expIncDim4A <- data_long_expIncDim4 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(increment_energy = mean(value, na.rm = T))

resDim4A <- resDim4 %>% 
  group_by(run_number, yearnow, weeknow2) %>% summarise(resilience = mean(value, na.rm = T))

data_long_expSocDim2A = merge(data_long_expSocDim2A, data_set_DDMA2, by = 'run_number', all.x = T)
data_long_expSocDim3A = merge(data_long_expSocDim3A, data_set_DDMA3, by = 'run_number', all.x = T)
data_long_expSocDim4A = merge(data_long_expSocDim4A, data_set_DDMA4, by = 'run_number', all.x = T)

data_long_expTechDim2A = merge(data_long_expTechDim2A, data_set_DDMA2, by = 'run_number', all.x = T)
data_long_expTechDim3A = merge(data_long_expTechDim3A, data_set_DDMA3, by = 'run_number', all.x = T)
data_long_expTechDim4A = merge(data_long_expTechDim4A, data_set_DDMA4, by = 'run_number', all.x = T)

data_long_expEcoDim2A = merge(data_long_expEcoDim2A, data_set_DDMA2, by = 'run_number', all.x = T)
data_long_expEcoDim3A = merge(data_long_expEcoDim3A, data_set_DDMA3, by = 'run_number', all.x = T)
data_long_expEcoDim4A = merge(data_long_expEcoDim4A, data_set_DDMA4, by = 'run_number', all.x = T)

data_long_expEnvDim2A = merge(data_long_expEnvDim2A, data_set_DDMA2, by = 'run_number', all.x = T)
data_long_expEnvDim3A = merge(data_long_expEnvDim3A, data_set_DDMA3, by = 'run_number', all.x = T)
data_long_expEnvDim4A = merge(data_long_expEnvDim4A, data_set_DDMA4, by = 'run_number', all.x = T)

data_long_expOppDim2A = merge(data_long_expOppDim2A, data_set_DDMA2, by = 'run_number', all.x = T)
data_long_expOppDim3A = merge(data_long_expOppDim3A, data_set_DDMA3, by = 'run_number', all.x = T)
data_long_expOppDim4A = merge(data_long_expOppDim4A, data_set_DDMA4, by = 'run_number', all.x = T)

data_long_expIncDim2A = merge(data_long_expIncDim2A, data_set_DDMA2, by = 'run_number', all.x = T)
data_long_expIncDim3A = merge(data_long_expIncDim3A, data_set_DDMA3, by = 'run_number', all.x = T)
data_long_expIncDim4A = merge(data_long_expIncDim4A, data_set_DDMA4, by = 'run_number', all.x = T)

resDim2A = merge(resDim2A, data_set_DDMA2, by = 'run_number', all.x = T)
resDim3A = merge(resDim3A, data_set_DDMA3, by = 'run_number', all.x = T)
resDim4A = merge(resDim4A, data_set_DDMA4, by = 'run_number', all.x = T)


data_set1 <- rbind(data_long_expSocDim4A, 
                   data_long_expSocDim3A,
                   data_long_expSocDim2A)
data_set1$ID = 1:nrow(data_set1)

data_set2 <- rbind(data_long_expTechDim4A,
                   data_long_expTechDim3A,
                   data_long_expTechDim2A)
data_set2$ID = 1:nrow(data_set2)

data_set3 <- rbind(data_long_expEcoDim4A,
                   data_long_expEcoDim3A,
                   data_long_expEcoDim2A)
data_set3$ID = 1:nrow(data_set3)

data_set4 <- rbind(data_long_expEnvDim4A,
                   data_long_expEnvDim3A,
                   data_long_expEnvDim2A)
data_set4$ID = 1:nrow(data_set4)

data_set5 <- rbind(data_long_expOppDim4A,
                   data_long_expOppDim3A,
                   data_long_expOppDim2A)
data_set5$ID = 1:nrow(data_set5)

data_set6 <- rbind(data_long_expIncDim4A,
                   data_long_expIncDim3A,
                   data_long_expIncDim2A)
data_set6$ID = 1:nrow(data_set6)

data_set7 <- rbind(resDim4A,
                   resDim3A,
                   resDim2A)
data_set7$ID = 1:nrow(data_set7)


data_set = merge(data_set1, data_set2[, c('Technical_dimension', 'ID')], by = 'ID')
data_set = merge(data_set, data_set3[, c('Economic_dimension', 'ID')], by = 'ID')
data_set = merge(data_set, data_set4[, c('Environmental_dimension', 'ID')], by = 'ID')
data_set = merge(data_set, data_set5[, c('Opportunistic', 'ID')], by = 'ID')
data_set = merge(data_set, data_set6[, c('increment_energy', 'ID')], by = 'ID')

data_set = merge(data_set, data_set7[, c('resilience', 'ID')], by = 'ID')

fit <- lm(Technical_dimension ~ Opportunistic + increment_energy, data=data_set)
summary(fit)

###################### Opportunistic correlation with dimensions #########################
cor.test(data_set$Opportunistic, data_set$Social_dimension,
         alternative = "two.sided",
         method = "kendall",
         exact = NULL, conf.level = 0.95, continuity = FALSE)
dataset_opp_soc <- data_set %>% select(Opportunistic,Social_dimension)
p5 <- chart.Correlation(dataset_opp_soc, histogram=TRUE,method = "", pch=19)
ggsave("opp_vs_soc.png", plot = p5, width = 15)

fit <- lm(Social_dimension ~ Opportunistic, data=data_set)
summary(fit)

cor.test(data_set$Opportunistic,data_set$Technical_dimension,
         alternative = "two.sided",
         method = "pearson",
         exact = NULL, conf.level = 0.95, continuity = FALSE)
dataset_opp_tech <- data_set %>% select(Opportunistic,Technical_dimension)
p6 <- chart.Correlation(dataset_opp_tech, histogram=TRUE, pch=19)
ggsave("opp_vs_tech.png", plot = p6, width = 15)

fit <- lm(resilience ~ Opportunistic + increment_energy, data=data_set)
summary(fit)
anova(fit)

cor.test(data_set$Economic_dimension, data_set$Opportunistic,
         alternative = "two.sided",
         method = "kendall",
         exact = NULL, conf.level = 0.95, continuity = FALSE)
dataset_opp_eco <- data_set %>% select(Opportunistic,Economic_dimension)
p7 <- chart.Correlation(dataset_opp_eco, histogram=TRUE, pch=19)
ggsave("opp_vs_eco.png", plot = p7, width = 15)

cor.test(data_set$Environmental_dimension, data_set$Opportunistic,
         alternative = "two.sided",
         method = "pearson",
         exact = NULL, conf.level = 0.95, continuity = FALSE)
dataset_opp_env <- data_set %>% select(Opportunistic,Environmental_dimension)
p8 <- chart.Correlation(dataset_opp_env, histogram=TRUE, pch=19)
ggsave("opp_vs_env.png", plot = p8, width = 15)

cor.test(data_set$resilience, data_set$Opportunistic,
         alternative = "two.sided",
         method = "kendall",
         exact = NULL, conf.level = 0.95, continuity = FALSE)
dataset_opp_res <- data_set %>% select(Opportunistic,resilience)
p9 <- chart.Correlation(dataset_opp_res, histogram=TRUE,method = "kendall", pch=19)
ggsave("opp_vs_res.png", plot = p9, width = 15)


cor.test(data_set$resilience, data_set$increment_energy,
         alternative = "two.sided",
         method = "pearson",
         exact = NULL, conf.level = 0.95, continuity = FALSE)
dataset_inc_res <- data_set %>% select(increment_energy,resilience)
p10 <- chart.Correlation(dataset_inc_res, histogram=TRUE, pch=19)
ggsave("inc_vs_res.png", plot = p10, width = 15)
###############################################################################################

dataset_opp_soc <- data_set %>% select(Opportunistic,Social_dimension)

data_res_inc <- data_res_inc %>% select(increment_energy,resilience, weeknow)

###################### increment correlation with dimensions #################################
cor.test(data_set$Social_dimension, data_set$increment_energy,
         alternative = "two.sided",
         method = "pearson",
         exact = NULL, conf.level = 0.95, continuity = FALSE)
dataset_inc_soc <- data_set %>% select(increment_energy,Social_dimension)
p1 <- chart.Correlation(dataset_inc_soc, histogram=TRUE, pch=19)
ggsave("inc_vs_soc.png", plot = p1, width = 15)

cor.test(data_set$Technical_dimension, data_set$increment_energy,
         alternative = "two.sided",
         method = "pearson",
         exact = NULL, conf.level = 0.95, continuity = FALSE)
dataset_inc_tech <- data_set %>% select(increment_energy,Technical_dimension)
p2 <- chart.Correlation(dataset_inc_tech, histogram=TRUE, pch=19)
ggsave("inc_vs_tech.png", plot = p2, width = 15)

cor.test(data_set$Economic_dimension, data_set$increment_energy,
         alternative = "two.sided",
         method = "pearson",
         exact = NULL, conf.level = 0.95, continuity = FALSE)
dataset_inc_eco <- data_set %>% select(increment_energy,Economic_dimension)
p3 <- chart.Correlation(dataset_inc_eco, histogram=TRUE, pch=19)
ggsave("inc_vs_eco.png", plot = p3, width = 15)

cor.test(data_set$Environmental_dimension, data_set$increment_energy,
         alternative = "two.sided",
         method = "pearson",
         exact = NULL, conf.level = 0.95, continuity = FALSE)
dataset_inc_env <- data_set %>% select(increment_energy,Environmental_dimension)
p4 <- chart.Correlation(dataset_inc_env, histogram=TRUE, pch=19)
ggsave("inc_vs_env.png", plot = p4, width = 15)

dataset_inc <- data_set %>% select(increment_energy,Social_dimension, Technical_dimension, Economic_dimension, Environmental_dimension)

save(data_set, file = "listDATA.Rdata")

cor(dataset_opp_soc)

ggcorr(dataset_opp,
       midpoint = 0.2,
       palette = NULL,
       geom = "tile",
       min_size = 2,
       max_size = 6,
       label = FALSE,
       label_alpha = FALSE,
       label_color = "black",
       label_round = 1,
       label_size = 4,
       limits = c(-0.2, 1),
       drop = is.null(limits) || identical(limits, FALSE),
       layout.exp = 0,
       legend.position = "right",
       legend.size = 9)


chart.Correlation(dataset_opp_soc, histogram=TRUE, pch=19)

cor(dataset_inc)

ggcorr(dataset_inc,
       midpoint = 0.2,
       palette = NULL,
       geom = "tile",
       min_size = 2,
       max_size = 6,
       label = FALSE,
       label_alpha = FALSE,
       label_color = "black",
       label_round = 1,
       label_size = 4,
       limits = c(-0.2, 1),
       drop = is.null(limits) || identical(limits, FALSE),
       layout.exp = 0,
       legend.position = "right",
       legend.size = 9)


chart.Correlation(dataset_inc, histogram=TRUE, pch=19)


########################################################
########################################################
########################################################

social_class <- c(-Inf, 0.3, 0.6, Inf)
tech_class <- c(-Inf, 0.3, 0.6, Inf)
eco_class <- c(-Inf, 0.3, 0.6, Inf)
env_class <- c(-Inf, 0.3, 0.6, Inf)

data_set$socio <- cut(data_set$Social_dimension, breaks = social_class, labels = c("low", "medium", "high"))
data_set$tech <- cut(data_set$Technical_dimension, breaks = tech_class, labels = c("low", "medium", "high"))
data_set$eco <- cut(data_set$Economic_dimension, breaks = eco_class, labels = c("low", "medium", "high"))
data_set$env <- cut(data_set$Environmental_dimension, breaks = env_class, labels = c("low", "medium", "high"))

table <- data_set %>% group_by(socio, tech, env) %>% summarise(economic = mean(Economic_dimension))
write_xlsx(table,"classifytry.xlsx")

leverset1 <-  data_set %>% filter(socio == "medium" & tech == "medium" & env == "low" & eco == "low") %>% select (Lever_power_KC, Lever_power_SDMA, Lever_power_DDMA, socio, tech, env, eco)
leverset2 <-  data_set %>% filter(socio == "high" & tech == "medium" & env == "low" & eco == "low" ) %>% select (Lever_power_KC, Lever_power_SDMA, Lever_power_DDMA, socio, tech, env, eco)
new_data <- rbind (leverset1, leverset2)
finalset <- unique(new_data)
write_xlsx(finalset,"fipower_policy2.xlsx")
#leverset2 <- subset(leverset1, select = -c(ID, run_number, yearnow, weeknow, Social_dimension,Technical_dimension, Environmental_dimension,Economic_dimension, Opportunistic, Policy, increment_energy))

data_set$Policy_Label <- with(data_set,
                                            paste(
                                              paste("Policy:", Policy, sep = ""),   
                                              paste("DDMA:", Lever_power_DDMA, sep = ""),
                                              paste("SDMA:", Lever_power_SDMA, sep = ""),
                                              paste("KC:", Lever_power_KC, sep = ""),
                                              sep = " "))
nPol <- length(unique(data_set$Policy_Label))
getPalette = colorRampPalette(brewer.pal(9, "Set1"))
Top_Top_Policies <- c("Policy:5 DDMA:3 SDMA:3 KC:3", 
                      "Policy:1 DDMA:4 SDMA:2 KC:2", 
                      "Policy:4 DDMA:4 SDMA:2 KC:3")

data_set$Policy_2 <- ifelse( data_set$Policy_Label %in% Top_Top_Policies, data_set$Policy_Label, "Other Policies" )
#nPol <- length(unique(data_set$Policy_2))

data_OnTop_TopPolicy <- subset(data_set, Policy_Label %in% Top_Top_Policies)


plot_top <- ggplot(data_OnTop_TopPolicy, aes(x = weeknow2, y = Social_dimension, color = Policy_Label)) + 
  geom_boxplot() +  
  stat_smooth(aes(x = as.numeric(weeknow2), y = Social_dimension), method = "lm",
              formula = y ~ poly(x, 15), se = FALSE) +
  theme(legend.text=element_text(size=8), legend.title=element_text(size=10), axis.text.x = element_text(size=6, angle = 90))+ 
  guides(color=guide_legend(title="Policy")) + 
  scale_x_continuous(breaks = 0:104, name = "Week") + 
  scale_y_continuous(breaks = seq(-1, 1, by = 0.1), name = "social dimension") + 
  guides(color=guide_legend(title="Top Policies")) + 
  scale_color_manual(values = getPalette(nPol)) +
  scale_colour_brewer(palette = "Dark2") +
  ggtitle("Results of social dimension")
ggsave("Results_TopPolicies_social.png", width = 20)

## Box plot socio
plot_top <- ggplot(data_OnTop_TopPolicy, aes(x = Policy_Label, y = Social_dimension, color = Policy_Label)) + 
  geom_boxplot() +
  scale_colour_brewer(palette = "Dark2") +
  scale_y_continuous(breaks = seq(-1, 1, by = 0.1), name = "social dimension") + 
  ggtitle("Results of social dimension")
ggsave("Results_TopPolicies_social.png", width = 20)


plot_top1 <- ggplot(data_OnTop_TopPolicy, aes(x = weeknow2, y =Technical_dimension, color = Policy_Label)) + 
  geom_point(alpha = 0.1) + 
  stat_smooth(aes(x = as.numeric(weeknow2), y = Technical_dimension), method = "lm",
              formula = y ~ poly(x, 15), se = FALSE) +
  theme(legend.text=element_text(size=8), legend.title=element_text(size=10), axis.text.x = element_text(size=6, angle = 90))+ 
  guides(color=guide_legend(title="Policy")) + 
  scale_x_continuous(breaks = 0:104, name = "Week") + 
  scale_y_continuous(breaks = seq(-1, 1, by = 0.1), name = "Technical dimension") + 
  guides(color=guide_legend(title="Top Policies")) + 
  scale_color_manual(values = getPalette(nPol)) + 
  scale_colour_brewer(palette = "Dark2") +
  ggtitle("Results of technical dimension")
ggsave("Results_TopPolicies_technical.png", width = 20)

## Box plot tech
plot_top <- ggplot(data_OnTop_TopPolicy, aes(x = Policy_Label, y = Technical_dimension, color = Policy_Label)) + 
  geom_boxplot() +
  scale_colour_brewer(palette = "Dark2") +
  
  scale_y_continuous(breaks = seq(-1, 1, by = 0.1), name = "Technical dimension") + 
  ggtitle("Results of technical dimension")
ggsave("Results_TopPolicies_technical.png", width = 20)

plot_top2 <- ggplot(data_OnTop_TopPolicy, aes(x = weeknow2, y =Economic_dimension, color = Policy_Label)) + 
  geom_point(alpha = 0.1) + 
  stat_smooth(aes(x = as.numeric(weeknow2), y = Economic_dimension), method = "lm",
              formula = y ~ poly(x, 15), se = FALSE) +
  theme(legend.text=element_text(size=8), legend.title=element_text(size=10), axis.text.x = element_text(size=6, angle = 90))+ 
  guides(color=guide_legend(title="Policy")) + 
  scale_x_continuous(breaks = 0:104, name = "Week") + 
  scale_y_continuous(breaks = seq(-1, 1, by = 0.1), name = "Economic dimension") + 
  guides(color=guide_legend(title="Top Policies")) + 
  scale_color_manual(values = getPalette(nPol)) +
  scale_colour_brewer(palette = "Dark2") +
  ggtitle("Results of economic dimension")
ggsave("Results_TopPolicies_economic.png", width = 20)

### box plot eco

plot_top2 <- ggplot(data_OnTop_TopPolicy, aes(x = Policy_Label, y =Economic_dimension, color = Policy_Label)) + 
  geom_boxplot() +
  scale_colour_brewer(palette = "Dark2") +
  
  scale_y_continuous(breaks = seq(-1, 1, by = 0.1), name = "Economic dimension") + 
  ggtitle("Results of economic dimension")
ggsave("Results_TopPolicies_economic.png", width = 20)

plot_top4 <- ggplot(data_OnTop_TopPolicy, aes(x = weeknow2, y =Environmental_dimension, color = Policy_Label)) + 
  geom_point(alpha = 0.1) + 
  stat_smooth(aes(x = as.numeric(weeknow2), y = Environmental_dimension), method = "lm",
              formula = y ~ poly(x, 15), se = FALSE) +
  theme(legend.text=element_text(size=8), legend.title=element_text(size=10), axis.text.x = element_text(size=6, angle = 90))+ 
  guides(color=guide_legend(title="Policy")) + 
  scale_x_continuous(breaks = 0:104, name = "Week") + 
  scale_y_continuous(breaks = seq(-1, 1, by = 0.1), name = "Environmental dimension") + 
  guides(color=guide_legend(title="Top Policies")) + 
  scale_color_manual(values = getPalette(nPol)) + 
  scale_colour_brewer(palette = "Dark2") +
  ggtitle("Results of environmental dimension")
ggsave("Results_TopPolicies_environmental.png", width = 20)

### box plot env

plot_top3 <- ggplot(data_OnTop_TopPolicy, aes(x = Policy_Label, y =Environmental_dimension, color = Policy_Label)) + 
  geom_boxplot() + 
  scale_colour_brewer(palette = "Dark2") +
 
  scale_y_continuous(breaks = seq(0, 1, by = 0.1), name = "Environmental dimension") + 
  ggtitle("Results of environmental dimension")
ggsave("Results_TopPolicies_environmental_box.png", width = 20)
