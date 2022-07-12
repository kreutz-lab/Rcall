%   This function is for initialization purpose.
%   The global variable "global OPENR" with paths to the R executable and 
%   libraries is initialized and empty workspaces are created.
% 
% libraries - cell or string of the R package names which to attach (alternatively the R packages can be defined in Rrun(‘library(Rpackage)’))
%   The path to the R executable is set automatically or can be specified
%   by the user:
% path      - path to the executable R.exe
% (The path to the R executable is set automatically or can be specified by the user)
% libpath   - path to the R libraries
% 
% Example:
%   path = '/usr/local/lib/R/bin/R.exe';
%   libpath = '~/R_library';
%   Rinit([],path,libpath)
%   Rrun('dat <- c(5,5,5)')
%   dat = Rpull('dat');
%   Rclear
%
% Rcall: An R interface for MATLAB.
% Copyright (C) 2022, Janine Egert and Clemens Kreutz
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
% 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
% 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
% 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
% IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
% egert@imbi.uni-freiburg.de and ckreutz@imbi.uni-freiburg.de
% Institut für Medizinische Biometrie und Statistik
% Universitätsklinikum Freiburg
% Stefan-Meier-Str. 26
% 79104 Freiburg



function Rinit(libraries,path,libpath)

global OPENR
OPENR = struct;

%% Copyright information
fprintf('Rcall: An R interface for MATLAB. \nCopyright (C) 2022 Janine Egert and Clemens Kreutz.\n')
fprintf('THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES ARE DISCLAIMED; for details see "LICENSE".\n')
fprintf('Redistribution and use in source and binary forms, with or without modification, are permitted provided certain conditions; for details see "LICENSE".\n')
%fprintf('Website & bug report: https://github.com/kreutz-lab/Rcall')

%% Set R path
if exist('path','var') && ~isempty(path)
    OPENR.Rexe = path;
else
    if isunix || ismac
        [~,OPENR.Rexe]=system('which R');
    else
        [~,OPENR.Rexe]=system('where R.exe');
        if strncmpi(OPENR.Rexe,'information',11)
            warning('"R.exe" has not be found. Try adding the R path to the system environment variables.')
        end
%         if ~strcmp(OPENR.Rexe(1),'"')
%             OPENR.Rexe = ['"' OPENR.Rexe '"']; % to be excecutable via command line
%         end
    end
    if isempty(OPENR.Rexe)
        % Searches in standard windows/linux/cluster paths
        OPENR.Rexe = Rload;
    end
    OPENR.Rexe = strtrim(OPENR.Rexe);
%     OPENR.Rexe = sort(strsplit(OPENR.Rexe));
%     OPENR.Rexe = OPENR.Rexe{end};
end
if ~isfield(OPENR,'Rexe') || isempty(OPENR.Rexe)
    error('Rcall/Rinit.m: Define your home directory of R in Rinit(Rlibraries,Rpath). You can find the directory by R.home() in R.')
else
    if contains(OPENR.Rexe,'Rscript')
        warning('Not all R code is executable with Rscript. Better use R. You can set your Rpath in Rinit(Rlibraries, Rpath).\n')
    end
    %% Print R version
    cmd = sprintf('"%s" --version',OPENR.Rexe);
    [status,cmdout] = system(cmd);
    if status~=0
        error('%s fails. Can be checked from command line. \nIs the Rpath "%s" correct? \nIs R path is set as environmental variable? \n%s',cmd, OPENR.Rexe, cmdout)
    else
        cmdout = strsplit(cmdout,char(10));
        Rversion = cmdout{1}
    end
end
% Check existence of R path. if calling "R" on clusters, it's not a path
% if ~exist(OPENR.Rexe,'file') % 'dir'?
%     if exist(OPENR.Rexe,'dir') && exist([OPENR.Rexe filesep 'R.exe'],'file')
%         OPENR.Rexe = [OPENR.Rexe filesep 'R.exe'];
%     elseif exist(OPENR.Rexe(1:end-1),'file')
%         OPENR.Rexe = OPENR.Rexe(1:end-1);
%     else
%         error(['Rinit.m: R path "' OPENR.Rexe '" not found. You can find the directory by R.home() in R.'])
%     end
% end

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
save('Rpush.mat','OPENR','-v7'); % version >=7.3 not supported by R.matlab package
                                 % version <7 do not support structs
warning('off','MATLAB:DELETE:FileNotFound');
delete('Rpull.mat')
warning('on','MATLAB:DELETE:FileNotFound');

