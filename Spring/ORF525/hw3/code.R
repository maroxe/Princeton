set.seed(525)

setwd('~/Documents/Princeton/ORF525/hw3/')

library(dplyr)
library(ggplot2)
library(rpart)
library(rpart.plot)

data <- tbl_df(read.csv('MLB2008.csv'))

data.train <- data[1:154, ]
data.test <- data[155:dim(data)[1], ]

dim(data)
dim(data.train)
dim(data.test)

colnames(data)[1:10]

ggplot(data, aes(x=Record_ID., y=SALARY)) + geom_point()

feature.names <- colnames(data)[6:length(data)]
formula <- as.formula(paste('SALARY ~', paste(feature.names, collapse='+')))
rpart.model <- rpart(formula, data=data.train, method='anova')
mse <- data.frame(
    prune=0,
    train=norm(predict(rpart.model) - data.train$SALARY, type="2"), 
    test=norm(predict(rpart.model, data.test) - data.test$SALARY, type="2")
)

prp(rpart.model)

for(prune in (1:100 / 100.)) {
    rpart.model.prune <- prune(rpart.model, cp=prune)
    mse <- rbind(mse,
                 c(  
                     prune=prune,
                     train=norm(predict(rpart.model.prune) - data.train$SALARY, type="2"), 
                     test=norm(predict(rpart.model.prune, data.test) - data.test$SALARY, type="2")
                 ))
}


ggplot(mse) + 
geom_point(aes(x = prune, y = train, color='train')) + geom_line(aes(x = prune, y = train, color='train')) + 
geom_point(aes(x = prune, y = test, color='test')) +
xlab("prune cp") + ylab("MSE")








mse.forest <-  data.frame(B=integer(), train=numeric(), test=numeric()) 
for(B in 10:100) {
    randomForest.model <- randomForest(formula, data=data.train, ntree=B)
    mse.forest <- rbind(mse.forest,
                        data.frame(  
                            B=B,
                            train=norm(predict(randomForest.model, data.train) - data.train$SALARY, type="2"), 
                            test=norm(predict(randomForest.model, data.test) - data.test$SALARY, type="2")
                        ))
}
ggplot(mse.forest) + geom_point(aes(x=B, y=train))

str(data.train[,5:dim(data)[2]])




randomForest.model <- randomForest(x=data.train[,6:dim(data)[2]], y=data.train$SALARY, ntree=12)

randomForest.model





