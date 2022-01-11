% Rclear
%
% All temporary variables and files which were created by Rcall are deleted
%
% Rcall: An R interface for MATLAB.
% Copyright (C) 2022, Janine Egert and Clemens Kreutz
% see LICENSE for more details

function Rclear
warning('off','MATLAB:DELETE:FileNotFound');
% try
    delete('Rrun.R');
    delete('Rrun.Rout');
    delete('Rrun.rData');
    delete('Rrun.Rdata');
    
    delete('Rpull.mat');
    delete('Rpull.mat.tmp');
    delete('Rpull.Rdata');
    delete('Rpull.R');
    delete('Rpull.Rout');
    
    delete('Rpush.mat')
    delete('Rerrortmp.txt')
    delete('Rerrorinstalltmp.txt')
    delete('Rwarn.txt')
% end
warning('on','MATLAB:DELETE:FileNotFound');

