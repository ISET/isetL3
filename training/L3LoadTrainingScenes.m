function scenes = L3LoadTrainingScenes(sceneFolder)

% Load stored training scenes for L3 training 
%
% scenes = L3LoadTrainingScenes(sceneFolder)
%
% INPUT:
%   sceneFolder:  String giving folder that contains all scenes to use
%                 All .mat files in folder must be scene files
%
% OUTPUT:
%   scenes: a cell array of all the stored scenes 
%
% Example:
%   scenes = L3LoadTrainingScenes(sceneFolder)
%
% (c) Stanford VISTA Team 2013


sceneNames = dir([sceneFolder,filesep,'*.mat']);
nScenes = length(sceneNames);
scenes = cell(nScenes,1);
for ii=1:nScenes
    thisName  = fullfile(sceneFolder,sceneNames(ii).name);
    data = load(thisName,'scene');
    scenes{ii}  = data.scene;
end
