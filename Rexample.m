t = cputime;
Rinit({'limma'});             % Define R packages
load arrhythmia; Y = [ones(size(Y,1),1) Y];
Rpush('X',X','Y',Y)  

% Define R commands
Rrun('fit <- lmFit(scale(X),Y)')       		%# fit linear model
Rrun('fite <- eBayes(fit)')											%# empirical Bayes statistics
Rrun('tiff("VolcanoArrhythmia.tiff")')
Rrun('volcanoplot(fite)')							%&& # log-fold changes vs log-odds
Rrun('dev.off()')
Rrun('tiff("ClusterArrhythmia.tiff")')
Rrun('h <- heatmap(X,Rowv=NA,ColSideColors=rainbow(16)[cut(Y[,2],16)])')

% Evaluate R commands and get variables
[h,fite] = Rpull('h','fite');

Rclear
cputime-t