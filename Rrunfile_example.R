#setwd("C:/Users/Janine/Repositories/Rcall")
library(R.matlab)
library(limma)


###  cmds  ###
dat <- voom(dat, grp)
fit <- lmFit(dat,design=model.matrix(~1+grp))
fit <- eBayes(fit)
p <- fit$p.value
top <- topTable(fit)
pdf("Volcano.pdf", pointsize=18,compress=FALSE)
volcanoplot(fit,coef=2,highlight=2)
dev.off()

