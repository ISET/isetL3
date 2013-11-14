% There is a lot of overlap between this and other scripts.  Let's clarify
% the point of this script and possibly convert to a demo or function.
%
% Perhaps it should be split into training and testing parts.  The training
% part is very similar to L3TrainCameraforCFA.  



%% s_L3ExpCFAs
%
% This script shows how to change L3 structure parameters to experiment
% with different CFA layouts
%
%
% (c) Stanford VISTA Team

clear, clc, close all

% Start ISET
s_initISET
dataroot = '/biac4/wandell/data/qytian/L3Project';

%% Training part

% Create and initialize L3 structure
L3 = L3Initialize();  % use default parameters

% Change the CFA to Aptina's new RWBW design
sensorD = L3Get(L3,'design sensor');
cfaPattern = [1 4; 4 3]; 
sensorD = sensorSet(sensorD, 'cfa pattern', cfaPattern);
L3 = L3Set(L3,'design sensor', sensorD);

% Perform training
L3 = L3Train(L3);

% Save L3
name = 'L3_RWBW';
L3 = L3Set(L3, 'name', name);
saveL3 = fullfile(dataroot, 'l3', [L3Get(L3, 'name') '.mat']);
save(saveL3, 'L3');

%% Rendering part 
% Load L3
name = 'L3_RWBW.mat';
loadL3 = fullfile(dataroot, 'l3', name);
load(loadL3);

% Load scene
loadScene = fullfile(dataroot, 'scene', 'AsianWoman_1.mat');
scene = sceneFromFile(loadScene, 'multispectral');

% Create camera from L3 structure
camera = L3CameraCreate(L3);
camera = cameraSet(camera,'vci name','l3'); % specify L3 pipeline
sz = sceneGet(scene, 'size');

for meanLum = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, ...
              90, 100, 150, 200, 300, 400, 500] % various scene mean lumin 
    % Compute sRGB results
    [srgbResult, srgbIdeal, raw, camera] = cameraComputesrgb(camera, scene, meanLum, sz);
    
    % Save sRGB results
    renderType = cameraGet(camera, 'vcitype');
    L3name = L3Get(L3, 'name');
    saveImage = fullfile(dataroot, 'image', ['sRGB_' L3name '_' renderType... 
        '_meanLum_' num2str(meanLum) '.png']);
    imwrite(srgbResult, saveImage);
end

saveImage = fullfile(dataroot, 'image', 'sRGB_ideal.png');
imwrite(srgbIdeal, saveImage);



