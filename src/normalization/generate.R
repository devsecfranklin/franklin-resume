arg = commandArgs(TRUE)

samples = rep(NA, 100000)
for ( i in 1:100000 ){ samples[i] = mean(rexp(40, 0.2)) }

jpeg(paste('plots/', arg, '.jpg', sep=""))
hist(samples, main="", prob=T, col="darkred")
lines(density(samples), col="darkblue", lwd=3)
dev.off()
