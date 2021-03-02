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

system(sprintf('%s CMD BATCH --vanilla --slave "%s%sRpull.R"',OPENR.Rexe,pwd,filesep));

dat = load('Rpull.mat');
    
varargout = {};
for i=1:length(varargin)
    if isfield(dat,[varargin{i} '_subfields']) && ~isempty(dat.([varargin{i} '_subfields']))
        sf = strsplit(dat.([varargin{i} '_subfields']),',');
        dim = str2num(dat.([varargin{i} '_dim']));
        %% Dataframe to table
        if isfield(dat,[varargin{i} '_vartype']) && strcmp(dat.([varargin{i} '_vartype']),'data.frame')
            temp = dat.(sf{1});
            for j=2:length(sf)
                temp = [temp dat.(sf{j})];
            end
            varargout{i} = struct2table(temp);
        %% Array to array
        elseif isfield(dat,[varargin{i} '_vartype']) && (strcmp(dat.([varargin{i} '_vartype']),'array') || strcmp(dat.([varargin{i} '_vartype']),'matrix'))
            dim = str2num(dat.([varargin{i} '_dim']));
            if ~isempty(dim)
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
            else
                varargout{i} = dat.(varargin{i});
                warning(['Possible error in ' varargin{i} '. No dimension for array given.'])
            end
        %% List to struct
        else %if isfield(dat,[varargin{i} '_vartype']) && strcmp(dat.([varargin{i} '_vartype']),'list') && ~isempty(sf)
            fn = fieldnames(dat);
            %fn = fn{contains(fn,dat.([varargin{i} '_subfields'])) & ~contains(fn,'_subfields')};
            fn2 = fn(contains(fn,'_subfields'));
            for j=1:length(fn2)
                fn3 = strsplit(dat.(fn2{j}),',');
                for k=1:length(fn3)
                    if ~isempty(fn3{k})
                        name = replace(fn3{k},'_','.');
                        eval(sprintf('dat.%s = dat.(fn3{k});',name));
                    end
                end
            end
            varargout{i} = dat.(varargin{i});
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
fprintf(fid,'%s\n','      expr <- paste('','',gsub("\\$","_",argname),''='',argname) ');
fprintf(fid,'%s\n','    } else { ');

fprintf(fid,'%s\n','      # Initialize');
fprintf(fid,'%s\n','      expr <- NULL');
fprintf(fid,'%s\n','      sf <- NULL');
fprintf(fid,'%s\n','      if (!grepl("\\$",argname)) {');
fprintf(fid,'%s\n','        arg <- drop(arg)');
fprintf(fid,'%s\n','        expr <- paste('','',argname,''_vartype="'',class(arg)[1],''"'',sep="")');
fprintf(fid,'%s\n','        expr <- paste(expr,'','',argname,''_dim="'',toString(dim(arg)),''"'',sep="") }');
      
fprintf(fid,'%s\n','      # Get names for subfields');
fprintf(fid,'%s\n','      if (is.null(names(arg))) {');
fprintf(fid,'%s\n','        if (!is.null(rownames(arg)) & length(rownames(arg))==length(arg)) { varnames <- rownames(arg)');
fprintf(fid,'%s\n','        } else { varnames <- seq(1:length(arg)) }');
fprintf(fid,'%s\n','      } else { varnames <- names(arg) }');
      
fprintf(fid,'%s\n','      # DATA FRAME');
fprintf(fid,'%s\n','      if (is.data.frame(arg)) { for (i in 1:dim(arg)[2]) { ');
fprintf(fid,'%s\n','        sf <- c(sf,gsub("\\.","_",gsub("\\$","_",paste(argname,''_'',varnames[i],sep=""))))');
fprintf(fid,'%s\n','        expr <- paste(expr,'','',tail(sf,1),''='',argname,''[,'',i,'']'',sep="") }');
      
fprintf(fid,'%s\n','      # ARRAY');
fprintf(fid,'%s\n','      } else if (is.array(arg)) { ');
fprintf(fid,'%s\n','        for (i in 1:length(arg)) {');
fprintf(fid,'%s\n','          sf <- c(sf,gsub("\\.","_",gsub("\\$","_",paste(argname,''_'',varnames[i],sep=""))))');
fprintf(fid,'%s\n','          if (is.list(arg[[i]])) {');
fprintf(fid,'%s\n','            expr <- paste(expr,'','',tail(sf,1),''= unlist('',argname,''[['',i,'']])'',sep="") }');
fprintf(fid,'%s\n','          else { expr <- paste(expr,'','',tail(sf,1),''='',argname,''[['',i,'']]'',sep="")  } }');
        
fprintf(fid,'%s\n','      # LIST');
fprintf(fid,'%s\n','      } else { del <- NULL');
fprintf(fid,'%s\n','        for (i in 1:length(arg)) {');
fprintf(fid,'%s\n','          if (is.list(arg[[i]])) {');
fprintf(fid,'%s\n','            if (length(arg[[i]])<2) { arg <- unlist(arg) } else {');
fprintf(fid,'%s\n','              re<- UnlistArg(arg[[i]],paste(argname,''$'',varnames[i],sep=""))');
fprintf(fid,'%s\n','              arg[[i]] <- re[[1]]');
fprintf(fid,'%s\n','              if (is.list(arg[[i]])) {');
fprintf(fid,'%s\n','                expr <- paste(expr,re[[2]]) ');
fprintf(fid,'%s\n','                sf <- c(sf,gsub("\\.","_",gsub("\\$","_",paste(argname,''_'',varnames[i],sep=""))))}');
fprintf(fid,'%s\n','            } } else if (is.null(arg[[i]])) { del <- c(del,i) } }');
fprintf(fid,'%s\n','        if (!is.null(del)) { for (j in 1:length(del)) { arg[[rev(del)[j]]] <- NULL } }');
fprintf(fid,'%s\n','        expr <- paste(expr,'','',gsub("\\.","_",gsub("\\$","_",argname)),''='',argname) }');
fprintf(fid,'%s\n','       if (!is.null(sf)) { expr <- paste(expr,'','',gsub("\\.","_",gsub("\\$","_",argname)),''_subfields="'',paste(sf,collapse='',''),''"'',sep="")');
fprintf(fid,'%s\n','      } } }');
fprintf(fid,'%s\n','  return(list(arg,expr))');
fprintf(fid,'%s\n','}');