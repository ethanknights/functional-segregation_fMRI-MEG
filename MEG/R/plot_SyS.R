library(ggplot2)
library(MASS)
library(sfsmisc)


rm(list = ls()) # clears environment
cat("\f") # clears console
dev.off() # clears graphics device
graphics.off() #clear plots


#---- Setup ----#
# wd <- "/imaging/ek03/MVB/FreeSelection/MVB/R"
wd = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(wd)

# Roi Parameters
#descript_roisName = 'craddock'
descript_roisName = 'Schaefer_100parcels_7networks'
doOrthog = '1'

rawDir = sprintf('../data/computeSyS/ROIs-%s',descript_roisName)
outImageDir = sprintf('images/%s_doOrthog-%s',descript_roisName,doOrthog); dir.create(outImageDir, showWarnings = FALSE)

#---- Load Data ----#
rawD <- read.csv(file.path(rawDir,sprintf('SySTable_allBands_doOrthog-%s.csv',doOrthog)), header=TRUE,sep=",")
df = rawD

# Setup Age
#=======================================================================
df$Age0 = df$Age - mean(df$Age) #mean corrected
df$Age0z = scale(df$Age0) #zscored
#before
ggplot(df, aes(x=Age)) + 
  geom_histogram(aes(y=..density..), colour="black", fill="white")+
  geom_density(alpha=.2, fill="#FF6666")
#after
ggplot(df, aes(x=Age0)) + 
  geom_histogram(aes(y=..density..), colour="black", fill="white")+
  geom_density(alpha=.2, fill="#FF6666")
ggplot(df, aes(x=Age0z)) + 
  geom_histogram(aes(y=..density..), colour="black", fill="white")+
  geom_density(alpha=.2, fill="#FF6666")

df$Age0z2 <- poly(df$Age0z,2) #1st linear, 2nd quad

# RLM - delta
#=======================================================================
#Fancy age (corrected, quadratic) 
rlm_model <- rlm(delta ~ Age0z2,
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("Age0z21","Age0z22")) #age effect?
f.robftest(rlm_model, var="Age0z21") #linear
f.robftest(rlm_model, var="Age0z22") #quadratic

#Plot
p <- ggplot(df, aes(x = Age, y = delta))
p <- p + geom_point(shape = 21, size = 3, colour = "black", fill = "white", stroke = 2)
p <- p + stat_smooth(method = "lm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
#formatting
p <- p + 
  #ylim(0,400) +
  scale_x_continuous(breaks = round(seq(20, max(80), by = 20),1),
                     limits = c(15,90)) +
  theme_bw() + 
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.line = 
          element_line(colour = "black",size = 1.5), 
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=24))
ggsave(file.path(outImageDir,"SyS_delta.png"),
       width = 25, height = 25, units = 'cm', dpi = 300); p

# RLM - theta
#=======================================================================
#Fancy age (corrected, quadratic) 
rlm_model <- rlm(theta ~ Age0z2,
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("Age0z21","Age0z22")) #age effect?
f.robftest(rlm_model, var="Age0z21") #linear
f.robftest(rlm_model, var="Age0z22") #quadratic

#Plot
p <- ggplot(df, aes(x = Age, y = theta))
p <- p + geom_point(shape = 21, size = 3, colour = "black", fill = "white", stroke = 2)
p <- p + stat_smooth(method = "lm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
#formatting
p <- p + 
  #ylim(0,400) +
  scale_x_continuous(breaks = round(seq(20, max(80), by = 20),1),
                     limits = c(15,90)) +
  theme_bw() + 
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.line = 
          element_line(colour = "black",size = 1.5), 
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=24))
ggsave(file.path(outImageDir,"SyS_theta.png"),
       width = 25, height = 25, units = 'cm', dpi = 300); p

# RLM - alpha
#=======================================================================
#Fancy age (corrected, quadratic) 
rlm_model <- rlm(alpha ~ Age0z2,
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("Age0z21","Age0z22")) #age effect?
f.robftest(rlm_model, var="Age0z21") #linear
f.robftest(rlm_model, var="Age0z22") #quadratic

#Plot
p <- ggplot(df, aes(x = Age, y = alpha))
p <- p + geom_point(shape = 21, size = 3, colour = "black", fill = "white", stroke = 2)
p <- p + stat_smooth(method = "lm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
#formatting
p <- p + 
  #ylim(0,400) +
  scale_x_continuous(breaks = round(seq(20, max(80), by = 20),1),
                     limits = c(15,90)) +
  theme_bw() + 
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.line = 
          element_line(colour = "black",size = 1.5), 
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=24))
ggsave(file.path(outImageDir,"SyS_alpha.png"),
       width = 25, height = 25, units = 'cm', dpi = 300); p

# RLM - beta
#=======================================================================
#Fancy age (corrected, quadratic) 
rlm_model <- rlm(beta ~ Age0z2,
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("Age0z21","Age0z22")) #age effect?
f.robftest(rlm_model, var="Age0z21") #linear
f.robftest(rlm_model, var="Age0z22") #quadratic

#Plot
p <- ggplot(df, aes(x = Age, y = beta))
p <- p + geom_point(shape = 21, size = 3, colour = "black", fill = "white", stroke = 2)
#p <- p + stat_smooth(method = "lm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
#formatting
p <- p + 
  #ylim(0,400) +
  scale_x_continuous(breaks = round(seq(20, max(80), by = 20),1),
                     limits = c(15,90)) +
  theme_bw() + 
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.line = 
          element_line(colour = "black",size = 1.5), 
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=24))
ggsave(file.path(outImageDir,"SyS_beta.png"),
       width = 25, height = 25, units = 'cm', dpi = 300); p

# RLM - lGamma
#=======================================================================
#Fancy age (corrected, quadratic) 
rlm_model <- rlm(lGamma ~ Age0z2,
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("Age0z21","Age0z22")) #age effect?
f.robftest(rlm_model, var="Age0z21") #linear
f.robftest(rlm_model, var="Age0z22") #quadratic

#Plot
p <- ggplot(df, aes(x = Age, y = lGamma))
p <- p + geom_point(shape = 21, size = 3, colour = "black", fill = "white", stroke = 2)
p <- p + stat_smooth(method = "lm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
#formatting
p <- p + 
  #ylim(0,400) +
  scale_x_continuous(breaks = round(seq(20, max(80), by = 20),1),
                     limits = c(15,90)) +
  theme_bw() + 
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.line = 
          element_line(colour = "black",size = 1.5), 
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=24))
ggsave(file.path(outImageDir,"SyS_lGamma.png"),
       width = 25, height = 25, units = 'cm', dpi = 300); p

# RLM - broadband
#=======================================================================
#Fancy age (corrected, quadratic) 
rlm_model <- rlm(broadband ~ Age0z2,
                 data = df, psi = psi.huber, k = 1.345)
summary(rlm_model)
f.robftest(rlm_model, var=c("Age0z21","Age0z22")) #age effect?
f.robftest(rlm_model, var="Age0z21") #linear
f.robftest(rlm_model, var="Age0z22") #quadratic

#Plot
p <- ggplot(df, aes(x = Age, y = broadband))
p <- p + geom_point(shape = 21, size = 3, colour = "black", fill = "white", stroke = 2)
p <- p + stat_smooth(method = "lm", se = TRUE, fill = "grey60", formula = y ~ x, colour = "springgreen3", size = 3)
#p <- p + stat_smooth(method = "rlm", se = TRUE, fill = "grey60", formula = y ~ poly(x,2, raw = TRUE), colour = "springgreen3", size = 3)
#formatting
p <- p + 
  #ylim(0,400) +
  scale_x_continuous(breaks = round(seq(20, max(80), by = 20),1),
                     limits = c(15,90)) +
  theme_bw() + 
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.line = 
          element_line(colour = "black",size = 1.5), 
        axis.ticks = element_line(colour = "black",
                                  size = 1.5),
        text = element_text(size=24))
ggsave(file.path(outImageDir,"SyS_broadband.png"),
       width = 25, height = 25, units = 'cm', dpi = 300); p