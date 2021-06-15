%   Rpush(valname,val,[valname,val,...])
% 
%   This function is used to push variables to the R-workspace
% 
%   valname     the variable name used in R
%   val         the variable which is passed to R

function Rpush(varargin)
global OPENR

Rexec  % execute R commands if they are in the buffer

OPENR.cmd = {};

for i=1:2:nargin
    
    if nargin<2 % if only one input argument, take name of input variable
        val = varargin{i};
        valname = inputname(varargin{i});
    else        % else string is variable name, second argument is varialbe
        valname = varargin{i};
        val = varargin{i+1};
    end
    
    if ~isstruct(val) && ~isnumeric(val) && ~ischar(val) && ~islogical(val) && ~ischar(val) && ~istable(val) && ~iscell(val) && ~isa(val,'dataset') && ~iscategorical(val)
        warning(['Rcall/Rpush.m: Data type of variable ' valname ' unknown. May lead to problems converting to R.']);
    end
    if ~ischar(valname)
        error('Rpush.m: Name-value pairs expected as input arguments.')
    end
    
    %% Convert matlab variables to string/struct if necessary
    if isstring(val)
        val = char(val);
    end  
    if iscell(val)
        val = cell2struct(val,strcat('row',string(1:size(val,1))),1);
    end
    if isa(val,'dataset')
        val = dataset2table(val);
        %val = dataset2struct(val);
        %OPENR.cmd{end+1} = [valname ' <- data.frame(' valname ')']; % table -> data.frame (one can comment if list is prefered)
    end
    if istable(val) || istimetable(val)
        f = fieldnames(val);
        for j=1:length(f)-3
            if isa(val.(f{j}),'nominal') 			% convert nominal to string
                val.(f{j}) = cellstr(val.(f{j}));
                OPENR.cmd{end+1} = [valname '$' f{j} '<- factor(' valname '$' f{j} ')']; % table -> data.frame (one can comment if list is prefered)
            end
        end
        val = table2struct(val);
        OPENR.cmd{end+1} = [valname ' <- data.frame(' valname ')']; % table -> data.frame (one can comment if list is prefered)
    end
    if iscategorical(val)
        val = cellstr(val);
        %OPENR.cmd{end+1} = [valname ' <- factor(' valname ')']; % table -> data.frame (one can comment if list is prefered)
    end  
    if isdatetime(val) || isduration(val)
       val = char(val);
    end
    if isa(val,'function_handle')
        cmd = [varargin{i} '<- eval(expression(' replace(replace(func2str(val),'@','function'),'.','') '))'];
        if ~isfield(OPENR,'cmd')
            OPENR.cmd = {cmd};
        else
            OPENR.cmd{end+1} = cmd;
        end
        continue
    end
    
    %% Push
    ftmp = @(x)x;
    evstr = sprintf('%s = feval(ftmp,val);',valname);   
    evstr2 = sprintf('save(''Rpush.mat'',''%s'',''-append'');',valname);
    eval(evstr);
    eval(evstr2);
end
