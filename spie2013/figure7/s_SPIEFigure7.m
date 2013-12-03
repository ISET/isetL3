%% s_SPIEFigure7
%
% This script trains L3 for Bayer and RGB/W (with bias and variance 
% tradeoff) and compare results for low light and high light. 
% 
%
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Train and create a L3 camera for Bayer pattern
L3 = L3Initialize(); % use default parameters
sensorD = L3Get(L3,'design sensor');

cfaPattern = [1 2; 2 3]; % change to Bayer pattern
sensorD = sensorSet(sensorD, 'cfa pattern', cfaPattern);
L3 = L3Set(L3,'design sensor', sensorD);

L3 = L3Train(L3); % train L3
camera = L3CameraCreate(L3); % create camera

name = 'L3camera_bayer';
camera = cameraSet(camera, 'name', name);
save(name, 'camera'); % save camera

%% Train and create a L3 camera for RGBW pattern with bias and variance
% tradeoff
L3 = L3Initialize();  % use default parameters

A = L3findRGBWcolortransform(L3); % find color space conversion matrix
L3 = L3Set(L3, 'weight color transform', A);

% Set optimal bias and variance tradeoff weights
weights = [1, 1, 1];  
L3 = L3Set(L3, 'global weight bias variance', weights);
weights = [4, 16, 4]; 
L3 = L3Set(L3, 'flat weight bias variance', weights);
weights = [4, 1, 4]; 
L3 = L3Set(L3, 'texture weight bias variance', weights);

L3 = L3Train(L3); % train L3
camera = L3CameraCreate(L3); % create camera

name = 'L3camera_rgbw_tradeoff';
camera = cameraSet(camera, 'name', name);
save(name, 'camera'); % save camera

%% Render images
% Load scene
dataroot = '/biac4/wandell/data/qytian/L3Project';
loadScene = fullfile(dataroot, 'scene', 'AsianWoman_1.mat');
scene = sceneFromFile(loadScene, 'multispectral');
sz = sceneGet(scene, 'size');

% Load cameras
load('L3camera_bayer.mat', 'camera');
L3camera_bayer = camera; 
load('L3camera_rgbw_tradeoff.mat', 'camera');
L3camera_rgbw_tradeoff = camera;

% render images
luminances = [1, 80];
 for ii = 1 : length(luminances)
    meanLum = luminances(ii); 
    srgbResult_bayer = cameraComputesrgb(L3camera_bayer, scene, meanLum, sz);
    srgbResult_rgbw_tradeoff = cameraComputesrgb(L3camera_rgbw_tradeoff, scene, meanLum, sz);
    
    saveFile = ['srgbResult_bayer_lum' num2str(meanLum) '.png'];
    imwrite(srgbResult_bayer, saveFile);
    
    saveFile = ['srgbResult_rgbw_tradeoff_lum' num2str(meanLum) '.png'];
    imwrite(srgbResult_rgbw_tradeoff, saveFile);
 end
 
 
 
 
 
 
 
 