%% This script is to train L3 using a simulated five-band camera.
%
%
%
%
%
% (c) Stanford Vista Team 2014

clear, clc, close all

%% Start ISET
s_initISET

%% Create and initialize L3 structure
L3 = L3Create;
wavelength = [400:10:680]';
[sensor, optics] = fbCreate(wavelength');

oi = oiCreate;
oi = oiSet(oi,'optics',optics);
oi = oiSet(oi,'name','fb optics');

L3 = L3Initialize(L3, [], oi, sensor, []); 

%% Change luminance list. Use more levels when it's dark. This should be 
% studied and optimized for the final paper.
voltagemax = L3Get(L3,'voltage max');
L3.training.luminanceList = [linspace(0.01*voltagemax, 0.1*voltagemax, 40), ...
                             linspace(0.11*voltagemax, 0.5*voltagemax, 20), ...
                             linspace(0.51*voltagemax, 99*voltagemax, 10)];

%% Across illuminat training using the measured illuminant spectra
dataRootPath = '/biac4/wandell/users/hblasins/5BD_Faces';
fName = fullfile(dataRootPath,'Joyce_2.8_Tungsten_exp_4.mat');
load(fName);
trainingillum = interp1(wave, SPD, wavelength, 'linear');
L3 = L3Set(L3, 'training illuminant', trainingillum);

%% Perform training
L3 = L3Train(L3);

%% Setup L3 camera
camera = L3CameraCreate(L3);

%% Save data
save('L3_fb_D652D65', 'L3');
save('L3camera_fb_Tungsten2D65', 'camera');