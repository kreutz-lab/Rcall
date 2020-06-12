%   Rpush(varname,val)
% 
%   This function is used to push variables to the R-workspace
% 
%   varname     the variable name used in R

function Rpush(varargin)
global OPENR

Rexec  % execute R commands if they are in the buffer
ftmp = @(x)x;

for i=1:2:nargin

    valname = varargin{i};
    val = varargin{i+1};

    if ~ischar(valname)
        error('Rpush.m: Name-value pairs expected as input arguments.')
    end
    
    %% Convert matlab variables to string/struct if necessary
    if isstring(val)
        val = char(val);
    end
    if iscategorical(val)
        val = cellstr(val);
    end    
    if iscell(val)
        val = cell2struct(val,strcat('row',string(1:size(val,1))),1);
    end
    if istable(val) || istimetable(val)
        val = table2struct(val);
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
    if ~isstruct(val) && ~isnumeric(val) && ~ischar(val) && ~islogical(val) && ~ischar(val)
        warning(['Rcall/Rpush.m: Data type of variable ' valname ' unknown. May lead to problems converting to R.']);
    end
    
    %% Push
    evstr = sprintf('%s = feval(ftmp,val);',valname);   
    evstr2 = sprintf('save(''Rpush.mat'',''%s'',''-append'');',valname);
    eval(evstr);
    eval(evstr2);
end
