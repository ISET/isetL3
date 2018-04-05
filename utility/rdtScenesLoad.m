function scenes = rdtScenesLoad(varargin)
% Load multispectral data from the open repository
%
%   scenes = rdtScenesLoad(varargin)
%
% Inputs:
%   varargin - name value pairs for the parameters
%
% Outputs:
%   scenes - cell array of multispectral scenes
%
% Example:
%     scenes = rdtScenesLoad();
%     scenes = rdtScenesLoad('nScenes', 1); % Loads 1 scenes
%
% See also:
%   scarletScenesLoad
% 
% HJ/BW, VISTA TEAM, 2015

%% Parse input parameters
p = inputParser;
p.addParameter('nScenes', inf);
p.addParameter('wave', 400:10:680);
p.addParameter('rdtConfigName', 'scien');
p.addParameter('fov', 10);
p.parse(varargin{:});

nScenes = p.Results.nScenes;
wave    = p.Results.wave;
rdtName = p.Results.rdtConfigName;
fov     = p.Results.fov;

%% Init remote data toolbox client
rdt = RdtClient(rdtName);  % using rdt-config-scien.json configuration file
rdt.crp('/L3/faces');
files = rdt.listArtifacts();
nScenes = min(nScenes, length(files));

% load scene files
scenes = cell(nScenes, 1);
for ii = 1 : nScenes
    data = rdt.readArtifact(files(ii).artifactId);
    scene = sceneSet(data.scene, 'wave', wave); % adjust wavelength
    scenes{ii} = sceneSet(scene, 'h fov', fov);
end

end