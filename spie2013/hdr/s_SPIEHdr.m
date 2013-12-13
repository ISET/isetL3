%% s_SPIEHdr
%
% This script compare Bayer and RGBW for HDR scene.
% 
%
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Load pre-trained cameras
load(fullfile(L3rootpath,'cameras','L3','L3camera_Bayer.mat')); 
L3camera_Bayer = camera;
L3camera_Bayer = cameraSet(L3camera_Bayer, 'name', 'L3camera_Bayer');

load(fullfile(L3rootpath,'cameras','L3','L3camera_RGBW1.mat')); 
L3camera_RGBW = camera;
L3camera_RGBW = cameraSet(L3camera_RGBW, 'name', 'L3camera_RGBW');

%% Load scene
scene = sceneFromFile([isetRootPath, '/data/images/multispectral/Feng_Office-hdrs.mat'], 'multispectral');
sz = sceneGet(scene, 'size');

%% Change exposure times
expo = 0.06;
sensor = cameraGet(L3camera_Bayer, 'sensor');
sensor = sensorSet(sensor, 'exposure time', expo);
L3camera_Bayer = cameraSet(L3camera_Bayer, 'sensor', sensor);

sensor = cameraGet(L3camera_RGBW, 'sensor');
sensor = sensorSet(sensor, 'exposure time', expo);
L3camera_RGBW = cameraSet(L3camera_RGBW, 'sensor', sensor);

%% Render images
lum = 50;
[srgbResult_Bayer, idealResult] = cameraComputesrgb(L3camera_Bayer, scene, lum, sz);
[srgbResult_RGBW, idealResult] = cameraComputesrgb(L3camera_RGBW, scene, lum, sz);

%% Save images
saveFile = ['srgbResult_Bayer_lum' num2str(lum) '_expo' num2str(expo) '.png'];
imwrite(srgbResult_Bayer, saveFile);

saveFile = ['srgbResult_RGBW_lum' num2str(lum) '_expo' num2str(expo) '.png'];
imwrite(srgbResult_RGBW, saveFile);

imwrite(idealResult, 'idealResult.png');

%% Save images in .mat
saveFile = ['srgbResult_Bayer_lum' num2str(lum) '_expo' num2str(expo)];
save(saveFile, 'srgbResult_Bayer')

saveFile = ['srgbResult_RGBW_lum' num2str(lum) '_expo' num2str(expo)];
save(saveFile, 'srgbResult_RGBW')

 
 
 
 
 
 
 
 