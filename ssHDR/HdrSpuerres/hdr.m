%% s_SPIEHdr
%
% This script compare Bayer and RGBW for HDR scene.
% 
%
%
% (c) Stanford VISTA Team

%% Start ISET
clear, clc, close all;
s_initISET

%% Load pre-trained cameras
load('L3camera_HDRcy.mat'); 

%% Load scene
scene = sceneFromFile([isetRootPath, '/data/images/multispectral/Feng_Office-hdrs.mat'], 'multispectral');
sz = sceneGet(scene, 'size');
meanLuminance = 60;

%% Change exposure times
expo = 0.095;
sensor = cameraGet(camera, 'sensor');
sensor = sensorSet(sensor, 'exposure time', expo);
camera = cameraSet(camera, 'sensor', sensor);

%% Render images

[srgb, ideal, raw, camera] = cameraComputesrgb(camera, scene, meanLuminance, sz, [], 1, 2);

%% Save images in .mat
imwrite(srgb, 'srgbResult_HDRcy_exp0.095.png');

%%
% scene = sceneAdjustLuminance(scene, meanLuminance);
% scene = sceneSet(scene,'fov',30);
% [camera, xyzIdeal] = cameraCompute(camera, scene, 'idealxyz');
% xyzIdeal = xyzIdeal/max(xyzIdeal(:)); %scale to full display range
% [srgbIdeal, lrgbIdeal] = xyz2srgb(xyzIdeal);

% Calculate L3 result
% camera = cameraSet(camera,'vci name','L3');
% [camera, lrgbL3] = cameraCompute(camera,'oi'); % OI is already calculated when calculate xyzIdeal
% 
% % Calculate basic ISET pipeline result 
% camera = cameraSet(camera,'vci name','default');
% [camera, lrgbBasic] = cameraCompute(camera,'sensor');


%% Scale and convert to sRGB
% [srgbIdeal, lrgbIdeal] = xyz2srgb(xyzIdeal);

% lrgbL3scaled = lrgbL3 * mean(lrgbIdeal(:)) / mean(lrgbL3(:));
% lrgbBasicscaled = lrgbBasic * mean(lrgbIdeal(:)) / mean(lrgbBasic(:));
% 
% srgbL3 = lrgb2srgb(ieClip(lrgbL3scaled, 0, 1));
% srgbBasic = lrgb2srgb(ieClip(lrgbBasicscaled, 0, 1));

%% Show results
% figure, imshow(srgbIdeal), title('Ideal')
% figure, imshow(srgbL3), title('L3')
% figure, imshow(srgbBasic), title('ISET Basic')
%%
% [srgb, ideal, raw, camera] = cameraComputesrgb(camera, scene, lum, sz, [], 1, 2);
% figure, imshow(srgb)


% %% Save images
% saveFile = ['srgbResult_Bayer_lum' num2str(lum) '_expo' num2str(expo) '.png'];
% imwrite(srgbResult_Bayer, saveFile);
% 
% saveFile = ['srgbResult_RGBW_lum' num2str(lum) '_expo' num2str(expo) '.png'];
% imwrite(srgbResult_RGBW, saveFile);

%% Save images in .mat
% saveFile = ['srgbResult_Bayer_lum' num2str(lum) '_expo' num2str(expo)];
% save(saveFile, 'srgbResult_Bayer')
% 
% saveFile = ['srgbResult_RGBW_lum' num2str(lum) '_expo' num2str(expo)];
% save(saveFile, 'srgbResult_RGBW')

 
 
 
 
 
 
 
 
