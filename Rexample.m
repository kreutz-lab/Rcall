% Initialize Rcall
Rinit('limma')

% Pass test data to R
load('TestData.mat')
Rpush('dat',dat,'grp',grp)

% Define R commands
Rrun('fit <- lmFit(dat,design=model.matrix(~1+grp))')       		%# fit linear model
Rrun('fitBay <- eBayes(fit)')											%# empirical Bayes statistics
Rrun('p <- fitBay$p.value')
Rrun('pdf("Volcano.pdf", pointsize=18,compress=FALSE)')
Rrun('volcanoplot(fitBay,coef=2,highlight=2)')							%&& # log-fold changes vs log-odds
Rrun('dev.off()')

% Evaluate R commands and get variables
[fitM, p] = Rpull('fit','p');

% 2nd example: Cluster analysis
Rrun('options(bitmapType="cairo")')
Rrun('tiff("ClusterArrhythmia.tiff")')
Rrun('h <- heatmap(dat,row=NA)')
Rrun('cl <- h$colInd')
Rrun('dev.off()')
cl = Rpull('cl');

% Clear all temporary variables and files
Rclear
