%% s_L3RenderScenesforCFAs
%
% This script renders images for a series L3 cameras.
%
% For each camera all parameters are identical except the CFA that is used.
% All parameters are specified in L3TrainCameraforCFA.
%
% (c) Stanford VISTA Team

%%
% s_initISET

%% File locations
% Specify the directory that contain camera files.
cameraFolder = fullfile(L3rootpath, 'cameras', 'L3');

% Specify the directory that contain scene files.
sceneFolder = '/biac4/wandell/data/qytian/L3Project/scene';

% Specify the directory in which the rendered images will be saved.
saveFolder = '/biac4/wandell/data/qytian/L3Project/spie2013/figure8';

% If it doesn't exist, create the folder where files will be saved
if exist(saveFolder, 'dir')~=7
    mkdir(saveFolder)
end

cameraFiles = dir(fullfile(cameraFolder, '*.mat'));
sceneFiles = dir(fullfile(sceneFolder, '*.mat'));

%% Render image for each scene, camera and luminance
luminances = [200];

for sceneFilenum = 1:length(sceneFiles)
    sceneFile = sceneFiles(sceneFilenum).name;
    [pathstr,scenename,ext] = fileparts(sceneFile);
    disp(['scene:  ', sceneFile, '  ', num2str(sceneFilenum),' / ', num2str(length(sceneFiles))])    
    loadFile = fullfile(sceneFolder, sceneFile);
    scene = sceneFromFile(loadFile, 'multispectral');
    sz = sceneGet(scene, 'size');
    
    for cameraFilenum = 1:length(cameraFiles)
        cameraFile = cameraFiles(cameraFilenum).name;
        [pathstr,cameraname,ext] = fileparts(cameraFile); 
        disp(['camera:  ', cameraFile, '  ', num2str(cameraFilenum),' / ', num2str(length(cameraFiles))])    
        load(cameraFile);
        
        for lum = luminances
            [srgbResult, idealResult] = cameraComputesrgb(camera, scene, lum, sz);
            saveFile = fullfile(saveFolder, [cameraname '_' scenename '_lum' num2str(lum) '_srgb.png']);
            imwrite(srgbResult, saveFile);
        end        
    end
    saveFile = fullfile(saveFolder, [scenename '_ideal.png']);
    imwrite(idealResult, saveFile);
end