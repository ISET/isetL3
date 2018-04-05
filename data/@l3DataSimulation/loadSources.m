function sources = loadSources(obj, nImg, type, varargin)
% load sources (scene / oi) for l3DataSimulation class
%   sources = loadSources(nImg, type, varargin)
%
% Inputs:
%   obj  - l3DataSimulation object instance
%   nImg - number of sources to be loaded. By default, we load all things
%          available
%   type - what kind of sources to be loaded. Can be chosen from 'scene',
%          'oi' or 'all' (default). When type is 'all', we load scenes
%          first
%
% Outputs:
%   sources - cell array of scenes and optical images
%
% See also:
%   scarletScenesLoad, rdtScenesLoad, rdtOILoad
%
% HJ, VISTA TEAM, 2015

% Check inputs
if notDefined('nImg'), nImg = inf; end
if notDefined('type'), type = 'all'; end
sources = {};

% Load scenes from remote server
if strcmp(type, 'all') || strcmp(type, 'scene')
    try
        % fprintf('Trying from RDT/SCIEN\n');
        sources = rdtScenesLoad('nScenes', nImg);
    catch
        fprintf('Load from RemoteDataToolbox server failed.');
        fprintf('Trying using scarlet server\n');
        sources = scarletScenesLoad('nScenes', nImg);
    end
    nImg = nImg - length(sources);
end

% Load oi from remote sever
if strcmp(type, 'all') || strcmp(type, 'oi')
    % Combine the oi cell array with the scene cell array
    sources = cat(1, sources, rdtOILoad('nOI', nImg));
end

obj.sources = sources;
end