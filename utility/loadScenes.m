function scenes = loadScenes(scenePath, format, idxScene, varargin)
%% loadScenes

%% 
curPath = pwd;
cd(scenePath);
fileName = strcat('*.', format);
filesToLoad = dir(fileName);
nFiles = length(filesToLoad);


scenes = cell(length(idxScene), 1);

for ii = 1 : length(idxScene)

    sceneName = filesToLoad(idxScene(ii)).name;
    scenes{ii} = load(sceneName);
end

cd(curPath);
end