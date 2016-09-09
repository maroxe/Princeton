rgb2gray=function(X){
	return(0.2989*X[,,1]+0.587*X[,,2]+0.114*X[,,3])
}

crop.r=function(X, h, w){
	h1=dim(X)[1]
	w1=dim(X)[2]
	x1=sample(1:(w1-w+1),1)
	y1=sample(1:(h1-h+1),1)
	return(X[(y1:(y1+h-1)), (x1:(x1+w-1))])
}


crop.c=function(X, h, w){
	h1=dim(X)[1]
	w1=dim(X)[2]
	h.margin=floor((h1-h)/2)
	w.margin=floor((w1-w)/2)
	x1=w.margin+1
	y1=h.margin+1
	return(X[(y1:(y1+h-1)), (x1:(x1+w-1))])
}

hog=function(xgrad, ygrad, hn, wn, an){
	h=dim(xgrad)[1]
	w=dim(xgrad)[2]
	h1=h/hn
	w1=w/wn
	xr=(1:wn)*w1
	xl=xr-(w1-1)
	yd=(1:hn)*h1
	yu=yd-(h1-1)
	theta=ifelse(ygrad>0, acos(xgrad/sqrt(xgrad^2+ygrad^2)), -acos(xgrad/sqrt(xgrad^2+ygrad^2)))
	angle=c()
	for (i in 1:hn){
		for (j in 1:wn){
			angle=c(angle, hist(as.vector(theta[yu[j]:yd[j], xl[i]:xr[i]])+pi, breaks=seq(from=0, to=2*pi, by=2*pi/an), plot=F)$counts/(h1*w1))
		}
	}
	return(angle)
}

grad=function(X, h, w, pic){
	X1=crop.c(X, h+2, w+2)
	xgrad=(X1[-c(1,h+2), -c(1, 2)]-X1[-c(1,h+2), -c(w+1,w+2)])/2
	ygrad=(X1[-c(h+1,h+2), -c(1,w+2)]-X1[-c(1, 2), -c(1, w+2)])/2
	if (pic==TRUE){
		plot(c(),c(), asp=1, xlim=c(0,70), ylim=c(0,130), xlab="X", ylab="Y")
		for (i in 1:h){
			for (j in 1:w){
				arrows(x0=j, y0=h+1-i, x1=j+xgrad[i,j]*5, y1=h-i+1+ygrad[i,j]*5, length=0.01)
			}
		}
	}
	return(list("xgrad"=xgrad, "ygrad"=ygrad))
}
