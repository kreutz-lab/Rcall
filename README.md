# Rcall: Calling R from MATLAB
R and Matlab are two high-level scientific programming languages which are frequently applied
in computational biology. To extend the wide variety of available and approved implementations, we present
the Rcall interface which runs in MATLAB and provides direct access to methods and software packages
implemented in R. Rcall involves passing the relevant data to R, executing the specified R commands
and forwarding the results to MATLAB for further use. The evaluation and conversion of the basic data
types in R and MATLAB are provided. Due to the easy embedding of R facilities, Rcall greatly extends the
functionality of the MATLAB programming language.

Rcall is implemented in MATLAB and Octave and runs on Linux, Windows and macOS.

## Installation
[![View Rcall on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://de.mathworks.com/matlabcentral/fileexchange/104945-rcall)

or
```
git clone https://github.com/kreutz-lab/Rcall.git
```
or
```
github install kreutz-lab/Rcall
```
Add the repository file path to your Matlab search path by addpath.m or by Home -> Set Path -> Add Folder.

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

## Finding Errors
Here, strategies are mentioned to find errors, i.e. to resolve problems occurring when trying to execute R commands from matlab.
* Check whether all packages that you try to use are installed in R
* Check local files: If Rcall does not terminate properly, files indicating the problem might be available in your working directory. Inspect them and/or try to execute them directly in R.
* If you changed the .Rprofile file, this can cause problems when it cannot be executed when R is starting. However, if R runs properly, this is also not an issue for Rcall
* Check the global variable RCALL in Matlab. This variable contains the code you execute.

## License

BSD 3-Clause License

Copyright (c) 2022, Janine Egert and Clemens Kreutz
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Author
Clemens Kreutz and Janine Egert

Institute of Medical Biometry and Statistics, 
Faculty of Medicine and Medical Center – University of Freiburg, Germany

https://www.uniklinik-freiburg.de/imbi-en/msb.html
ckreutz at imbi.uni-freiburg.de
egert at imbi.uni-freiburg.de
