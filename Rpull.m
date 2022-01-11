% val = Rpull(varname)
% 
%   varname     name of an R variable which should be picked
% 
%   val         the value of the variable in R
% 
%  This function is for getting the results of calculations in R. The
%  buffered R commands in OPENR.cmd are executed before. Therefore, it
%  might take some time.
%  Picking the variables is also rather slow since *.mat workspaces has to
%  be written.
% 
%   This function requires the R.matlab package that has to be installed in
%   R (e.g. via install.packages("R.matlab")
%
% Rcall: An R interface for MATLAB.
% Copyright (C) 2022, Janine Egert and Clemens Kreutz
% see LICENSE for more details

function varargout = Rpull(varargin)
global OPENR

Rexec

%% Schreibe *.Rdata in Rrun und konvertiere varname und speichere varname in Rpull.mat
fid = fopen('Rpull.R','w');

fprintf(fid,'%s\n',['setwd("',strrep(pwd,filesep,'/'),'")']);
if isfield(OPENR,'myLibPath') && ~isempty(OPENR.myLibPath) && exist(OPENR.myLibPath,'file')  
    fprintf(fid,'%s\n',['.libPaths("',OPENR.myLibPath,'")']); % my own library
end
fprintf(fid,'require(R.matlab)\n');
fprintf(fid,'rm(list=ls())\n');
fprintf(fid,'\n');

fprintf(fid,'%s\n','load("Rrun.Rdata")');

% do variables exist?
for i=1:nargin
    fprintf(fid,'%s\n',sprintf('if (!exists("%s") && !file.exists("Rerrortmp.R")) { writeLines(paste("Variable ''%s'' does not exist. Check your variable definition or the Rrun.R function.",sep=""),"Rerrortmp.txt")}',varargin{i},varargin{i}));
end
fprintf(fid,'%s\n','expr <- ''writeMat("Rpull.mat"''');

UnlistArg(fid)

for i=1:nargin
    fprintf(fid,'%s\n',sprintf('re <- UnlistArg(%s,''%s'')',varargin{i},varargin{i}));
    fprintf(fid,'%s\n',sprintf('%s <- re[[1]]',varargin{i}));
    fprintf(fid,'%s\n','expr <- paste(expr,re[[2]])');
end
fprintf(fid,'%s\n','expr <- paste(expr,'')'')');
fprintf(fid,'%s\n','eval(parse(text=expr))');
fclose(fid);

[status,cmdout] = system(sprintf('"%s" CMD BATCH --slave "%s%sRpull.R"',OPENR.Rexe,pwd,filesep));

if exist('Rerrortmp.txt','file')
     error(fileread([pwd filesep 'Rerrortmp.txt']))
end
if ~isempty(cmdout)
    if contains(cmdout,'system cannot find the path specified')
        error([cmdout ' Is your R path ' OPENR.Rexe ' defined in the PATH environmental variable? Alternatively, set your R path in the Rinit(Rpackages,Rpath) function as second input argument.'])
    end
    error(cmdout)
end
if status~=0
    if isfield(OPENR,'myLibPath')
        error(sprintf(['Is your R path "' OPENR.Rexe '" correct? You can set the Rpath in Rinit(Rlibraries,Rpath). /n Is your R library path "' OPENR.myLibPaths '"correct? You can set it in Rinit(Rlibraries,Rpath,Rlibpaths).']))
    else
        error(sprintf(['Is your R path "' OPENR.Rexe '" correct? You can set the Rpath in Rinit(Rlibraries,Rpath). /n Is the R library path correct? You can set it in Rinit(Rlibraries,Rpath,Rlibpaths).']))
    end
end
try
    dat = load('Rpull.mat');
catch
     warning('Is the R package installed? Try to run Rrun.R in R for error prouning.')
end
    
varargout = {};
for i=1:length(varargin)
    if isfield(dat,[varargin{i} '_subfields']) && ~isempty(dat.([varargin{i} '_subfields']))
        sf = strsplit(dat.([varargin{i} '_subfields']),',');
        %% Array to array
        if isfield(dat,[varargin{i} '_vartype']) && (strcmp(dat.([varargin{i} '_vartype']),'array') || strcmp(dat.([varargin{i} '_vartype']),'matrix'))
            dim = str2num(dat.([varargin{i} '_dim']));
                if length(dim)==1
                    row = ind2sub(dim,1:length(sf));
                    col = ones(length(row),1); page = ones(length(row),1);
                    varargout{i} = cell(dim(1));
                elseif length(dim)==2
                    [row,col] = ind2sub(dim,1:length(sf));
                    varargout{i} = cell(dim(1),dim(2));
                    page = ones(length(row),1);
                elseif length(dim)==3
                    [row,col,page] = ind2sub(dim,1:length(sf));
                    varargout{i} = cell(dim(1),dim(2),dim(3));
                else
                    warning('No more than 4D arrays supported.')
                end
                for j=1:length(row)
                    varargout{i}{row(j),col(j),page(j)} = dat.(sf{j});
                end
        %% List to struct
%         elseif isfield(dat,[varargin{i} '_vartype']) && strcmp(dat.([varargin{i} '_vartype']),'data.frame')
%             temp = dat.(sf{1});
%             for j=2:length(sf)
%                 temp = [temp dat.(sf{j})];
%             end
%             varargout{i} = struct2table(temp);
        else %if isfield(dat,[varargin{i} '_vartype']) && strcmp(dat.([varargin{i} '_vartype']),'list') && ~isempty(sf) 
            fn = fieldnames(dat);
            sfields = fn(~cellfun(@isempty,strfind(fn,varargin{i})) & ~cellfun(@isempty,strfind(fn,'_subfields')) );
            %sfields = fn(contains(fn,varargin{i}) & contains(fn,'_subfields'));
            for k=length(sfields):-1:1
                sf = strsplit(dat.(sfields{k}),',');
                for s = length(sf):-1:1
                    eval(sprintf('dat.%s = dat.(sf{s});',strrep(sf{s},'_struct_','.')));
                end
            end
            if isfield(dat,[varargin{i} '_vartype']) && ~isempty(strfind(dat.([varargin{i} '_vartype']),'tbl'))
              try
                varargout{i} = struct2table(dat.(varargin{i}),'AsArray',true); % In Octave, the data type 'table' is not available
              catch
                varargout{i} = dat.(varargin{i});
              end
            else
                varargout{i} = dat.(varargin{i});
            end
        end
    %% Take as is
    else
        varargout{i} = dat.(varargin{i});
    end
end



function UnlistArg(fid)

fprintf(fid,'%s\n','UnlistArg <- function(arg,argname) { ');
fprintf(fid,'%s\n','if (exists("arg")) { ');
fprintf(fid,'%s\n','    # if not list, keep as is');
fprintf(fid,'%s\n','    if (!is.list(arg)) { ');
fprintf(fid,'%s\n','      expr <- paste('','',gsub("\\$","_struct_",argname),''='',gsub("\\$sub([0-9])","[[\\1]]",argname)) ');
fprintf(fid,'%s\n','    } else { ');
fprintf(fid,'%s\n','      # Initialize');
fprintf(fid,'%s\n','      expr <- NULL');
fprintf(fid,'%s\n','      sf <- NULL');
fprintf(fid,'%s\n','      # Get names for subfields');
fprintf(fid,'%s\n','      if (is.null(names(arg))) {');
fprintf(fid,'%s\n','        if (!is.null(rownames(arg)) & length(rownames(arg))==length(arg)) { varnames <- rownames(arg)');
fprintf(fid,'%s\n','        } else { varnames <- paste0("sub",seq(1:length(arg))) }');
fprintf(fid,'%s\n','      } else { varnames <- names(arg) }');
fprintf(fid,'%s\n','      varnames <- gsub(" ","_",varnames)');
fprintf(fid,'%s\n','      if (!grepl("\\$",argname)) {');
fprintf(fid,'%s\n','        arg <- drop(arg)');
fprintf(fid,'%s\n','        expr <- paste('','',argname,''_vartype="'',class(arg)[1],''"'',sep="")');
fprintf(fid,'%s\n','        expr <- paste(expr,'','',argname,''_dim="'',toString(dim(arg)),''"'',sep="") }');
fprintf(fid,'%s\n','        ii <- 0');
fprintf(fid,'%s\n','        for (i in 1:length(arg)) {');
fprintf(fid,'%s\n','          if (varnames[i-ii]=="") {varnames[i-ii] <- paste("X",i-ii,sep="")}');
fprintf(fid,'%s\n','          if (is.list(arg[[i-ii]]) || is.factor(arg[[i-ii]])) {');
fprintf(fid,'%s\n','            if (length(arg[[i-ii]])<2 || is.factor(arg[[i-ii]])) { arg <- unlist(arg);break } else {');
fprintf(fid,'%s\n','              re<- UnlistArg(arg[[i-ii]],paste(argname,''$'',varnames[i-ii],sep=""))');
fprintf(fid,'%s\n','              if (is.list(arg[[i-ii]])) {');
fprintf(fid,'%s\n','                arg[[i-ii]] <- re[[1]]');
fprintf(fid,'%s\n','                expr <- paste(expr,re[[2]]) ');
fprintf(fid,'%s\n','                sf <- c(sf,gsub("\\.","_",gsub("\\$","_struct_",paste(argname,"_struct_",varnames[i-ii],sep=""))))');
fprintf(fid,'%s\n','              }');
fprintf(fid,'%s\n','            } } else if (is.call(arg[[i-ii]])) { arg[[i-ii]] <- str(arg[[i-ii]])');
fprintf(fid,'%s\n','              } else if (is.null(arg[[i-ii]])) { arg[[i-ii]] <- NULL');
fprintf(fid,'%s\n','          varnames <- names(arg) ');
fprintf(fid,'%s\n','          ii <- ii+1');
fprintf(fid,'%s\n','          } else { sf <- c(sf,gsub("\\.","_",gsub("\\$","_struct_",paste(argname,"_struct_",varnames[i-ii],sep="")))) ');
fprintf(fid,'%s\n','                   expr <- paste(expr,",",tail(sf,1),"=",argname,"[[",i-ii,"]]",sep="") } }');
%fprintf(fid,'%s\n','        if (!is.null(del)) { for (j in 1:length(del)) { arg[[rev(del)[j]]] <- NULL } }');
fprintf(fid,'%s\n','        expr <- paste(expr,'','',gsub("\\.","_",gsub("\\$","_struct_",argname)),''='',gsub("\\$sub([0-9])","[[\\1]]",argname))');
fprintf(fid,'%s\n','       if (!is.null(sf)) { expr <- paste(expr,'','',gsub("\\.","_",gsub("\\$","_struct_",argname)),''_subfields="'',paste(sf,collapse='',''),''"'',sep="")');
fprintf(fid,'%s\n','      } } }');
fprintf(fid,'%s\n','  return(list(arg,expr))');
fprintf(fid,'%s\n','}');