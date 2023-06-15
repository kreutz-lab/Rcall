% function Rrunfile(Rscript)
%
% Rrunfile.m reads the file Rscript.R linewise
% the R commands are saved and executed in the file in Rpull.m
%
% Rscript - location and name of a .R or .txt file consisting of R script
% 
% Example:
% Rinit('limma')
% load('pasilla_count_noMM.mat')
% Rpush('dat',geneCountTable{:,3:6},'grp',[0;0;1;1])
% Rrunfile('Rrunfile_example.R')
% p = Rpull('p');
% Rclear

function Rrunfile(Rscript)

if ~exist('Rscript','var') || ~exist(Rscript,'file')
    error(['Did not find ' Rscript '. Did you define the correct directory?'])
end

fid = fopen(Rscript);
tline = fgetl(fid);
while ischar(tline)
    disp(tline)
    eval(['Rrun(''' tline ''')']);
    tline = fgetl(fid);
end
fclose(fid);

