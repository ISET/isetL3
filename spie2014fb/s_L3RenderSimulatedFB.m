%% This script is to render images on a simulated five-band camera using 
% different methods: L3, ISET basic pipeline. In the final paper we will
% test also guided filter and compute some metrics potentially.
%
%
%
%
% (c) Stanford Vista Team 2014

clear, clc, close all

%% Initialize ISET
s_initISET

%% Load camera with L3 stored
load('L3camera_fb_D652D65.mat');
L3 = cameraGet(camera, 'l3');

%% Load scene
dataRootPath = '/biac4/wandell/data/qytian/L3Project/scene';
sceneName = 'FosterBuilding-photons'; 
% eg scenes: AsianWoman_1, VegetablesCalibNIR, FosterBuilding-photons
fName = fullfile(dataRootPath, [sceneName '.mat']);
scene = sceneFromFile(fName,'multispectral');

%% Adjust camera sensor size to the spectral scene size
sz = sceneGet(scene, 'size');
camera = cameraSet(camera,'sensor size',sz);

%% Adjust scene
% Adjust scene wavelength samples to match the camera
wave = cameraGet(camera,'sensor wave');
scene = sceneSet(scene,'wave',wave');

% Change illuminant to the rendering illuminant that matches the stored L3
illum = L3Get(L3, 'training illuminant');
scene = sceneAdjustIlluminant(scene, illum);

% Set scene FOV to camera FOV
fov = cameraGet(camera, 'sensor hfov');
scene = sceneSet(scene,'hfov',fov);

% Set mean luminance
meanLuminance = 400;
scene = sceneAdjustLuminance(scene, meanLuminance);

%% Simulation
% Calculate ideal XYZ image
[camera, xyzIdeal] = cameraCompute(camera, scene, 'idealxyz');
xyzIdeal = xyzIdeal/max(xyzIdeal(:)); %scale to full display range

% Calculate L3 result
camera = cameraSet(camera,'vci name','L3');
[camera, lrgbL3] = cameraCompute(camera,'oi'); % OI is already calculated when calculate xyzIdeal

% Calculate basic ISET pipeline result 
camera = cameraSet(camera,'vci name','default');
[camera, lrgbBasic] = cameraCompute(camera,'sensor');

%% Crop image borders
xyzIdeal = L3imcrop(L3, xyzIdeal); 
lrgbL3 = L3imcrop(L3, lrgbL3);
lrgbBasic = L3imcrop(L3, lrgbBasic);

%% Scale and convert to sRGB
[srgbIdeal, lrgbIdeal] = xyz2srgb(xyzIdeal);

lrgbL3scaled = lrgbL3 * mean(lrgbIdeal(:)) / mean(lrgbL3(:));
lrgbBasicscaled = lrgbBasic * mean(lrgbIdeal(:)) / mean(lrgbBasic(:));

srgbL3 = lrgb2srgb(ieClip(lrgbL3scaled, 0, 1));
srgbBasic = lrgb2srgb(ieClip(lrgbBasicscaled, 0, 1));

%% Show results
figure, imshow(srgbIdeal), title('Ideal')
figure, imshow(srgbL3), title('L3')
figure, imshow(srgbBasic), title('ISET Basic')

%% Save results
imwrite(srgbIdeal, [sceneName '_srgb_simulation_Ideal_lum_', num2str(meanLuminance), '.png']);
imwrite(srgbL3, [sceneName '_srgb_simulation_L3_lum_', num2str(meanLuminance), '.png']);
imwrite(srgbBasic, [sceneName '_srgb_simulation_Basic_lum_', num2str(meanLuminance), '.png']);
