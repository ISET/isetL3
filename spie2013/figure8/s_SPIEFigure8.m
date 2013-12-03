%% s_SPIEFigure8
%
% This script trains L3 for different RGB/W CFA layouts.
%
%
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Train and create a L3 camera for RWBW
% Create and initialize L3 structure
L3 = L3Initialize();  % use default parameters

% Change the CFA to Aptina's new RWBW design
sensorD = L3Get(L3,'design sensor');
cfaPattern = [1 4;... 
              4 3]; 
sensorD = sensorSet(sensorD, 'cfa pattern', cfaPattern);
L3 = L3Set(L3,'design sensor', sensorD);

% Perform training
L3 = L3Train(L3);
camera = L3CameraCreate(L3); % create camera

name = 'L3camera_rwbw';
camera = cameraSet(camera, 'name', name);
save(name, 'camera'); % save camera

%% Train and create a L3 camera for Kodak
% Create and initialize L3 structure
L3 = L3Initialize();  % use default parameters

% Change the CFA to Aptina's new RWBW design
sensorD = L3Get(L3,'design sensor');
cfaPattern = [4, 3, 4, 2;...
              3, 4, 2, 4;...
              4, 2, 4, 1;...
              2, 4, 1, 4]; 
sensorD = sensorSet(sensorD, 'cfa pattern', cfaPattern);
L3 = L3Set(L3,'design sensor', sensorD);

% Perform training
L3 = L3Train(L3);
camera = L3CameraCreate(L3); % create camera

name = 'L3camera_kodak';
camera = cameraSet(camera, 'name', name);
save(name, 'camera'); % save camera


% Train and create a L3 camera for Wang
% Create and initialize L3 structure
L3 = L3Initialize();  % use default parameters

% Change the CFA to Aptina's new RWBW design
sensorD = L3Get(L3,'design sensor');
cfaPattern = [4, 1, 3, 4, 2;...
              4, 2, 4, 1, 3;...
              1, 3, 4, 2, 4;...
              2, 4, 1, 3, 4;...
              3, 4, 2, 4, 1]; 
sensorD = sensorSet(sensorD, 'cfa pattern', cfaPattern);
L3 = L3Set(L3,'design sensor', sensorD);

% Perform training
L3 = L3Train(L3);
camera = L3CameraCreate(L3); % create camera

name = 'L3camera_wang';
camera = cameraSet(camera, 'name', name);
save(name, 'camera'); % save camera

% Render images 
% Load scene
dataroot = '/biac4/wandell/data/qytian/L3Project';
loadScene = fullfile(dataroot, 'scene', 'AsianWoman_1.mat');
scene = sceneFromFile(loadScene, 'multispectral');
sz = sceneGet(scene, 'size');
meanLum = 1;

% Load camera and render images
cameraFiles = dir('*.mat');
for cameraFilenum = 1:length(cameraFiles)
    load(cameraFiles(cameraFilenum).name)
    srgbResult = cameraComputesrgb(camera, scene, meanLum, sz);
    saveFile = ['srgbResult_' cameraGet(camera, 'name') '_lum' num2str(meanLum) '.png'];
    imwrite(srgbResult, saveFile);
end

