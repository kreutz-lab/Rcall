%   Rrun(cmd)
% 
%   cmd     a command line in R syntax
% 
%   This function only collects R commands. They are executed if Rpull is called next time.
% 
%   This function requires the R.matlab package that has to be installed in R
%   e.g. via install.packages("R.matlab")
%
% Rcall: An R interface for MATLAB.
% Copyright (C) 2022, Janine Egert and Clemens Kreutz
% see LICENSE for more details

function Rrun(cmd)

global OPENR
if ~isfield(OPENR,'cmd')
    OPENR.cmd = {cmd};
else
    OPENR.cmd{end+1} = cmd;
end



