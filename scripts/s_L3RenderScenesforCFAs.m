%% s_L3RenderScenesforCFAs
%
% This script renders images for a series L3 cameras.
%
% For each camera all parameters are identical except the CFA that is used.
% All parameters are specified in L3TrainCameraforCFA.
%
% (c) Stanford VISTA Team

s_initISET

%% File locations
% An image will be rendered for each of the .mat files in the following
% directory which should contain a CFA.
cameraFiles = dir(fullfile(L3rootpath, 'cameras', 'L3', '*.mat'));

% All images will be saved in the following subfolder of the images
% folder.  The filename will be srgbResult_XXX where XXX is the camera filename.
saveFolder = fullfile(L3rootpath, 'images', 'L3');

%% If it doesn't exist, create the folder where files will be saved
if exist(saveFolder, 'dir')~=7
    mkdir(saveFolder)
end

%% Load scene
dataroot = '/biac4/wandell/data/qytian/L3Project';
loadScene = fullfile(dataroot, 'scene', 'AsianWoman_1.mat');
scene = sceneFromFile(loadScene, 'multispectral');
sz = sceneGet(scene, 'size');
meanLum = 1;

%% Render image for each camera 
for cameraFilenum = 1:length(cameraFiles)
    cameraFile = cameraFiles(cameraFilenum).name;
    disp(['camera:  ', cameraFile, '  ', num2str(cameraFilenum),' / ', num2str(length(cameraFiles))])    
    load(cameraFile);
    [srgbResult, idealResult] = cameraComputesrgb(camera, scene, meanLum, sz);
    
    [pathstr,name,ext] = fileparts(cameraFile); 
    saveFile = fullfile(saveFolder, ['srgbResult_' name '_lum' num2str(meanLum) '.png']);
    imwrite(srgbResult, saveFile);
end