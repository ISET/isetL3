function sources = loadSources(obj, nImg, type, varargin)
% load sources (scene / oi) for l3DataSimulation class
%
%   sources = loadSources(nImg, type, varargin)
%
% Inputs:
%   obj  - l3DataSimulation object instance
%   nImg - number of sources to be loaded. By default, we load all
%          available objects of that type.
%   type - what kind of sources to be loaded. Can be chosen from 'scene',
%          'oi' or 'all' (default). When type is 'all', we load 'scenes'
%          first and then 'oi'
%
% Outputs:
%   sources - cell array of scenes and optical images
%
% HJ, VISTA TEAM, 2015
%
% See also:
%   rdtScenesLoad, rdtOILoad

%% Check inputs
if notDefined('nImg'), nImg = inf; end
if notDefined('type'), type = 'all'; end
sources = {};

type = ieParamFormat(type);
%% Load scenes from remote server
switch type
    case {'all'}
        
        sources = rdtScenesLoad('nScenes', nImg);
        nImg = nImg - length(sources);
        
        % Combine the oi cell array with the scene cell array
        if nImg > 0
            sources = cat(1, sources, rdtOILoad('nOI', nImg));
        end
        
    case {'scene'}
        sources = rdtScenesLoad('nScenes', nImg);

    case {'oi'}
        sources = cat(1, sources, rdtOILoad('nOI', nImg));
        
    otherwise
        error('Unknown type %s\n',type);
end

% It appears that the sources can be a cell array of ISETCAM scenes and
% ois.  That's interesting and surprising. (BW).
obj.sources = sources;

end