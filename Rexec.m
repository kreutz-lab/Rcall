% Rrun_writeAndExecute
% 
%   This function is called in Rpush and getRdata to execute R commands
%   which are collected and buffered by Rrun commands. Usually, this
%   function is NOT directly called by the user.
% 
%   The reason for buffering is that it is faster to execute serveral R
%   commands together.
%
% Rcall: An R interface for MATLAB.
% Copyright (C) 2022, Janine Egert and Clemens Kreutz
% see LICENSE for more details

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
        fprintf(fid,' library(%s)\n',OPENR.libraries{i});
        fprintf(fid,'},error=function(e) {\n');
        fprintf(fid,' tryCatch({\n');
        fprintf(fid,'  tryCatch({\n');
        fprintf(fid,'   install.packages("%s", repos="http://cran.us.r-project.org")\n',OPENR.libraries{i});
        fprintf(fid,'   library(%s)\n',OPENR.libraries{i});
        fprintf(fid,'  },error=function(e) {\n');
        fprintf(fid,'   BiocManager::install("%s")\n',OPENR.libraries{i});
        fprintf(fid,'   library(%s)\n',OPENR.libraries{i});
        fprintf(fid,'  })\n');   
        fprintf(fid,' },error=function(e) {\n');
        fprintf(fid,'  sink("Rerrorinstalltmp.txt")\n');
        fprintf(fid,'  cat("Error in Rrun.R : Installation of package %s was not successfull. Try package installation in R beforehand. If your package has been installed, check if the R version and the R libraries are set in the system environmental variables. ", conditionMessage(e))\n',OPENR.libraries{i});
        fprintf(fid,'  sink()\n');
        fprintf(fid,'})})\n');        
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
    if any(~cellfun(@isempty,strfind(OPENR.cmd,'pdf')))
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
    
    cmd = sprintf('"%s" CMD BATCH --slave "%s%sRrun.R"',OPENR.Rexe,pwd,filesep);
    [status,cmdout] = system(cmd);
    
    if ~isempty(cmdout)
        if contains(cmdout,'system cannot find the path specified')
            error([cmdout ' Is your R path ' OPENR.Rexe ' defined in the PATH environmental variable? Alternatively, set your R path in the Rinit(Rpackages,Rpath) function as second input argument.'])
        end
        error(cmdout)
    end
    if status~=0
        if isfield(OPENR,'myLibPath')
            error(sprintf(['Is your R path "' OPENR.Rexe '" correct? You can set the Rpath in Rinit(Rlibraries,Rpath). /n Is your R library path "' OPENR.myLibPath '"correct? You can set it in Rinit(Rlibraries,Rpath,Rlibpaths).']))
        else
            error(sprintf(['Is your R path "' OPENR.Rexe '" correct? You can set the Rpath in Rinit(Rlibraries,Rpath). /n Is the R library path correct? You can set it in Rinit(Rlibraries,Rpath,Rlibpaths).']))
        end
    end
    
    % show error messages in matlab command window
    if exist([pwd filesep 'Rerrorinstalltmp.txt'],'file')
        error(fileread([pwd filesep 'Rerrorinstalltmp.txt']))
    end
    if exist([pwd filesep 'Rerrortmp.txt'],'file')
        error(fileread([pwd filesep 'Rerrortmp.txt']))
    end
   
    OPENR = rmfield(OPENR,'cmd');
end

