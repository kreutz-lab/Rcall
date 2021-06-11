% Rclear
%
% All temporary variables and files which were created by Rcall are deleted

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
    delete('Rwarn.txt')
% end
warning('on','MATLAB:DELETE:FileNotFound');

