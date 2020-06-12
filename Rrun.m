%   Rrun(cmd)
% 
%   cmd     a command line in R syntax
% 
%   This function only collects R commands. They are executed if Rpull or
%   Rpush is called next time.
% 
%   This function requires the R.matlab packages that has to be installed in R 
%   e.g. via 
%   install.packages("R.matlab")
%   install.packages("amap")

function Rrun(cmd)

global OPENR
if ~isfield(OPENR,'cmd')
    OPENR.cmd = {cmd};
else
    OPENR.cmd{end+1} = cmd;
end



