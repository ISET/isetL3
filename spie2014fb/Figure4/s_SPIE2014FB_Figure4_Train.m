%% s_SPIE2014FB_Figure4_Train
%
% This script performs L3 training module for the five-band camera for
% Figure 4 of 2014 SPIE paper.
%
% (c) Stanford VISTA Team, Jan 2015

clear, clc, close all

%% Start ISET
s_initISET

%% Create and initialize L3 structure
L3 = L3Initialize();
scenes = L3Get(L3,'scene');
wave = sceneGet(scenes{1}, 'wave'); 
expIdx = 1; 
[sensor, optics] = fbCreate(wave', expIdx);

oi = oiCreate;
oi = oiSet(oi,'optics',optics);
oi = oiSet(oi,'name','fb optics');

%% Use the default sensor of L3 initialization
L3sensor = L3Get(L3, 'design sensor');
L3sensor = sensorSet(L3sensor, 'color', sensorGet(sensor, 'color'));
L3sensor = sensorSet(L3sensor, 'cfa', sensorGet(sensor, 'cfa'));
L3 = L3Set(L3, 'design sensor', L3sensor);

%% Perform training
tic
L3 = L3Train(L3);
toc
%% Setup L3 camera
camera = L3CameraCreate(L3);

%% Save data
save(fullfile(L3rootpath, 'spie2014fb', 'Figure4', 'L3camera_fb.mat'), 'camera');