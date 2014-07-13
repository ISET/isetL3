function scenes = L3LoadTrainingScenes(sceneFolder, hfov)
%
% Load training scenes for L3 training. This function can be used to load
% training scenes from any directory when initialize L3 structure. 
%
% scenes = L3LoadTrainingScenes(sceneFolder, hfov)
%
% INPUT:
%   sceneFolder:  String giving folder that contains all scenes to use
%                 All .mat files in folder must be scene files
%   hfov: Horizontal field of view in degrees
%
% OUTPUT:
%   scenes: a cell array of all the stored scenes 
%
% Example:
%   scenes = L3LoadTrainingScenes(sceneFolder)
%   scenes = L3LoadTrainingScenes(sceneFolder)
%
% (c) Stanford VISTA Team 2013

if ieNotDefined('sceneFolder') || isempty(sceneFolder) || ~ischar(sceneFolder)
    error('Scenes directory needed.')
end
        
sceneNames = dir([sceneFolder,filesep,'*.mat']);
nScenes = length(sceneNames);
scenes = cell(nScenes,1);
for ii=1:nScenes
    thisName  = fullfile(sceneFolder,sceneNames(ii).name);
    data = load(thisName,'scene');
    scenes{ii}  = data.scene;
end

%% Adjust FOV if hfov is specified
if exist('hfov','var')
    nScenes = length(scenes);
    for ii=1 : nScenes
        scenes{ii} = sceneSet(scenes{ii}, 'hfov', hfov);
    end
end