
load arrhythmia
design = [ones(size(Y,1),1) Y];
Rinit({'limma','rrcovNA'});             % Define R packages
Rpush('data',X','design',design)             % Data to use in R
%Rrun('I <- impSeqRob(data)')            % Imputation
%Rrun('data <- I$xseq')
Rrun('fit <- lmFit(scale(data),design)')       % linear model
Rrun('fite <- eBayes(fit)')             % empirical Bayes statistics
Rrun('tiff("VolcanoArrythmia.tiff")')
Rrun('volcanoplot(fite)')
Rrun('dev.off()')
Rrun('tiff("ClusterArrythmia.tiff")')
Rrun('h <- heatmap(data,Rowv=NA,ColSideColors=rainbow(16)[cut(design[,2]),16)])')
[h,fite] = Rpull('h','fite');

Rclear