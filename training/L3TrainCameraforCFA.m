function L3camera = L3TrainCameraforCFA(cfaFile)

% This function creates an L3 camera for a specified CFA file.
%
% L3camera = L3TrainCameraforCFA(cfaFile)
%
% Besides the CFA, all values for the camera are specified inside this
% function.  The idea is that we will fix a set of values for training scenes,
% optics, sensor, and L3 parameters and investigate the impact of the CFA
% only.  This function easily enables this.
% 
% This is modeled after s_L3TrainCamera.
%
% (c) Stanford VISTA Team


%% Create and initialize L3 structure
L3 = L3Initialize();  % use default parameters

%% Change CFA
scenes = L3Get(L3,'scene');
wave = sceneGet(scenes{1}, 'wave');   %use the wavelength samples from the first scene

sensorD = L3Get(L3,'design sensor');
cfaData = load(cfaFile);
sensorD = sensorSet(sensorD,'filterspectra',vcReadSpectra(cfaFile,wave));
sensorD = sensorSet(sensorD,'filter names',cfaData.filterNames);
sensorD = sensorSet(sensorD,'cfa pattern and size',cfaData.filterOrder);
L3 = L3Set(L3,'design sensor', sensorD);

sensorM = L3Get(L3,'monochrome sensor');
sz = sensorGet(sensorD, 'sensor size');
sensorM = sensorSet(sensorM, 'sensor size', sz);
L3 = L3Set(L3,'monochrome sensor', sensorM);

%% Perform training
L3 = L3Train(L3);

%% Setup L3 camera
L3camera = L3CameraCreate(L3);

%% Use the camera with s_L3render, cameraCompute, or cameraComputesRGB
