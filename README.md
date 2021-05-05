# Rcall
R function interface for Matlab. See also the [Rcall wiki](https://github.com/kreutz-lab/Rcall/wiki).

## Installation
Clone or download repository.

Add the repository file path to your Matlab search path (e.g. by addpath.m)

## Short Example

```
Rinit('limma')
load arrhythmia; Y = [ones(size(Y,1),1) Y];
Rpush('X',X','Y',Y) 
Rrun('fit <- lmFit(scale(X),Y)') 
fit = Rpull('fit');
Rclear
```
