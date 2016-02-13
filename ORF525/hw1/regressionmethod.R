#inline mode @ https://stat.ethz.ch/pipermail/ess-help/attachments/20131118/7c7e35ea/attachment.pl
## pdf("test1.pdf")
## dev.control(displaylist = "enable")
## plot(1:0)
## dev.copy(pdf, "test2.pdf")
## dev.off()
## dev.off() # finished


train.data <- read.csv('data/train.data.csv')
test.data <- read.csv('data/test.data.csv')

train.data$zipcode <- as.factor(train.data$zipcode)
test.data$zipcode <- as.factor(test.data$zipcode)

# Linear regression
linear.model <- lm(price ~ bedrooms + bathrooms + sqft_living + sqft_lot, data=train.data)
r2.train <- mean(residuals(linear.model)**2)
r2.test <- mean((predict(linear.model, test.data) - test.data$price)**2)

# Linear regression with zip code
# Linear regression
linear.model.with.zipcode <- lm(price ~ bedrooms + bathrooms + sqft_living + sqft_lot + zipcode, data=train.data)
r2.train.with.zipcode <- mean(residuals(linear.model.with.zipcode)**2)
r2.test.with.zipcode <- mean((predict(linear.model.with.zipcode, test.data) - test.data$price)**2)

# glmnet
library(glmnet)
feature.names <- colnames(train.data)[5:length(train.data)]
#feature.names <- feature.names[feature.names != "zipcode"]
formula <- as.formula(paste('~', paste(feature.names, collapse='+')))

X.train <- model.matrix(formula, data=train.data)
y.train <- train.data$price

X.test <- model.matrix(formula, data=test.data)
y.test <- test.data$price

lasso.model <- glmnet(X.train, y.train, alpha=0)
ridge.model <- glmnet(X.train, y.train, alpha=1)

# Plot lasso / ridge path
plot.path <- function(fit, ...) {
    L <- length(fit$lambda)
    y.train <- fit$beta[, L]
    labs <- names(y.train)
    par(mar=c(4.5,4.5,1,4))
    plot(fit, xvar="norm", label=T)
    vnat=coef(fit)
    vnat=vnat[-1,ncol(vnat)]
    axis(4, at=vnat,line=-.5,label=labs,las=1,tick=FALSE, cex.axis=0.5) 
}

do.cv <- function(alpha) {
    model <- glmnet(X.train, y.train, alpha=alpha)
    cv <- cv.glmnet(X.train,y.train, nfolds=5, alpha=alpha)
    l1.norm.min = sum(abs(coef(cv, s='lambda.min')[-1]))
    plot(model)
    abline(v=l1.norm.min, lty.train=2)
    text(x=l1.norm.min*0.95, y.train=2e5, label="best coefficient")
}
do.cv(0)

evaluate.on.test <- function(alpha){
    model <- glmnet(X.train, y.train, alpha=alpha)
    cv <- cv.glmnet(X.train,y.train, nfolds=5, alpha=alpha)
    pred <- predict(cv, X.test, s="lambda.min")
    mse <- mean((pred - y.test)^2)
    print(paste("MSE = ", mse))
}

evaluate.on.test(0)
evaluate.on.test(1)


# ----------------------------- Random forests -------------------------------
library(ggplot2)
library(maps)
library(zipcode)
library(randomForest)

state.map <- map_data('state', region = 'Washington')
data(zipcode)

areas.of.interest <- data.frame(zipcode=levels(train.data$zipcode))
areas.of.interest <- merge(areas.of.interest, zipcode, by.x='zipcode', by.y ='zip')
areas.of.interest$region <- substr(areas.of.interest$zipcode, 1, 1)
num.cities <- length(unique(areas.of.interest$city)) #24

# plot map
g = ggplot(data=areas.of.interest)
g = g + geom_polygon( data=state.map, aes(x=long, y=lat,group=group),colour="black", fill="white" )
g = g + geom_point(aes(x=longitude, y=latitude, colour=city)) 
g = g + theme_bw() 
g = g + labs(x=NULL, y=NULL)

zip.to.city <- function(df) {
    city <- merge(df, zipcode, by.x='zipcode', by.y='zip')$city
    as.factor(city)
}
train.data$city <- zip.to.city(train.data)
test.data$city <- zip.to.city(test.data)



formula <- price ~ sqft_living + sqft_lot + bedrooms + bathrooms + floors + city
random.forest.model <- randomForest(formula, data=train.data)






