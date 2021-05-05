# Rcall
R function interface for Matlab. See also the [Rcall wiki](https://github.com/kreutz-lab/Rcall/wiki).

## Installation
Clone or download repository
Add the repository file path to your Matlab search path (e.g. by addpath.m)

## Short Example

```
1 Rinit('limma')
2 load arrhythmia; Y = [ones(size(Y,1),1) Y];
3 Rpush('X',X','Y',Y) 
4 Rrun('fit <- lmFit(scale(X),Y)') 
11 fit = Rpull('fit');
12 Rclear
```
