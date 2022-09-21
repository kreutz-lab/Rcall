
%% Example 1 - Linear Model

Rinit

% Pass test data to R
load('hospital')
tbl = table(hospital.Sex,hospital.BloodPressure(:,1),hospital.Age,hospital.Smoker, hospital.Weight, ...
    'VariableNames',{'Sex','BloodPressure','Age','Smoker','Weight'});
%tbl = table(dat(:,1),dat(:,4),'VariableNames',{'grp1','grp2'});
Rpush('tbl',tbl)

%% Matlab
fit = fitlm(tbl,'BloodPressure~Age+Smoker+Weight');
cm = fit.Coefficients.Estimate

%% R
Rrun('fit <- lm(BloodPressure~Age+Smoker+Weight, tbl)')       		%# fit linear model
Rrun('cr <- fit$coefficients')											%# empirical Bayes statistics
%Rrun('p <- fit$p.value')

% Evaluate R commands and get variables
cr = Rpull('cr')



%% Example 2 - Linear Model with limma

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

%% Example 2.2 - Cluster analysis

Rrun('options(bitmapType="cairo")')
Rrun('tiff("ClusterArrhythmia.tiff")')
Rrun('h <- heatmap(dat,row=NA)')
Rrun('cl <- h$colInd')
Rrun('dev.off()')
cl = Rpull('cl');

% Clear all temporary variables and files
Rclear