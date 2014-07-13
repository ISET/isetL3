function L3 = L3InitTrainingScenes(L3)

% Initialize training scenes and parameters.
%
%   L3 = L3InitTrainingScenes(L3);
%
%
% The default settings for the training scenes are
%   All .mat files in L3rootpath\Data\Scenes
%
% (c) Stanford VISTA Team 2013


%% Load scenes
sceneFolder = fullfile(L3rootpath,'data','scenes');
hfov = 10; % hfov is horizontal field of view in degrees, default is 10
scenes = L3LoadTrainingScenes(sceneFolder, hfov);

%% Store in L3 structure
L3 = L3Set(L3,'scene', scenes);

%% End