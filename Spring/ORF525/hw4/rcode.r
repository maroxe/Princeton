library(png)
library(kernlab)
source("functions.R")

crop <- function(img) crop.r(img, 160, 96)
take.grad <- function(img) grad(img, 128, 64, F)
take.hog <- function(grad.img) hog(grad.img$xgrad, grad.img$ygrad, 4, 4, 6)

plt.grad <- function(grad.img, h=128, w=64, ...) {
    plot(c(),c(), asp=1, xlim=c(0,70), ylim=c(0,130), xlab="X", ylab="Y", ...)
    for (i in 1:h){
        for (j in 1:w){
            arrows(x0=j, y0=h+1-i, x1=j+grad.img$xgrad[i,j]*5, y1=h-i+1+grad.img$ygrad[i,j]*5, length=0.01)
        }
    }
}

plt.gray <- function(img.gray, ...) image(t(img.gray)[, nrow(img.gray):1], col  = gray((0:32)/32), ...)


load.from.directory <- function(dir) {
    images = list()
    img <- sample(list.files(dir), size=1) 
    return(readPNG(file.path(dir, img)))
}

image.pos <- load.from.directory("pngdata/pos")
image.neg.uncropped <- load.from.directory("pngdata/neg")
image.neg.gray.uncropped <- rgb2gray(image.neg.uncropped)
image.pos.gray <- rgb2gray(image.pos)
image.neg.gray <- crop(image.neg.gray.uncropped)
grad.pos <- take.grad(image.pos.gray)
grad.neg <- take.grad(image.neg.gray)
hog.pos <- take.hog(grad.pos)
hog.neg <- take.hog(grad.neg)


setEPS()
postscript("neg.eps")
par(mfrow = c(2, 2))
x <- dim(image.neg.uncropped)[1]
y <- dim(image.neg.uncropped)[2]
plot(c(0, x), c(0, y), type = "n", xlab = "", ylab = "", main="original")
rasterImage(image.neg.uncropped, 0, 0, x, y)
plt.gray(image.neg.gray.uncropped, main="gray")
plt.gray(image.neg.gray, main="gray cropped")
plt.grad(grad.neg, main="grad")
dev.off()

postscript("pos.eps")
par(mfrow = c(2, 2))
plot(c(0, 1), c(0, 1), type = "n", xlab = "", ylab = "", main="original")
rasterImage(image.pos, 0, 0, 1, 1)
plt.gray(image.pos.gray, main="gray")
plt.grad(grad.pos, main="grad")
dev.off()




load.all.directory <- function(dir) {
    images = list()
    for(img in list.files(dir)) {
        images[[img]] <- readPNG(file.path(dir, img))
    }
    return(images)
}

feature.pos.img <- function(img) c(1, take.hog(take.grad(rgb2gray(img))))
feature.neg.img <- function(img) c(0, take.hog(take.grad(crop(rgb2gray(img)))))

pos.images <- load.all.directory("pngdata/pos")
neg.images <- load.all.directory("pngdata/neg")

data <- c(
    unname(lapply(pos.images, feature.pos.img)),
    unname(lapply(neg.images, feature.neg.img))
)
data <- sapply(data, identity)
df <- data.frame(t(data))
colnames(df) <- c("label", paste("F",1:96, sep='_'))
df$label <- as.factor(df$label)
df[1:3, 1:10]


# SVM
logspace <- function(s, e, n=100) 10^((1:n-1) / n * (e-s) + s)
C <- logspace(-4, 2, 100)
formula <- as.formula(paste("label", paste(colnames(df)[-1], collapse='+'), sep='~'))
cross.error <- sapply(C, function(c) {ksvm(formula, df, cross=10, C=c)@cross})
plot(log(C), cross.error, 'o')










