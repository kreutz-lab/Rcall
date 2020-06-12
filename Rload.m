%   This function looks for R in the standard installation folders

function path = Rload
    % Standard windows path
    if exist(['C:' filesep 'Program Files' filesep 'R'],'dir')
        version = dir(['C:' filesep 'Program Files' filesep 'R' filesep]);
        if exist(['C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'x64'],'dir')
            path = ['"C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'x64' filesep 'R.exe"'];
        elseif exist(['C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'i386'],'dir')
            path = ['"C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'i386' filesep 'R.exe"'];
        end
    % Standard linux path
    elseif exist([filesep 'usr' filesep 'local' filesep 'lib' filesep 'R'],'dir')
        if exist([filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'bin' filesep 'R.exe'],'dir')
            path = ['"' filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'bin' filesep 'R.exe"'];
        elseif exist([filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'Rscript.exe'],'dir')
            path = ['"' filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'Rscript.exe"']; 
        else
            error('OmicsData/Rlink/Rinit.m: Change your home directory of R here. You can find the directory by R.home() in R.')
        end
        if ~exist(libpath,'var') || ~exist(libpath,'dir')
            OPENR.myLibPath = '~/R_library';
        end
    % Knechte
    elseif exist('/usr/bin/R','file')
        path = '/usr/bin/R'; 
    % Cluster with personal R library
    elseif exist('R_libs','file') || exist('R_library','file')
        path = 'R'; 
    else
        error('OmicsData/Rcall/Rinit.m: Define your home directory of R in Rinit(Rlibraries,Rpath,Rlibrarypath). You can find the directory by R.home() in R.')
    end