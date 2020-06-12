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

for i=1:nargin
    if strcmp(varargin{i},'c')    % 'c' is a reserved word in R
        varargin{i} = 'c2';       % 'c2' just for transfer, it's called 'c' again after loading (end of this file)
        % if dataframe,not convertible to *.mat, each column separately
        fprintf(fid,'%s\n',sprintf('if (is.data.frame(%s)){ for (i in 1:dim(%s)[2]) { ',varargin{i},'c'));
        fprintf(fid,'%s\n',sprintf('expr <- paste(paste(paste(paste(paste(expr,'', %s''),i,sep=""),''=%s[,''),i),'']'') }',varargin{i},'c'));
        fprintf(fid,'%s\n','} else { ');
        % Standard case
        fprintf(fid,'%s\n',sprintf('expr <- paste(expr,'',%s=%s'') }',varargin{i},'c'));
    else
        % if dataframe,not convertible to *.mat, each column separately
        fprintf(fid,'%s\n',sprintf('if (exists("%s")) { ',varargin{i}));
        fprintf(fid,'%s\n',sprintf('    if (is.data.frame(%s)) { for (i in 1:dim(%s)[2]) { ',varargin{i},varargin{i}));
        fprintf(fid,'%s\n',sprintf('        expr <- paste(paste(paste(paste(paste(expr,'', %s''),i,sep=""),''=%s[,''),i),'']'') } ',varargin{i},varargin{i}));
        fprintf(fid,'%s\n',sprintf('    } else { if (is.list(%s)) { for (i in 1:length(%s)) {',varargin{i},varargin{i}));
        fprintf(fid,'%s\n',sprintf('        %s[[i]] <- unlist(%s[[i]]) } }',varargin{i},varargin{i}));
        % Standard case
        fprintf(fid,'%s\n',sprintf('        expr <- paste(expr,'',%s=%s'') }',varargin{i},varargin{i}));
        fprintf(fid,'%s\n',sprintf('} else { %s <- {} ',varargin{i}));
        fprintf(fid,'%s\n',sprintf('expr <- paste(expr,'',%s=%s'') }',varargin{i},varargin{i}));
 
    end
end
fprintf(fid,'%s\n','expr <- paste(expr,'')'')');
fprintf(fid,'%s\n','eval(parse(text=expr))');
fclose(fid);

system(sprintf('%s CMD BATCH --vanilla --slave "%s%sRpull.R"',OPENR.Rexe,pwd,filesep));

dat = load('Rpull.mat');
    
varargout = {};
for i=1:length(varargin)
    names = regexp(fieldnames(dat),[varargin{i} '[0-9]'],'match','once');
    idx = find(~cellfun('isempty',names));
    if isempty(idx)
        varargout{i} = dat.(varargin{i});
    else
        varargout{i}= dat.(names{idx(1)});
        for j=2:length(idx)
            varargout{i} = [varargout{i} dat.(names{idx(j)})];
        end
    end
end

for i=1:length(varargout)
    if isstruct(varargout{i}) 
        % if substruct
        if isfield(varargout{i},varargin{i})
            varargout{i} = varargout{i}.(varargin{i});
        end 
        % if cell->struct in Rpush, now struct->cell in Rpull
        if isfield(varargout{i},'row1')
            varargout{i} = squeeze(struct2cell(varargout{i}));
        end
    end
end
