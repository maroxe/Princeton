setwd('~/Documents/MS')
library(xts)
library(reshape2)
library(ggplot2)

data <- read.csv('price.csv')
data$date <- as.Date(as.character(data$date), "%Y%m%d")

dates <- read.csv('dates.csv')
dates <- lapply(dates, function(x) as.Date(as.character(x[!is.na(x)]), '%Y%m%d'))

price_plot <- ggplot(melt(data[,c(1, sort(sample(2:100, 10)))], id.vars='date'), 
       aes(x=date, y=value, group=variable, color=variable)) +
  geom_line()
# add FOMC
for(col in 1:3) {
price_plot <- price_plot + 
  geom_vline(xintercept=as.numeric(dates[[col]]), 
             linetype=4, colour=col) 
}
load.xts <- function (filename) {
data <- read.csv(filename)
xts(data[,-1], order.by=as.Date(as.character(data[,1]), '%Y%m%d'))
}

prices <- load.xts('price.csv')
macro <- load.xts('macro.csv')
macro$Value <- as.numeric(macro$Value)
macro <- macro[!is.na(macro$Value)]
ggplot(macro,
       aes(x=index(macro), y=Value, group = Index.Name, color=Index.Name)) +
  facet_wrap(~Index.Name, scale="free") +
  geom_point() + geom_line()

dates <- read.csv('dates.csv')
dates <- lapply(dates, function(x) as.Date(as.character(x[!is.na(x)]), '%Y%m%d'))
melted = melt(dates)
ggplot(data=melted, 
       aes(y = L1, x = value, group=L1, color=L1)
       ) + 
  geom_point()

  