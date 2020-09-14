###### study the impacts of opportunistic behaviour, increment energy and power distribution on resilience

library(xlsx)
library(tidyr)
library(ggplot2)
library(reshape2)
library(dplyr)
library(viridis)
library(dichromat)
library(RColorBrewer)

setwd("E:/resilience")

fileDDMA_2 <- "resilience_2.xlsx"
fileDDMA_3 <- "resilience_3.xlsx"
fileDDMA_4 <- "resilience_4.xlsx"


data_exp_DDMA3 <- readxl::read_excel(fileDDMA_3, sheet = "Run_DDMA_3")
data_set_DDMA3 <- readxl::read_excel(fileDDMA_3, sheet = "Policy_DDMA_3")

data_exp_DDMA2 <- readxl::read_excel(fileDDMA_2, sheet = "Run_DDMA_2")
data_set_DDMA2 <- readxl::read_excel(fileDDMA_2, sheet = "Policy_DDMA_2")

#data_exp_DDMA3 <- read.table("Run_DDMA_3.csv", header = T, sep = ";", dec = ".")
#data_set_DDMA3 <- read.table("Policy_DDMA_3.csv", header = T, sep = ";", dec = ".")

data_exp_DDMA4 <- readxl::read_excel(fileDDMA_4, sheet = "Run_DDMA_4")
data_set_DDMA4 <- readxl::read_excel(fileDDMA_4, sheet = "Policy_DDMA_4")

####  organize for DDMA2
toLong <- colnames(data_exp_DDMA2) #column names of Runs
data_exp_DDMA2$yearnow <- data_exp_DDMA2$yearnow_1 # all yearnow and weeknow are same so we just need one of each
data_exp_DDMA2$weeknow <- data_exp_DDMA2$weeknow_1
remWeekDay <- c(paste("yearnow_", 1:90, sep = ""), paste("weeknow_", 1:90, sep = "")) # remove all the other yearnows and weeknows
ttt <- colnames(data_exp_DDMA2)[!colnames(data_exp_DDMA2) %in% remWeekDay]
data_exp_DDMA2 <- data_exp_DDMA2[, ttt]
data_long_exp_DDMA2 <- melt(data_exp_DDMA2, id.vars=c("yearnow", "weeknow"))
data_long_exp_DDMA2 <- data_long_exp_DDMA2[-1, ]

####  organize the data for DDMA3
toLong <- colnames(data_exp_DDMA3) #column names of Runs
data_exp_DDMA3$yearnow <- data_exp_DDMA3$yearnow_1 # all yearnow and weeknow are same so we just need one of each
data_exp_DDMA3$weeknow <- data_exp_DDMA3$weeknow_1
remWeekDay <- c(paste("yearnow_", 1:90, sep = ""), paste("weeknow_", 1:90, sep = "")) # remove all the other yearnows and weeknows
ttt <- colnames(data_exp_DDMA3)[!colnames(data_exp_DDMA3) %in% remWeekDay]
data_exp_DDMA3 <- data_exp_DDMA3[, ttt]
data_long_exp_DDMA3 <- melt(data_exp_DDMA3, id.vars=c("yearnow", "weeknow"))
data_long_exp_DDMA3 <- data_long_exp_DDMA3[-1, ]

#organize the data for DDMA4
toLong <- colnames(data_exp_DDMA4) #column names of Runs
data_exp_DDMA4$yearnow <- data_exp_DDMA4$yearnow_1 # all yearnow and weeknow are same so we just need one of each
data_exp_DDMA4$weeknow <- data_exp_DDMA4$weeknow_1
remWeekDay <- c(paste("yearnow_", 1:90, sep = ""), paste("weeknow_", 1:90, sep = "")) # remove all the other yearnows and weeknows
ttt <- colnames(data_exp_DDMA4)[!colnames(data_exp_DDMA4) %in% remWeekDay]
data_exp_DDMA4 <- data_exp_DDMA4[, ttt]
data_long_exp_DDMA4 <- melt(data_exp_DDMA4, id.vars=c("yearnow", "weeknow"))
data_long_exp_DDMA4 <- data_long_exp_DDMA4[-1, ]

############################# copy and prepare data for analysis before median
## data for DDMA2
data_long_exp_DDMA2_C <- data_long_exp_DDMA2
data_long_exp_DDMA2_C$variableID <- gsub("_[0-9]*$", "", data_long_exp_DDMA2_C$variable)
data_long_exp_DDMA2_C$run_number <- gsub("_|[a-z]*| ", "", data_long_exp_DDMA2_C$variable)
data_long_exp_DDMA2_C <- merge(data_long_exp_DDMA2_C, data_set_DDMA2, by = "run_number", all.x = T)
data_long_exp_DDMA2_C$Policy_Label <- with(data_long_exp_DDMA2_C,
                                           paste(
                                             paste("Policy:", Policy, sep = ""),   
                                             paste("DDMA:", Lever_power_DDMA, sep = ""),
                                             paste("SDMA:", Lever_power_SDMA, sep = ""),
                                             paste("KC:", Lever_power_KC, sep = ""),
                                             sep = " "))
data_long_exp_DDMA2_C_res <- data_long_exp_DDMA2_C %>% filter(variableID == "resilience")
### add what Fabio added
data_long_exp_DDMA2_C_res$ID <- with(data_long_exp_DDMA2_C_res, paste(yearnow, weeknow, sep = "_") )
data_long_exp_DDMA2_C_res$ID <- factor(data_long_exp_DDMA2_C_res$ID)
data_long_exp_DDMA2_C_res$ID2 <- as.numeric(data_long_exp_DDMA2_C_res$ID)

data_long_exp_DDMA2_C_res$run_number <- as.numeric(data_long_exp_DDMA2_C_res$run_number)
data_long_exp_DDMA2_C_res$Policy_Label <- factor(data_long_exp_DDMA2_C_res$Policy_Label)

p <- ggplot(data_long_exp_DDMA2_C_res, aes(x=ID2, y = value)) + 
  geom_point(aes(colour = run_number))
ggsave("DDMA2_res.png", plot = p, width = 15)

p1 <- ggplot(data_long_exp_DDMA2_C_res, aes(x=ID2, y = value)) + 
  geom_point(aes(colour = Policy_Label))
ggsave("DDMA2_res1.png", plot = p1, width = 15)

p2 <- ggplot(data_long_exp_DDMA2_C_res, aes(x=ID2, y = value, group= round(ID2/2))) + 
  geom_boxplot() 
ggsave("DDMA2_res_box.png", plot = p2, width = 15)

# try another way for box plot
value_res_2 <- subset(data_long_exp_DDMA2_C, variableID %in% c("resilience"))
value_res_2 <- value_res_2 %>% group_by(run_number, weeknow, variableID) %>% summarise(meanVar = mean(Median))
value_res_2 <- dcast(value_res_2, weeknow + Policy_Label ~ variableID)

boxplot(value ~run_number ,data_long_exp_DDMA2_C_res )
ggplot(data_long_exp_DDMA2_C_res, aes(x = run_number, y = value)) +
  geom_boxplot() + 
  theme(axis.text.x = element_text(size=1, angle = 90)) + 
  ggtitle("Boxplot of run data DDMA 2")
ggsave("Boxplot_test.png")

## data for DDMA3
data_long_exp_DDMA3_C <- data_long_exp_DDMA3
data_long_exp_DDMA3_C$variableID <- gsub("_[0-9]*$", "", data_long_exp_DDMA3_C$variable)
data_long_exp_DDMA3_C$run_number <- gsub("_|[a-z]*| ", "", data_long_exp_DDMA3_C$variable)
data_long_exp_DDMA3_C <- merge(data_long_exp_DDMA3_C, data_set_DDMA3, by = "run_number", all.x = T)
data_long_exp_DDMA3_C$Policy_Label <- with(data_long_exp_DDMA3_C,
                                           paste(
                                             paste("Policy:", Policy, sep = ""),   
                                             paste("DDMA:", Lever_power_DDMA, sep = ""),
                                             paste("SDMA:", Lever_power_SDMA, sep = ""),
                                             paste("KC:", Lever_power_KC, sep = ""),
                                             sep = " "))
data_long_exp_DDMA3_C_res <- data_long_exp_DDMA3_C %>% filter(variableID == "resilience")
data_long_exp_DDMA3_C_res$ID <- with(data_long_exp_DDMA3_C_res, paste(yearnow, weeknow, sep = "_") )
data_long_exp_DDMA3_C_res$ID <- factor(data_long_exp_DDMA3_C_res$ID)
data_long_exp_DDMA3_C_res$ID2 <- as.numeric(data_long_exp_DDMA3_C_res$ID)

data_long_exp_DDMA3_C_res$run_number <- as.numeric(data_long_exp_DDMA3_C_res$run_number)
data_long_exp_DDMA3_C_res$Policy_Label <- factor(data_long_exp_DDMA3_C_res$Policy_Label)

p3 <- ggplot(data_long_exp_DDMA3_C_res, aes(x=ID2, y = value)) + 
  geom_point(aes(colour = run_number))
ggsave("DDMA3_res.png", plot = p, width = 15)

p4 <- ggplot(data_long_exp_DDMA3_C_res, aes(x=ID2, y = value)) + 
  geom_point(aes(colour = Policy_Label))
ggsave("DDMA3_res1.png", plot = p1, width = 15)

p5 <- ggplot(data_long_exp_DDMA3_C_res, aes(x=ID2, y = value, group= round(ID2/2))) + 
  geom_boxplot()
ggsave("DDMA3_res_box.png", plot = p2, width = 15)

## data for DDMA4
data_long_exp_DDMA4_C <- data_long_exp_DDMA3
data_long_exp_DDMA4_C$variableID <- gsub("_[0-9]*$", "", data_long_exp_DDMA4_C$variable)
data_long_exp_DDMA4_C$run_number <- gsub("_|[a-z]*| ", "", data_long_exp_DDMA4_C$variable)
data_long_exp_DDMA4_C <- merge(data_long_exp_DDMA4_C, data_set_DDMA4, by = "run_number", all.x = T)
data_long_exp_DDMA4_C$Policy_Label <- with(data_long_exp_DDMA4_C,
                                           paste(
                                             paste("Policy:", Policy, sep = ""),   
                                             paste("DDMA:", Lever_power_DDMA, sep = ""),
                                             paste("SDMA:", Lever_power_SDMA, sep = ""),
                                             paste("KC:", Lever_power_KC, sep = ""),
                                             sep = " "))
data_long_exp_DDMA4_C_res <- data_long_exp_DDMA4_C %>% filter(variableID == "resilience")
data_long_exp_DDMA4_C_res$ID <- with(data_long_exp_DDMA4_C_res, paste(yearnow, weeknow, sep = "_") )
data_long_exp_DDMA4_C_res$ID <- factor(data_long_exp_DDMA4_C_res$ID)
data_long_exp_DDMA4_C_res$ID2 <- as.numeric(data_long_exp_DDMA4_C_res$ID)

data_long_exp_DDMA4_C_res$run_number <- as.numeric(data_long_exp_DDMA4_C_res$run_number)
data_long_exp_DDMA4_C_res$Policy_Label <- factor(data_long_exp_DDMA4_C_res$Policy_Label)  


p6 <- ggplot(data_long_exp_DDMA4_C_res, aes(x=ID2, y = value)) + 
  geom_point(aes(colour = run_number))
ggsave("DDMA4_res.png", plot = p, width = 15)

p7 <- ggplot(data_long_exp_DDMA4_C_res, aes(x=ID2, y = value)) + 
  geom_point(aes(colour = Policy_Label))
ggsave("DDMA4_res1.png", plot = p1, width = 15)

p8 <- ggplot(data_long_exp_DDMA4_C_res, aes(x=ID2, y = value, group= round(ID2/2))) + 
  geom_boxplot()
ggsave("DDMA4_res_box.png", plot = p2, width = 15)

##########combine all the three before median for total results

 data_long_exp_DDMA_C_res <- rbind(data_long_exp_DDMA2_C_res, data_long_exp_DDMA3_C_res)
 data_long_exp_DDMA_C_res <- rbind(data_long_exp_DDMA_C_res, data_long_exp_DDMA4_C_res)
 
 p9 <- ggplot(data_long_exp_DDMA4_C_res, aes(x=ID2, y = value, group= round(ID2/2))) + 
   geom_boxplot()
 ggsave("DDMA_res_box.png", plot = p2, width = 15)

################################### with median

 #with median for DDMA2
 data_long_exp_DDMA2_AG <- data_long_exp_DDMA2 %>% group_by(weeknow, variable) %>% summarise(Median = median(as.numeric(value), na.rm = T))
 data_long_exp_DDMA2_AG$variableID <- gsub("_[0-9]*$", "", data_long_exp_DDMA2_AG$variable)
 data_long_exp_DDMA2_AG$run_number <- gsub("_|[a-z]*| ", "", data_long_exp_DDMA2_AG$variable)
 data_long_exp_DDMA2_AG <- merge(data_long_exp_DDMA2_AG, data_set_DDMA3, by = "run_number", all.x = T)
 
 data_long_exp_DDMA2_AG$Policy_Label <- with(data_long_exp_DDMA2_AG,
                                             paste(
                                               paste("Policy:", Policy, sep = ""),   
                                               paste("DDMA:", Lever_power_DDMA, sep = ""),
                                               paste("SDMA:", Lever_power_SDMA, sep = ""),
                                               paste("KC:", Lever_power_KC, sep = ""),
                                               sep = " "))
 
 nPol <- length(unique(data_long_exp_DDMA2_AG$Policy_Label))
 getPalette = colorRampPalette(brewer.pal(9, "Set1"))
 data_long_exp_DDMA2_AG_res <- data_long_exp_DDMA2_AG %>% filter(variableID == "resilience") %>%select(weeknow, variable, Median, Policy_Label)
 data_long_exp_DDMA2_AG_res$weeknow <- as.numeric(data_long_exp_DDMA2_AG_res$weeknow)
 
 plot1 <-  ggplot(data_long_exp_DDMA2_AG_res, aes(x = weeknow, y = Median, color = Policy_Label)) + 
   geom_point(alpha = 0) + 
   stat_smooth(aes(x = weeknow, y = Median), method = "lm",
               formula = y ~ poly(x, degree = 20), se = FALSE) +
   theme(legend.text=element_text(size=8), legend.title=element_text(size=10))+ 
   guides(color=guide_legend(title="Policy")) + 
   scale_x_continuous(breaks = 0:104, name = "Week") + 
   scale_y_continuous(breaks = seq(-1, 1, by = 0.1), name = "Median of Resilience") + 
   scale_color_manual(values = getPalette(nPol)) + 
   ggtitle("Simulation for DDMA power = 3 ")
 ggsave("DDMA2_policies.png", plot = plot1, width = 15)
 
## with median DDMA3
data_long_exp_DDMA3_AG <- data_long_exp_DDMA3 %>% group_by(weeknow, variable) %>% summarise(Median = median(as.numeric(value), na.rm = T))
data_long_exp_DDMA3_AG$variableID <- gsub("_[0-9]*$", "", data_long_exp_DDMA3_AG$variable)
data_long_exp_DDMA3_AG$run_number <- gsub("_|[a-z]*| ", "", data_long_exp_DDMA3_AG$variable)
data_long_exp_DDMA3_AG <- merge(data_long_exp_DDMA3_AG, data_set_DDMA3, by = "run_number", all.x = T)

data_long_exp_DDMA3_AG$Policy_Label <- with(data_long_exp_DDMA3_AG,
                                            paste(
                                              paste("Policy:", Policy, sep = ""),   
                                              paste("DDMA:", Lever_power_DDMA, sep = ""),
                                              paste("SDMA:", Lever_power_SDMA, sep = ""),
                                              paste("KC:", Lever_power_KC, sep = ""),
                                              sep = " "))

nPol <- length(unique(data_long_exp_DDMA3_AG$Policy_Label))
getPalette = colorRampPalette(brewer.pal(9, "Set1"))
data_long_exp_DDMA3_AG_res <- data_long_exp_DDMA3_AG %>% filter(variableID == "resilience") %>%select(weeknow, variable, Median, Policy_Label)
data_long_exp_DDMA3_AG_res$weeknow <- as.numeric(data_long_exp_DDMA3_AG_res$weeknow)
#data_long_exp_DDMA2_AG_env <- data_long_exp_DDMA2_AG_env %>% filter(Policy_Label == "Policy:1 DDMA:2 SDMA:2 KC:2")

plot2 <-  ggplot(data_long_exp_DDMA3_AG_res, aes(x = weeknow, y = Median, color = Policy_Label)) + 
  geom_point(alpha = 0.2) + 
  stat_smooth(aes(x = weeknow, y = Median), method = "lm",
              formula = y ~ poly(x, degree = 20), se = FALSE) +
  theme(legend.text=element_text(size=8), legend.title=element_text(size=10))+ 
  guides(color=guide_legend(title="Policy")) + 
  scale_x_continuous(breaks = 0:104, name = "Week") + 
  scale_y_continuous(breaks = seq(-1, 1, by = 0.1), name = "Median of resilience") + 
  scale_color_manual(values = getPalette(nPol)) + 
  ggtitle("Simulation for DDMA power = 3 ")
ggsave("DDMA3_policies.png", plot = plot2, width = 15)


#with median for DDMA 4

data_long_exp_DDMA4_AG <- data_long_exp_DDMA3 %>% group_by(weeknow, variable) %>% summarise(Median = median(as.numeric(value), na.rm = T))
data_long_exp_DDMA4_AG$variableID <- gsub("_[0-9]*$", "", data_long_exp_DDMA4_AG$variable)
data_long_exp_DDMA4_AG$run_number <- gsub("_|[a-z]*| ", "", data_long_exp_DDMA4_AG$variable)
data_long_exp_DDMA4_AG <- merge(data_long_exp_DDMA4_AG, data_set_DDMA4, by = "run_number", all.x = T)

data_long_exp_DDMA4_AG$Policy_Label <- with(data_long_exp_DDMA4_AG,
                                            paste(
                                              paste("Policy:", Policy, sep = ""),   
                                              paste("DDMA:", Lever_power_DDMA, sep = ""),
                                              paste("SDMA:", Lever_power_SDMA, sep = ""),
                                              paste("KC:", Lever_power_KC, sep = ""),
                                              sep = " "))

nPol <- length(unique(data_long_exp_DDMA4_AG$Policy_Label))
getPalette = colorRampPalette(brewer.pal(9, "Set1"))
data_long_exp_DDMA4_AG_res <- data_long_exp_DDMA4_AG %>% filter(variableID == "resilience") %>%select(weeknow, variable, Median, Policy_Label)
data_long_exp_DDMA4_AG_res$weeknow <- as.numeric(data_long_exp_DDMA4_AG_res$weeknow)

plot3 <-  ggplot(data_long_exp_DDMA4_AG_res, aes(x = weeknow, y = Median, color = Policy_Label)) + 
  geom_point(alpha = 0.2) + 
  stat_smooth(aes(x = weeknow, y = Median), method = "lm",
              formula = y ~ poly(x, degree = 20), se = FALSE) +
  theme(legend.text=element_text(size=8), legend.title=element_text(size=10))+ 
  guides(color=guide_legend(title="Policy")) + 
  scale_x_continuous(breaks = 0:104, name = "Week") + 
  scale_y_continuous(breaks = seq(-1, 1, by = 0.1), name = "Median of resilience") + 
  scale_color_manual(values = getPalette(nPol)) + 
  ggtitle("Simulation for DDMA power = 4 ")
ggsave("DDMA4_policies.png", plot = plot3, width = 15)

# # Statistical Analysis - Step 3 

# # Regression analysis on relationship between main variables and resilience.  

policyDDMA2_tot <- data_long_exp_DDMA2_AG_res %>% 
  group_by(Policy_Label) %>% 
  summarise(meanres  = mean(Median, na.rm = T)) %>% 
  arrange(desc(meanres))

policyDDMA3_tot <- data_long_exp_DDMA3_AG_res %>% 
  group_by(Policy_Label) %>% 
  summarise(meanres  = mean(Median, na.rm = T)) %>% 
  arrange(desc(meanres))

policyDDMA4_tot <- data_long_exp_DDMA4_AG_res %>% 
  group_by(Policy_Label) %>% 
  summarise(meanres  = mean(Median, na.rm = T)) %>% 
  arrange(desc(meanres))

data_TotPolicy <- subset(data_long_exp_DDMA2_AG, Policy_Label %in% policyDDMA2_tot$Policy_Label)
varAnalysis <- colnames(data_TotPolicy)
data_TotPolicy <- rbind(data_TotPolicy, 
                        subset(data_long_exp_DDMA3_AG, Policy_Label %in% policyDDMA3_tot$Policy_Label, select =  varAnalysis), 
                        subset(data_long_exp_DDMA4_AG, Policy_Label %in% policyDDMA4_tot$Policy_Label, select = varAnalysis))

data_TotPolicy$Policy_Label_2 <- with(data_TotPolicy,
                                      paste(
                                        paste("Policy:", Policy, sep = ""),   
                                        paste("DDMA:", Lever_power_DDMA, sep = ""),
                                        paste("SDMA:", Lever_power_SDMA, sep = ""),
                                        paste("KC:", Lever_power_KC, sep = ""),
                                        sep = " "))

data_OnPolicy_garbage_res <- data_TotPolicy %>% group_by(Policy_Label_2, weeknow, variableID, Lever_power_DDMA, Lever_power_KC, Lever_power_SDMA) %>% summarise(meanVar = mean(Median))


data_OnPolicy_garbage_res <- dcast(data_OnPolicy_garbage_res, weeknow + Policy_Label_2 + Lever_power_DDMA + Lever_power_KC +  Lever_power_SDMA ~ variableID)

#colnames(data_OnPolicy_garbage_env)[colnames(data_OnPolicy_garbage_env) %in% c("info_value", "social_capacity", "vulnerability_info", "forecast_info", "technical_capcity", "opportunistic", "initiative_members", "increment_energy")] <- c("info_value", "social_capacity", "vulnerability_info", "forecast_info", "technical_capcity", "opportunistic", "initiative_members", "increment_energy")
#data_OnPolicy_garbage_pls_2 <- subset(data_OnPolicy_garbage_pls, Policy_Label_2 == "PoOf:4 Ini:10 Co_Wo:2 Gar:5 Expense:80")

data_OnPolicy_garbage_eres <- na.omit(data_OnPolicy_garbage_res)
lm_model <- lm(resilience ~ opportunistic + increment_energy + as.factor(Lever_power_DDMA) + as.factor(Lever_power_SDMA) + 
                 as.factor(Lever_power_KC), data =  data_OnPolicy_garbage_res)
anova(lm_model)
summary(lm_model)

## Top policies
policyDDMA2_top <- data_long_exp_DDMA2_AG_res %>% 
  group_by(Policy_Label) %>% 
  summarise(meanres  = mean(Median, na.rm = T)) %>% 
  arrange(desc(meanres)) %>% filter(meanres > 0.3)

policyDDMA3_top <- data_long_exp_DDMA3_AG_res %>% 
  group_by(Policy_Label) %>% 
  summarise(meanres  = mean(Median, na.rm = T)) %>% 
  arrange(desc(meanres)) %>% filter(meanres > 0.3)

policyDDMA4_top <- data_long_exp_DDMA4_AG_res %>% 
  group_by(Policy_Label) %>% 
  summarise(meanres  = mean(Median, na.rm = T)) %>% 
  arrange(desc(meanres)) %>% filter(meanres < 0.3)

data_OnTopPolicy <- subset(data_long_exp_DDMA2_AG, Policy_Label %in% policyDDMA2_top$Policy_Label)
varAnalysis <- colnames(data_OnTopPolicy)
data_OnTopPolicy <- rbind(data_OnTopPolicy, 
                          subset(data_long_exp_DDMA3_AG, Policy_Label %in% policyDDMA3_top$Policy_Label, select =  varAnalysis), 
                          subset(data_long_exp_DDMA4_AG, Policy_Label %in% policyDDMA4_top$Policy_Label, select = varAnalysis))

data_OnTopPolicy$Policy_Label_2 <- with(data_OnTopPolicy,
                                        paste(
                                          paste("Policy:", Policy, sep = ""),   
                                          paste("DDMA:", Lever_power_DDMA, sep = ""),
                                          paste("SDMA:", Lever_power_SDMA, sep = ""),
                                          paste("KC:", Lever_power_KC, sep = ""),
                                          
                                          sep = " "))

data_OnTopPolicy_res <- subset(data_OnTopPolicy, variableID == "resilience")
#data_OnTopPolicy %>% group_by(Lever_power_KC) %>% summarise(meanExpense = mean(economic_dimension))
#data_OnTopPolicy_eco <- subset(data_OnTopPolicy, variableID == "environmental_dimension")

nPol <- length(unique(data_OnTopPolicy$Policy_Label))
getPalette = colorRampPalette(brewer.pal(9, "Set1"))

# ggplot(data_OnTopPolicy_res, aes(x = weeknow, y = Median, color = factor(Lever_power_KC))) + 
#   geom_point(alpha = 0.3) + 
#   stat_smooth(aes(x = as.numeric(weeknow), y = Median), method = "lm",
#               formula = y ~ poly(x, 25), se = FALSE) +
#   theme(legend.text=element_text(size=8), legend.title=element_text(size=10), axis.text.x = element_text(size=6, angle = 90))+ 
#   guides(color=guide_legend(title="Policy")) + 
#   scale_y_continuous(breaks = seq(0, 100, by = 10), name = "Median of env_dimension") + 
#   guides(color=guide_legend(title="power for KC")) + 
#   ggtitle("Results Top policies - Analysis on power allocated to KC")
# ggsave("Power allocate to KCS top policies.png", width = 20)

data_OnTopPolicy_res$weeknow <- as.numeric(data_OnTopPolicy_res$weeknow)
plot_top <- ggplot(data_OnTopPolicy_res, aes(x = weeknow, y = Median, color = Policy_Label_2)) + 
  geom_point(alpha = 0.1) + 
  stat_smooth(aes(x = as.numeric(weeknow), y = Median), method = "lm",
              formula = y ~ poly(x, 15), se = FALSE) +
  theme(legend.text=element_text(size=8), legend.title=element_text(size=10), axis.text.x = element_text(size=6, angle = 90))+ 
  guides(color=guide_legend(title="Policy")) + 
  scale_x_continuous(breaks = 0:104, name = "Week") + 
  scale_y_continuous(breaks = seq(-1, 1, by = 0.1), name = "Median of resilience") + 
  guides(color=guide_legend(title="Top Policies")) + 
  scale_color_manual(values = getPalette(nPol)) + 
  ggtitle("Results Top policies")
ggsave("Results_TopPolicies.png", width = 20)


#### try box plot of the top-top policies
Policy <- subset(data_OnTopPolicy, variableID %in% c("resilience"))
Policy <- Policy %>% group_by(Policy_Label_2, weeknow, variableID) %>% summarise(meanVar = mean(Median))
Policy <- dcast(Policy, weeknow + Policy_Label_2 ~ variableID)

boxplot(resilience ~Policy_Label_2 ,Policy )
ggplot(data_OnTopPolicy_res, aes(x = Policy_Label_2, y = resilience)) +
  geom_boxplot() + 
  theme(axis.text.x = element_text(size=1, angle = 90)) + 
  ggtitle("Boxplot Top policies")
ggsave("Boxplot.png")

unique(data_OnTopPolicy_res$Policy_Label_2)



