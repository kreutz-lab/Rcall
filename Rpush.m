%   Rpush(varname,val)
% 
%   This function is used to push variables to the R-workspace
% 
%   varargin - variables of any type which to pass to R

function Rpush(varargin)
global OPENR

Rexec  % execute R commands if they are in the buffer

OPENR.cmd = {};

for i=1:nargin
    
    val = varargin{i};
    name = inputname(i);
    
    if ~isstruct(val) && ~isnumeric(val) && ~ischar(val) && ~islogical(val) && ~ischar(val) && ~istable(val) && ~iscell(val) && ~isa(val,'dataset') && ~iscategorical(val)
        warning(['Rcall/Rpush.m: Data type of variable ' name ' unknown. May lead to problems converting to R.']);
    end
    if ~ischar(name)
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
        %OPENR.cmd{end+1} = [name ' <- data.frame(' name ')']; % table -> data.frame (one can comment if list is prefered)
    end
    if istable(val) || istimetable(val)
        f = fieldnames(val);
        for j=1:length(f)-3
            if isa(val.(f{j}),'nominal') 			% convert nominal to string
                val.(f{j}) = cellstr(val.(f{j}));
                OPENR.cmd{end+1} = [name '$' f{j} '<- factor(' name '$' f{j} ')']; % table -> data.frame (one can comment if list is prefered)
            end
        end
        val = table2struct(val);
        OPENR.cmd{end+1} = [name ' <- data.frame(' name ')']; % table -> data.frame (one can comment if list is prefered)
    end
    if iscategorical(val)
        val = cellstr(val);
        %OPENR.cmd{end+1} = [name ' <- factor(' name ')']; % table -> data.frame (one can comment if list is prefered)
    end  
    if isdatetime(val) || isduration(val)
       val = char(val);
    end
    if isa(val,'function_handle')
        cmd = [val '<- eval(expression(' replace(replace(func2str(val),'@','function'),'.','') '))'];
        if ~isfield(OPENR,'cmd')
            OPENR.cmd = {cmd};
        else
            OPENR.cmd{end+1} = cmd;
        end
        continue
    end
    
    %% Push
    ftmp = @(x)x;
    evstr = sprintf('%s = feval(ftmp,val);',name);   
    evstr2 = sprintf('save(''Rpush.mat'',''%s'',''-append'');',name);
    eval(evstr);
    eval(evstr2);
end
