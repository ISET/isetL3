%% s_L3Train4IllumCorrection
%
% This script is to train L3 for illuminant correction: cross illuminant
% correction, global correction and local correction
%
%
% (c) Stanford Vista Team 2014

clear, clc, close all

%% Start ISET
% s_initISET

%% Illuminants and CFAs
ill = 'D65norm'; % 'D65'
cfa = 'Bayer'; % 'RGBW1'

%% Training
disp(ill)
disp(cfa)

%% Initialize L3
L3 = L3Initialize();

%% Change CFA pattern
cfaFile = fullfile(L3rootpath, 'data', 'sensors', 'CFA', 'published', [cfa '.mat']);
cfaData = load(cfaFile); % load cfa file

scenes = L3Get(L3,'scene');
wave = sceneGet(scenes{1}, 'wave'); %use the wavelength samples from the first scene

sensorD = L3Get(L3,'design sensor'); % set design sensor
sensorD = sensorSet(sensorD,'filterspectra',vcReadSpectra(cfaFile, wave));
sensorD = sensorSet(sensorD,'filter names',cfaData.filterNames);
sensorD = sensorSet(sensorD,'cfa pattern',cfaData.filterOrder);
L3 = L3Set(L3,'design sensor', sensorD);

%% Use small block size
blockSize = 5;
L3 = L3Set(L3,'block size', blockSize);

%% Turn on bias and bariance. These weights are optimized
% specifically for RGB/W

% weights = [4, 4, 4];
% L3 = L3Set(L3, 'global weight bias variance', weights);
% weights = [4, 16, 4];
% L3 = L3Set(L3, 'flat weight bias variance', weights);
% weights = [4, 1, 4];
% L3 = L3Set(L3, 'texture weight bias variance', weights);

%% Change luminance list
patchLuminanceSamples = (0:1/4:1) * 0.99 * 1.8; 
patchLuminanceSamples = patchLuminanceSamples(2:end);
patchLuminanceSamples = [0.001, 0.0016, 0.0026, 0.0041, 0.0065, 0.0104, 0.0166, 0.0266, 0.0424, 0.0678, 0.1082, 0.1729, 0.2762,...
    0.4505, 0.6753, 0.9, 1.1248, 1.3495, 1.5743, 0.99*1.8];
L3 = L3Set(L3,'luminance list', patchLuminanceSamples);

L3.sensor.design.rows = floor(L3.sensor.design.cols*10/22)*2;

%% Set training and rendering illuminant
L3 = L3Set(L3, 'Training Illuminant', [ill, '.mat']);
L3 = L3Set(L3, 'Rendering Illuminant', ['D65norm', '.mat']);

%% Change training scenes to color chart
% L3.scene = {sceneCreate('nature100')};

% Read training and rendering illuminant
illumTraining = vcReadSpectra(L3Get(L3, 'training illuminant'), wave);
illumD65 = vcReadSpectra('D65norm.mat', wave);

%% Train and create camera
L3 = L3TrainSimple_illum(L3);
camera = L3CameraCreate(L3);

%% Save L3 camera and L3
save(['dataSimple/L3_' cfa '_' ill '.mat'], 'L3');
save(['dataSimple/L3camera_' cfa '_' ill '.mat'], 'camera');




