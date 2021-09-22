% Initialize Rcall
Rinit('limma')

% Pass test data to R
load('pasilla_count_noMM.mat')
Rpush('dat',geneCountTable{:,3:6},'grp',[0;0;1;1])

% Define R commands
% Rread('Rapplication.R')
%Rrun('dat <- dat[filterByExpr(dat,grp),]')
%Rrun('dat <- dat*calcNormFactors(dat)')
Rrun('dat <- voom(dat, grp)')
Rrun('fit <- lmFit(dat,design=model.matrix(~1+grp))')       		%# fit linear model
Rrun('fit <- eBayes(fit)')											%# empirical Bayes statistics
Rrun('p <- fit$p.value')
Rrun('top <- topTable(fit)')
Rrun('pdf("Volcano.pdf", pointsize=18,compress=FALSE)')
Rrun('volcanoplot(fit,coef=2,highlight=2)')							%&& # log-fold changes vs log-odds
Rrun('dev.off()')

% Evaluate R commands and get variables
[top, p] = Rpull('top','p');

% Clear all temporary variables and files
Rclear
