function scenes = scarletScenesLoad(varargin)
% Load multispectral scenes from Scarlet server into the scene cell array
%   scenes = scarletScenesLoad(varargin)
%
% Inputs:
%   varargin - name value parameter pairs
%
% Outputs:
%   scenes - cell array of multispectral scenes
%
% Example:
%     scenes = scarletScenesLoad();
%     scenes = scarletScenesLoad('nScenes', N); % Loads N defaults
%
% See also:
%   rdtScenesLoad
% 
% HJ/QT/BW, VISTA TEAM, 2015

% Init parameters
% default Scarlet link storing all training scenes
webdir = 'http://scarlet.stanford.edu/validation/SCIEN/L3/people_small/';
hfov = 10;              % horizontal field of view in degrees
wave = 400 : 10 : 680;  % nm

for ii = 1 : 2 : length(varargin)
    switch ieParamFormat(varargin{ii})
        case 'webdir'
            webdir = varargin{ii + 1};
        case 'nscenes'
            nScenes = varargin{ii + 1};
        case {'fov', 'hfov', }
            hfov = varargin{ii + 1};
        case {'wave', 'wavelength', 'w'}
            wave = varargin{ii + 1};
        otherwise
            error('Unknown argument %s\n',varargin{ii});
    end
end

% get scene file list
fnames = lsScarlet(webdir, '.mat');

assert(~isempty(fnames), 'None training scenes found!');

if notDefined('nScenes'), nScenes = length(fnames); end
nScenes = min(nScenes, length(fnames));

% load scene files
scenes = cell(nScenes, 1);
for ii = 1 : nScenes
    % Programming note: don't use fullfile for url because it doesn't work
    % correctly on windows machines
    fwebpath = [webdir fnames(ii).name];
    fpath = [tempname '.mat']; % writing to system temp folder
    
    urlwrite(fwebpath, fpath); % load scene file from web
    load(fpath, 'scene');
    
    scene = sceneSet(scene, 'wave', wave); % adjust wavelength
    scenes{ii} = sceneSet(scene, 'h fov', hfov); % adjust fov
    delete(fpath); % Delete tmp file locally
end

end