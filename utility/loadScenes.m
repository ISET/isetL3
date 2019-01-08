function scenes = loadScenes(scenePath, format, idxScene, varargin)
%% loadScenes

%% 

fileName = strcat('*.', format);


filePath = fullfile(scenePath, fileName);
filesToLoad = dir(filePath);
nFiles = length(filesToLoad);
scenes = cell(length(idxScene), 1);

for ii = 1 : length(idxScene)

    sceneName = filesToLoad(idxScene(ii)).name;
    scenes{ii} = load(sceneName);
    scenes{ii} = sceneSet(scenes{ii}, 'fov', 10);
end


end