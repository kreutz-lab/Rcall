%   Rpush(valname,val,[valname,val,...])
% 
%   This function is used to push variables to the R-workspace
% 
%   varargin    the variable name used in R, the variable which is passed to R
%
%   Example:
%   Rpush('dat',dat,'X',X)
%   
%   Larger Example:
%   Rinit
%   Rpush('dat',dat)
%   Rrun('dat <- dat+1')
%   dat = Rpull('dat')
%   Rclear
%
% Rcall: An R interface for MATLAB.
% Copyright (C) 2022, Janine Egert and Clemens Kreutz
% see LICENSE for more details

function Rpush(varargin)

global OPENR

Rexec  % execute R commands if they are in the buffer

OPENR.cmd = {};

if nargin==0
    valname = evalin('caller','who');
    if length(valname)>100
        warning('More than 100 variables in your workspace. Sure you want to transfer them all? You can specify the variables by Rpush(''dat'',dat). \n No variables saved for transfer!');
        return
    end
    for i=1:length(valname)
        val = evalin('caller',valname{i});
        if whos('val').bytes > 1e9
            warning('Variable ''%s'' is greater than 1GB. It is not transferred to R.\n',valname{i});
            continue
        end
        if contains(valname{i},'.')
            error('Variable names with dot are not supported.')
        end
        Rpush(valname{i},val);
    end
else

%     if length(varargin)==1 && iscell(varargin)
%         c=1;
%         newvarargin = cell(length(varargin{1}),1);
%         for ic = 1:length(varargin{1})
%             newvarargin{c} = varargin{1}{ic};
%             newvarargin{c+1} = evalin('base',varargin{1}{ic});
%             c=c+2;
%         end
%         varargin = newvarargin;
%         nargin = length(varargin);
%     end
    
    for i=1:2:nargin
        
        if nargin<2 % if only one input argument, take name of input variable
            val = varargin{i};
            valname = inputname(varargin{i});
        else        % else string is variable name, second argument is varialbe
            valname = varargin{i};
            val = varargin{i+1};
        end
        
        if contains(valname,'.')
            error('Variable names with dot are not supported.')
        end

        if ~isa(val,'struct') && ~isa(val,'numeric') && ~isa(val,'string') && ~isa(val,'char') && ~isa(val,'logical') && ~isa(val,'table') && ~isa(val,'cell') && ~isa(val,'dataset') && ~isa(val,'categorical')
            warning(['Rcall/Rpush.m: Data type of variable ' valname ' not supported. May lead to problems converting to R.']);
        end
        if ~isa(valname,'char')
            error('Rpush.m: Name-value pairs expected as input arguments.')
        end
        if contains(valname,'_')
            warning(['The R.matlab package transforms ' valname ' into ' strrep(valname,'_','.') '. Consider removing or replacing "_".'])
        end
        
        %% Convert matlab variables to string/struct if necessary
        if isa(val,'string')
            val = char(val);
        elseif isa(val,'cell')
            val = cell2struct(val,strcat('row',num2str((1:size(val,1))')),1);
        elseif isa(val,'dataset')
            val = dataset2table(val);
            %val = dataset2struct(val);
            %OPENR.cmd{end+1} = [valname ' <- data.frame(' valname ')']; % table -> data.frame (one can comment if list is prefered)
        elseif isa(val,'table')
            f = fieldnames(val);
            val = table2struct(val,'ToScalar',true);
            %fn = horzcat(strjoin(strcat('"',f(1:length(f)-3),'",')));
            OPENR.cmd{end+1} = ['names(' valname ') <- rownames(' valname ')']; % table headings to table headings
            OPENR.cmd{end+1} = [valname ' <- data.frame(sapply(' valname ',c))']; % we do not want lists in our table BUT unlist produces character where it cans
            OPENR.cmd{end+1} = ['for (i in 1:dim(' valname ')[2]){   ' valname '[i] <- unlist(' valname '[,i])   }'];
            for j=1:length(f)-3
                if isa(val.(f{j}),'nominal') 			% convert nominal to string
                    val.(f{j}) = cellstr(val.(f{j}));
                    OPENR.cmd{end+1} = [valname '$' f{j} '<- factor(' valname '$' f{j} ')']; % table -> data.frame (one can comment if list is prefered)
                end
            end
            %val = table2struct(val);
            %OPENR.cmd{end+1} = [valname ' <- data.frame(drop(' valname '))']; % table -> data.frame (one can comment if list is prefered, in R: list -> struct)
            %fn = horzcat(strjoin(strcat('"',fieldnames(val),'",')));
            %OPENR.cmd{end+1} = ['names(' valname ') <- c(' fn(1:end-1) ')'];
        elseif isa(val,'categorical')
            val = cellstr(val);
            OPENR.cmd{end+1} = [valname ' <- factor(unlist(' valname '))'];
        elseif isa(val,'logical')
            OPENR.cmd{end+1} = [valname ' <- as.logical(' valname ')'];
        elseif isa(val,'time')
            val = char(val);
        elseif isa(val,'function_handle')
            cmd = [varargin{i} '<- eval(expression(' replace(replace(func2str(val),'@','function'),'.','') '))'];
            if ~isfield(OPENR,'cmd')
                OPENR.cmd = {cmd};
            else
                OPENR.cmd{end+1} = cmd;
            end
            continue
        elseif isa(val,'double')
        elseif isa(val,'float')
        elseif isa(val,'single')
        else
            warning('Pushing %s is not yet supported by Rlink. Convert to other variable types and work with these in your R commands.',class(val))
        end
        
        %% Push
        ftmp = @(x)x;
        evstr = sprintf('%s = feval(ftmp,val);',valname);
        evstr2 = sprintf('save(''Rpush.mat'',''%s'',''-append'',''-v7'');',valname);
        eval(evstr);
        warning('off','MATLAB:save:versionWithAppend');  % version has to be specified for Octave use
        eval(evstr2);
        warning('on','MATLAB:save:versionWithAppend');
    end
end

end
    