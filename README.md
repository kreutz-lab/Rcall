# Rcall
R function interface for Matlab. See also the [Rcall wiki](https://github.com/kreutz-lab/Rcall/wiki).

## Installation
Clone or download repository.

Add the repository file path to your Matlab search path (e.g. by addpath.m)

## Short Example

```
Rinit('limma')
load('TestData.mat')
Rpush('dat',dat,'grp',grp) 
Rrun('fit <- lmFit(dat,grp)') 
fit = Rpull('fit');
Rclear
```
