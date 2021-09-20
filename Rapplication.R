setwd("C:/Users/Janine/Repositories/Rcall")
tryCatch({

### Load packages ###
tryCatch({
 library(R.matlab)
},error=function(e) {
 tryCatch({
  install.packages("R.matlab")
  library(R.matlab)
 },error=function(e) {
  sink("Rerrorinstalltmp.txt")
  cat("Error in Rrun.R : Installation of package R.matlab was not successfull. Do package installation in R beforehand.", conditionMessage(e))
  sink()
})})
tryCatch({
 library(limma)
},error=function(e) {
 tryCatch({
  install.packages("limma")
  library(limma)
 },error=function(e) {
  sink("Rerrorinstalltmp.txt")
  cat("Error in Rrun.R : Installation of package limma was not successfull. Do package installation in R beforehand.", conditionMessage(e))
  sink()
})})

### Load data ###
rm(list=ls())
if(!file.exists("Rrun.Rdata"))
    save.image(file="Rrun.Rdata")
data_Rpush <- readMat("Rpush.mat")
attach(data_Rpush)

###  cmds  ###
dat <- voom(dat, grp)
fit <- lmFit(dat,design=model.matrix(~1+grp))
fit <- eBayes(fit)
p <- fit$p.value
top <- topTable(fit)
pdf("Volcano.pdf", pointsize=18,compress=FALSE)
volcanoplot(fit,coef=2,highlight=2)
dev.off()

### save ###
varnames <- unique(setdiff(ls(),c("data_Rpush","tmp","cellstrs")))
save(file="Rrun.Rdata",list=varnames)

### error output ###
},error=function(e) {
sink("Rerrortmp.txt")
cat("Error in Rrun.R :", conditionMessage(e))
sink() })
