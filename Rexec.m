% Rrun_writeAndExecute
% 
%   This function is called in Rpush and getRdata to execute R commands
%   which are collected and buffered by Rrun commands. Usually, this
%   function is NOT directly called by the user.
% 
%   The reason for buffering is that it is faster to execute serveral R
%   commands together.

function Rexec
global OPENR

if isfield(OPENR,'cmd')
    fid = fopen('Rrun.R','w');
    fprintf(fid,'%s\n',['setwd("',strrep(pwd,filesep,'/'),'")']);
    fprintf(fid,'%s\n','tryCatch({');
    fprintf(fid,'\n### Load packages ###\n');
    if isfield(OPENR,'myLibPath') && ~isempty(OPENR.myLibPath) && exist(OPENR.myLibPath,'file')  
        fprintf(fid,'%s\n',['.libPaths("',OPENR.myLibPath,'")']); % my own library
    end
    for i=1:length(OPENR.libraries)
        fprintf(fid,'tryCatch({\n');
        fprintf(fid,'library(%s)\n',OPENR.libraries{i});
        fprintf(fid,'},error=function(e) {\n');
        fprintf(fid,'install.packages("%s")\n',OPENR.libraries{i});
        fprintf(fid,'library(%s) })\n',OPENR.libraries{i});
    end
    
    fprintf(fid,'\n### Load data ###\n');
    fprintf(fid,'rm(list=ls())\n');
    fprintf(fid,'%s\n','if(!file.exists("Rrun.Rdata"))');
    fprintf(fid,'%s\n','    save.image(file="Rrun.Rdata")');
    
    fprintf(fid,'%s\n','data_Rpush <- readMat("Rpush.mat")');
    
    % if list, transform to data.frame
%     fprintf(fid,'%s\n','for (i in 1:length(data_Rpush)) {');
%     fprintf(fid,'%s\n','    if (is.list(data_Rpush[[i]])) { data_Rpush[[i]] <- drop(data_Rpush[[i]])');
%     fprintf(fid,'%s\n','        if (length(dim(data_Rpush[[i]]))>1) { ');
%     fprintf(fid,'%s\n','            data_Rpush[[i]] <- data.frame(data_Rpush[[i]]) } } }');

    fprintf(fid,'%s\n','attach(data_Rpush)');
    %fprintf(fid,'rm(i)\n');
    
    fprintf(fid,'\n###  cmds  ###\n');    
    if any(contains(OPENR.cmd,'foreach'))
        fprintf(fid,'%s\n','tryCatch( { require(doParallel) },');
        fprintf(fid,'%s\n','warning=function(c) {install.packages("doParallel")');
        fprintf(fid,'%s\n','require(doParallel) })');
        fprintf(fid,'%s\n','tryCatch( { require(foreach) },');
        fprintf(fid,'%s\n','warning=function(c) {install.packages("foreach")');
        fprintf(fid,'%s\n','require(foreach) })');
    end
    for i=1:length(OPENR.cmd)        
        fprintf(fid,'%s\n',OPENR.cmd{i});
    end
    fprintf(fid,'\n### save ###\n');
    fprintf(fid,'%s\n','varnames <- unique(setdiff(ls(),c("data_Rpush","tmp","cellstrs")))'); % al variables which were previously in Rrun.mat and are newly calculated (by cmd)
    fprintf(fid,'%s\n','save(file="Rrun.Rdata",list=varnames)');
    
    % submit error to Rerrortmp.txt
    fprintf(fid,'\n### error output ###\n');
    fprintf(fid,'%s\n','},error=function(e) {');
    fprintf(fid,'%s\n','sink("Rerrortmp.txt")');
    fprintf(fid,'%s\n','cat("Error in Rrun.R :", conditionMessage(e))');
    fprintf(fid,'%s\n','sink() })');
    fclose(fid);
    
    cmd = sprintf('%s CMD BATCH --vanilla --slave "%s%sRrun.R"',OPENR.Rexe,pwd,filesep);
    status = system(cmd);
    
    % show error messages in matlab command window
    if exist([pwd filesep 'Rerrortmp.txt'],'file')
        error(fileread([pwd filesep 'Rerrortmp.txt']))
    end
   
    OPENR = rmfield(OPENR,'cmd');
end

