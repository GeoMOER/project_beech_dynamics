rm(list=ls())

# ----- plotting results -----
# ----------------------------

library(ggplot2)
library(raster)
# ----- read data
setwd("F:/Uni/Geo/_MA/environmental_observations/data/moer-envobs/study_area/crop_area/Ergebnisse/")
linmod <- readRDS("linmod_amplitude_final.RDS")
# linmod <- readRDS("linmod_min_final.RDS")
# linmod <- readRDS("linmod_max_final.RDS")

# ----- prepare data for ggplot
df_res = as.data.frame(linmod)
rownames(linmod)
df = data.frame(t(linmod))
df$date = rownames(df)
dfl = reshape2::melt(df, id.vars = c("date"))

# ----- boxplot
ggplot(data = dfl[!dfl$date == "avg",], aes(x = variable, y = value)) + 
  geom_boxplot()

# ----- dodge position plot
ggplot(data = dfl[!dfl$date == "avg",], aes(x = date, y = value, fill = variable, group = variable)) +
  geom_bar(stat="identity", position = "dodge")


