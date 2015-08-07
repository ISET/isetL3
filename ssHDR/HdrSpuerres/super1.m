%% Start ISET
clear, clc, close all;
s_initISET

%% Load pre-trained cameras
load('L3camera_Bayer.mat'); 
bayercamera = camera;
load('L3camera_RxGxBx.mat'); 
rxbxgxcamera = camera;

%% Load scene
scene = sceneFromFile('StuffedAnimals_tungsten-hdrs','multispectral');
meanLuminance = 100;

sz = sceneGet(scene, 'size');

[srgbfull, idealfull, rawfull, bayercamera, lrgbIdeal] = cameraComputesrgb(bayercamera, scene, meanLuminance, sz, [], 1, 2);
imwrite(srgbfull, 'srgbfull.png');
imwrite(idealfull, 'idealfull.png');
% figure, imagesc(rawlow);

%%
sz = sceneGet(scene, 'size') / 2;

[srgblow, ideallow, rawlow, bayercamera] = cameraComputesrgb(bayercamera, scene, meanLuminance, sz, [], 1, 2);
imwrite(srgblow, 'srgblow.png');
imwrite(ideallow, 'ideallow.png');
% figure, imagesc(rawlow);

%%
srgbnear = imresize(srgblow, 2, 'nearest');
srgbbi = imresize(srgblow, 2, 'bilinear');
imwrite(srgbnear, 'srgbnear.png');
imwrite(srgbbi, 'srgbbi.png');

%%
rawinterp = zeros(2*size(rawlow));
rawinterp(1 : 2 : end, 1 : 2 : end) = rawlow;

%%
rxbxgxsensor = cameraGet(rxbxgxcamera, 'sensor');
rxbxgxsensor = sensorSet(rxbxgxsensor,'volts', rawinterp);
rxbxgxcamera = cameraSet(rxbxgxcamera, 'sensor', rxbxgxsensor);

rxbxgxcamera = cameraSet(rxbxgxcamera,'vci name','L3');
[rxbxgxcamera,lrgbL3] = cameraCompute(rxbxgxcamera, 'sensor'); % sensor image is already loaded into the camera

%% Scale and convert to sRGB
lrgbL3scaled = lrgbL3 / mean(lrgbL3(:)) * mean(lrgbIdeal(:));
srgbL3 = lrgb2srgb(ieClip(lrgbL3scaled,0,1));
imwrite(srgbL3, 'super.png');



