clear, clc, close all

%% Initialize iset
s_initISET

%% Load camera
load('L3camera_fb_30.mat');

%% Read FB raw images
fName = fullfile(fbRootPath,'data', 'images', 'sunny', '001_Sunny_f16.0.RAW');
fbSensor = fbRead(fName);
camera.sensor = fbSensor;

%%
[camera,lrgbResult] = cameraCompute(camera, 'sensor');

% arbitrary scaling
lrgbResult = lrgbResult / max(lrgbResult(:));

srgbResult = lrgb2srgb(ieClip(lrgbResult,0,1));

srgbResult90 = [];
for colornum = 1:3
    srgbResult90(:,:,colornum) = rot90(srgbResult(:,:,colornum),-1);
end

figure, imshow(srgbResult90)
imwrite(srgbResult90, 'srgb_30.png');