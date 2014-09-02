%% This script is to render images on a real five-band camera using 
% different methods: L3, ISET basic pipeline. In the final paper we will
% test also guided filter.
%
%
%
%
% (c) Stanford Vista Team 2014

clear, clc, close all

%% Initialize ISET
s_initISET

%% Load camera
load('L3camera_fb_D652D65_expIdx4_OC=0.mat');
L3 = cameraGet(camera, 'l3');

%% Load fb raw images
dataRootPath = '/biac4/wandell/users/hblasins/5BD_Faces';
expIdx = 1; 
sceneName = ['QT_2.8_Daylight_exp_' num2str(expIdx)];
fName = fullfile(dataRootPath, [sceneName '.mat']);
% fName = 'Daylight_exp_3.mat';
load(fName);

%% Set sensor image
fbSensor = cameraGet(camera, 'sensor');
fbSensor = sensorSet(fbSensor,'volts',RAW);
camera = cameraSet(camera, 'sensor', fbSensor);

%% Calculate L3 result
camera = cameraSet(camera,'vci name','L3');
[camera,lrgbL3] = cameraCompute(camera, 'sensor'); % sensor image is already loaded into the camera

% Calculate basic ISET pipeline result 
camera = cameraSet(camera,'vci name','default');
[camera, lrgbBasic] = cameraCompute(camera,'sensor');

%% Crop border
lrgbL3 = L3imcrop(L3, lrgbL3); 
lrgbBasic = L3imcrop(L3, lrgbBasic); 

%% Scale and convert to sRGB
meanLuminance = 0.8;
lrgbL3scaled = lrgbL3 / max(lrgbL3(:)) * meanLuminance;
lrgbBasicscaled = lrgbBasic / max(lrgbBasic(:)) * meanLuminance;

srgbL3 = lrgb2srgb(ieClip(lrgbL3scaled,0,1));
srgbBasic = lrgb2srgb(ieClip(lrgbBasicscaled,0,1));

%% Show results
figure, imshow(srgbL3), title('L3')
figure, imshow(srgbBasic), title('ISET Basic')

%% Save results
imwrite(srgbL3, [sceneName '_srgb_physical_L3_lum_', num2str(meanLuminance), '_DAYLIGHT_OC=0.png']);
imwrite(srgbBasic, [sceneName '_srgb_physical_Basic_lum_', num2str(meanLuminance), '_DAYLIGHT_OC=0.png']);






