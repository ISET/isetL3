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
meanLuminance = 200;

sz = sceneGet(scene, 'size');

[srgbfull, idealfull, rawfull, rxbxgxcamera, lrgbIdeal] = cameraComputesrgb(rxbxgxcamera, scene, meanLuminance, sz, [], 1, 2);
imwrite(srgbfull, 'srgbfull.png');
imwrite(idealfull, 'idealfull.png');


%%
rawlow = rawfull(1 : 2 : end, 1 : 2 : end);

%%
bayersensor = cameraGet(bayercamera, 'sensor');
bayersensor = sensorSet(bayersensor,'volts', rawlow);
bayercamera = cameraSet(bayercamera, 'sensor', bayersensor);

bayercamera = cameraSet(bayercamera,'vci name','L3');
[bayercamera, lrgbL3] = cameraCompute(bayercamera, 'sensor'); % sensor image is already loaded into the camera

lrgbL3scaled = lrgbL3 / mean(lrgbL3(:)) * mean(lrgbIdeal(:));
srgblow = lrgb2srgb(ieClip(lrgbL3scaled,0,1));

imwrite(srgblow, 'srgblow.png');

srgbnear = imresize(srgblow, 2, 'nearest');
srgbbi = imresize(srgblow, 2, 'bilinear');
imwrite(srgbnear, 'srgbnear.png');
imwrite(srgbbi, 'srgbbi.png');



