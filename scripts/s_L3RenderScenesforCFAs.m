%% s_L3RenderScenesforCFAs
%
% This script renders images for a series L3 cameras.
%
% For each camera all parameters are identical except the CFA that is used.
% All parameters are specified in L3TrainCameraforCFA.
%
% (c) Stanford VISTA Team

%%
s_initISET

%% Specify the directory that contain camera files.
cameraFolder = fullfile(L3rootpath, 'cameras', 'L3');
cameraFiles = dir(fullfile(cameraFolder, '*.mat'));

%% Load scene
scene = sceneFromFile('StuffedAnimals_tungsten-hdrs','multispectral');
% scene = sceneCreate('zone plate',[1000,1000]); %sz = number of pixels of scene
% scene = sceneCreate('freq orient');
% scene = sceneCreate('moire orient');
% scene = sceneCreate('macbethd65');

%% Specify luminance levels
luminances = [1, 80];

%% Render images
sz = sceneGet(scene, 'size');

for cameraFilenum = 1:length(cameraFiles)
    cameraFile = cameraFiles(cameraFilenum).name;
    [pathstr,cameraname,ext] = fileparts(cameraFile); 
    disp(['camera:  ', cameraFile, '  ', num2str(cameraFilenum),' / ', num2str(length(cameraFiles))])    
    load(cameraFile, 'camera');
    
    sensorShowCFA(cameraGet(camera,'sensor'));
    for lum = luminances
        srgbResult = cameraComputesrgb(camera, scene, lum, sz, [], [], 1);
    end
end
