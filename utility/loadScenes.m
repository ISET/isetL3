function scenes = loadScenes(scenePath, format, nScenes,varargin)
%% loadScenes

%% 
if ~isempty(varargin) nScenes = varargin{1}; end
cd(scenePath);
fileName = strcat('*.', format);
filesToLoad = dir(fileName);
nFiles = length(filesToLoad);

if exist('nScenes') nFiles = min(nFiles, nScenes); end
scenes = cell(nFiles, 1);

for ii = 1 : nFiles
    
    sceneName = filesToLoad(ii).name;
    scenes{ii} = load(sceneName);
end
end