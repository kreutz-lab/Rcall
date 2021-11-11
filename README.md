# Rcall: Calling R from MATLAB
R and Matlab are two high-level scientific programming languages which are frequently applied
in computational biology. To extend the wide variety of available and approved implementations, we present
the Rcall interface which runs in MATLAB and provides direct access to methods and software packages
implemented in R. Rcall involves passing the relevant data to R, executing the specified R commands
and forwarding the results to MATLAB for further use. The evaluation and conversion of the basic data
types in R and MATLAB are provided. Due to the easy embedding of R facilities, Rcall greatly extends the
functionality of the MATLAB programming language.

## Installation
1) Rcall is installed by cloning or downloading the 'Rcall' git repository, e.g. by
```
git clone https://github.com/kreutz-lab/Rcall.git
```
or
```
github install kreutz-lab/Rcall
```
2) Add the repository file path to your Matlab search path by addpath.m or by Home -> Set Path -> Add Folder.

## Short Example
To demonstrate the easy use of Rcall, here is a small example. First, Rcall is initialized by defining the R path, R libraries and the R libraries path. The variables are passed to R by the 'Rpush' command. R commands are defined by the 'Rrun' command. Within the 'Rpull' command the R code is executed and the defined variables are load in the Matlab workspace. For error prouning, make sure the R packages are properly installed or installed beforehand.
```
Rinit('limma')
load('TestData.mat')
Rpush('dat',dat,'grp',grp) 
Rrun('fit <- lmFit(dat,grp)') 
fit = Rpull('fit');
Rclear
```

For explanation of the input variables, the Rcall implementation and more application examples, see the [Rcall wiki](https://github.com/kreutz-lab/Rcall/wiki).
