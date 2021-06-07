%   This function is for initialization purpose.
%   The global variable "global OPENR" with paths to the R executable and 
%   libraries is initialized and empty workspaces are created.
% 
%   The path to the R executable is set automatically or can be specified
%   by the user:
% path      - path to the executable R.exe
% libpath   - path to the R libraries
% 
% Example:
%   path = '/usr/local/lib/R/bin/R.exe';
%   libpath = '~/R_library';
%   Rinit(path,libpath)
%   evalR('dat <- c(5,5,5)')
%   dat = getRdata('dat');
%   closeR

function Rinit(libraries,path,libpath)

global OPENR
OPENR = struct;

%% Set R path
if exist('path','var')
    OPENR.Rexe = path;
else
    if ispc
        if isunix || ismac
            [~,OPENR.Rexe]=system('which R');
        else
            [~,OPENR.Rexe]=system('where R.exe');
            if strncmpi(OPENR.Rexe,'information',11)
                warning('The system call "where R.exe" did not work on your system. Try adding the R path in your system environment variables.')
            end
            OPENR.Rexe = sort(split(OPENR.Rexe,char(10)));
            OPENR.Rexe = OPENR.Rexe{end};
        end
    else
        % Searches in standard windows/linux/cluster paths
        OPENR.Rexe = Rload;
    end
end
if ~isfield(OPENR,'Rexe') || isempty(OPENR.Rexe)
    error('Rcall/Rinit.m: Define your home directory of R in Rinit(Rlibraries,Rpath). You can find the directory by R.home() in R.')
end
% Check existence of R path, if calling "R" on clusters, it's not a path
% if ~exist(OPENR.Rexe,'file') % 'dir'?
%     if exist(OPENR.Rexe,'dir') && exist([OPENR.Rexe filesep 'R.exe'],'file')
%         OPENR.Rexe = [OPENR.Rexe filesep 'R.exe'];
%     elseif exist(OPENR.Rexe(1:end-1),'file')
%         OPENR.Rexe = OPENR.Rexe(1:end-1);
%     else
%         error(['Rinit.m: R path "' OPENR.Rexe '" not found. You can find the directory by R.home() in R.'])
%     end
% end
if ~strcmp(OPENR.Rexe(1),'"')
    OPENR.Rexe = ['"' OPENR.Rexe '"']; % to be excecutable via command line
end

%% Set library path
if exist('libpath','var')
    OPENR.myLibPath = libpath;
end

%% Set R packages
OPENR.libraries = {'R.matlab'}; % R package for reading/writing .mat variables, is always loaded

if exist('libraries','var') && ~isempty(libraries)
    if ~iscell(libraries)
        libraries = {libraries};
    end
    for i=1:length(libraries)
        if ischar(libraries{i})
            OPENR.libraries{end+1} = libraries{i};
        else
            error('Rinit.m: Input argument has to be a string of the required R package')
        end
    end
end

%% create empty workspaces
save Rpush

warning('off','MATLAB:DELETE:FileNotFound');
delete('getRdata.mat')
warning('on','MATLAB:DELETE:FileNotFound');

