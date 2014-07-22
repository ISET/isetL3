function L3Path(L3Dir)
% Set Matlab directory path for L3
%
%     L3Path(L3Dir)
%
% Set up the path to the functions and data called by L3.  Place this
% function in a location that is in the Matlab path at start-up.  When
% you wish to initialize the L3 path, or add a path for one of the
% tools boxes, call this function.
%
% Many people simply change to the L3 root directory and type
% L3Path(pwd)
%
% Another possibility is to include the L3 root directory on your
% path, and then invoke L3Path(L3RootPath).
%
% We recommend against putting the entire L3 distribution on your path,
% permanently. The reason is this:  Future distributions may change a
% directory organization. In that case, you may get path errors or other
% problems when you change distributions.
%
% Examples:
%   L3Dir = 'c:\myhome\Matlab\L3'; L3Path(L3Dir);
%   cd c:\myhome\Matlab\L3;          L3Path(pwd);
%
% copyfileright ImagEval Consultants, LLC, 2003.

fprintf('L3 root directory: %s\n',L3Dir)

% Adds the root directory of the L3 tree to the user's path
addpath(L3Dir);

% Generates a list of the directories below the L3 tree.
p = genpath(L3RootPath);

% Adds all of the directories to the user's path.
addpath(p);

% Refreshes the path.
path(path);

% For people using the svn version - ask for: svnRemovePath;
% to eliminate the svn directories from the matlab path.

% We must have the proper DLL on the path.  This depends on the version
% number.  We may need to elaborate this section of the code in the future.
version = ver('Matlab');
v = version.Version(1:3);
versionNumber = str2num(v);

if versionNumber < 7, error('L3 requires version 7 or higher'); end

return;
