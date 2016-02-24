train.data <- read.csv('data/train.data.csv')
test.data <- read.csv('data/test.data.csv')

train.data$zipcode <- as.factor(train.data$zipcode)
test.data$zipcode <- as.factor(test.data$zipcode)

# Linear regression
formula <- price ~ bedrooms + bathrooms + sqft_living + sqft_lot
linear.model <- lm(formula, data=train.data)
r2.train <- mean(residuals(linear.model)**2)
r2.test <- mean((predict(linear.model, test.data) - test.data$price)**2)

# Linear regression with zip code
formula <- update(formula,    ~ . + zipcode)
linear.model.with.zipcode <- lm(formula, data=train.data)
r2.train.with.zipcode <- mean(residuals(linear.model.with.zipcode)**2)
r2.test.with.zipcode <- mean((predict(linear.model.with.zipcode, test.data) - test.data$price)**2)

# glmnet
library(glmnet)
feature.names <- colnames(train.data)[5:length(train.data)]
#feature.names <- feature.names[feature.names != "zipcode"]
formula <- as.formula(paste('~', paste(feature.names, collapse='+')))
#formula <-  ~ bedrooms + bathrooms + price+ sqft_living + sqft_lot

X.train <- model.matrix(formula, data=train.data)[,-1] #drop intercept
y.train <- train.data$price

X.test <- model.matrix(formula, data=test.data)[,-1]
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

plot.path(ridge.model)

do.cv <- function(alpha) {
    model <- glmnet(X.train, y.train, alpha=alpha)
    cv <- cv.glmnet(X.train,y.train, nfolds=5, alpha=alpha)
    l1.norm.min = sum(abs(coef(cv, s='lambda.min')[-1]))

    par(mfrow=c(2,1))
    plot(model, xvar="norm")
    abline(v=l1.norm.min, lty=2)
    text(x=l1.norm.min*0.95, y=2e5, label="best coefficient")
    plot(cv)
    cv
}

ridge.model.cv <- do.cv(1)

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
library(forestFloor)

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
g

zip.to.city <- function(df) {
    city <- merge(df, zipcode, by.x='zipcode', by.y='zip')$city
    as.factor(city)
}
train.data$city <- zip.to.city(train.data)
test.data$city <- zip.to.city(test.data)



formula <- price ~ sqft_living + sqft_lot + bedrooms + bathrooms + floors + city
random.forest.model <- randomForest(formula, data=train.data)

varImpPlot(random.forest.model)

partialPlot(random.forest.model, train.data, "sqft_living")

importance(random.forest.model)

X = model.matrix(~ sqft_living + sqft_lot + bedrooms + bathrooms + floors + city, data=train.data)[,-1] #drop intercept
ff = forestFloor(rf.fit=random.forest.model, X = X, calc_np = FALSE,    # TRUE or FALSE both works, makes no difference
  binary_reg = FALSE  # takes no effect here when rfo$type="regression"
)

plot.partial.importance <- function(fit) {
    importanceOrder=order(-fit$importance)
    mynames=rownames(fit$importance)[importanceOrder]

    for (name in mynames) {
        print(name)


    }
}
    par(mfrow=c(2, 3), xpd=NA)
partialPlot(fit, train.data, x.var="sqft_living")
partialPlot(fit, train.data, x.var="bathrooms")
partialPlot(fit, train.data, x.var="sqft_lot")

# Convert donald trump to a dummmy variable understandable by glmnet
donald.trump <-  list(bedrooms=8, bathrooms=25, sqft_living=50000,sqft_lot=225000, floors=4, condition=10, grade=10,waterfront=1, view=4, sqft_above=37500, sqft_basement=12500, yr_built=1994,yr_renovated=2010, lat=47.627606, long=-122.242054, sqft_living15=5000,sqft_lot15=40000, zipcode98039=1)
trump.dummy <- 0*X.train[1,]
for(entry in names(donald.trump)) 
    trump.dummy[entry] <- donald.trump[entry]
trump.dummy <- t(unlist(trump.dummy))

house.donald.trump <- predict(ridge.model.cv, trump.dummy, s='lambda.min')










