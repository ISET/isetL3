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
ill = 'Tungstennorm'; % 'D65'
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
L3 = L3Set(L3,'luminance list', patchLuminanceSamples);


%% Set training and rendering illuminant
L3 = L3Set(L3, 'Training Illuminant', [ill, '.mat']);
L3 = L3Set(L3, 'Rendering Illuminant', ['D65norm', '.mat']);

%% 

% Read training and rendering illuminant
illumTraining = vcReadSpectra(L3Get(L3, 'training illuminant'), wave);
illumD65 = vcReadSpectra('D65norm.mat', wave);

%% Train and create camera
L3 = L3TrainSimple_illum(L3);
camera = L3CameraCreate_illum(L3);

%% Save L3 camera and L3
save(['dataSimple/L3_' cfas{cfaNum} '_' ils{illumNum} '.mat'], 'L3');
save(['dataSimple/L3camera_' cfas{cfaNum} '_' ils{illumNum} '.mat'], 'camera');




