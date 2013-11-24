%% s_L3TrainCamerasforCFAs
%
% This script trains and creates L3 cameras for a series of CFAs.
%
% For each camera all parameters are identical except the CFA that is used.
% All parameters are specified in L3TrainCameraforCFA.
%
% (c) Stanford VISTA Team

s_initISET

%% File locations
% An L3 camera will be trained for each of the .mat files in the following
% directory which should contain a CFA.
cfaFiles = dir(fullfile(L3rootpath,'data','sensors','CFA','published','*.mat'));

% All L3 cameras will be saved in the following subfolder of the Cameras
% folder.  The filename will be L3camera_XXX where XXX is the cfa filename.
saveFolder = fullfile(L3rootpath, 'cameras', 'L3');

%% If it doesn't exist, create the folder where files will be saved
if exist(saveFolder, 'dir')~=7
    mkdir(saveFolder)
end

%% Train Camera for each CFA 
for cfaFilenum = 1:length(cfaFiles)
    cfaFile = cfaFiles(cfaFilenum).name;
    disp(['CFA:  ', cfaFile, '  ', num2str(cfaFilenum),' / ', num2str(length(cfaFiles))])    
    camera = L3TrainCameraforCFA(cfaFile);
    saveFile = fullfile(saveFolder, ['L3camera_', cfaFile]);
    save(saveFile, 'camera')
end
