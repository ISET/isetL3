%% s_L3ExpCFALayouts
%
% This script shows how to train and create an L3 camera for different CFA 
% layouts.
%
% (c) Stanford VISTA Team

clear, clc, close all

% Start ISET
s_initISET
dataroot = '/biac4/wandell/data/qytian/L3Project';

%% Various CFA patterns
kodak = [4, 3, 4, 2; 3, 4, 2, 4; 4, 2, 4, 1; 2, 4, 1, 4];
sony = [4, 3, 4, 2; 1, 4, 2, 4; 4, 2, 4, 3; 2, 4, 1, 4];
bayer = [1, 2; 2, 3];

%% Train L3

% Create and initialize L3 structure
L3 = L3Initialize();  % use default parameters

% Change CFA pattern for L3 structure
cfaPattern = kodak;
sensorD = L3Get(L3,'sensordesign');
sensorD = sensorSet(sensorD, 'cfa pattern', cfaPattern);
L3 = L3Set(L3,'design sensor', sensorD);

% Perform training
L3 = L3Train(L3);

% Save L3
name = 'L3_kodak';
L3 = L3Set(L3, 'name', name);
saveL3 = fullfile(dataroot, 'l3', [L3Get(L3, 'name') '.mat']);
save(saveL3, 'L3');

%% Setup L3 camera
camera = L3CameraCreate(L3);

%% Use the camera with s_L3render, cameraCompute, or cameraComputesRGB
