function scenes = loadScenes(scenePath, format, idxScene, varargin)
% Load selected scenes
%
%
%
% ZhengLyu, SCIEN Team, 2018

%
%{
 scenePath = fullfile(huaquadrootpath,'local','scenes')
 format = 'mat';
 loadScenes(scenePath,format,[1 2]);
%}
%%

fileName = strcat('*.', format);

% filePath = fullfile(scenePath, fileName);
filesToLoad = dir(fullfile(scenePath,fileName));
nFiles = length(idxScene);
scenes = cell(nFiles, 1);

for ii = 1:nFiles
    sceneName  = fullfile(scenePath,filesToLoad(idxScene(ii)).name);
    scenes{ii} = load(sceneName);
    scenes{ii} = sceneSet(scenes{ii}, 'fov', 10);
end

end