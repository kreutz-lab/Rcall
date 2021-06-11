# Rcall
R function interface for Matlab. See also the [Rcall wiki](https://github.com/kreutz-lab/Rcall/wiki).

## Installation
Clone or download the repository.

Add the repository file path to your Matlab search path by addpath.m or by Home -> Set Path -> Add Folder.

## Short Example

```
Rinit('limma')
load('TestData.mat')
Rpush('dat',dat,'grp',grp) 
Rrun('fit <- lmFit(dat,grp)') 
fit = Rpull('fit');
Rclear
```
See also Rexample.m or the [Rcall wiki](https://github.com/kreutz-lab/Rcall/wiki).
