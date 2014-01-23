function L3 = L3InitTrainingScenes(L3, hfov)

% Load default training scenes and parameters.
%
%   L3 = L3InitTrainingScenes(L3, hfov);
%
%   hfov is horizontal field of view in degrees
%
% The default settings for the training scenes are
%   All .mat files in L3rootpath\Data\Scenes
%
% (c) Stanford VISTA Team 2013


%% Load scenes
sceneFolder = fullfile(L3rootpath,'data','scenes');
scenes = L3LoadTrainingScenes(sceneFolder);

%% Adjust FOV
nScenes = length(scenes);
for ii=1 : nScenes
    scenes{ii} = sceneSet(scenes{ii}, 'hfov', hfov);
end

%% Store in L3 structure
L3 = L3Set(L3,'scene',scenes);

%% End