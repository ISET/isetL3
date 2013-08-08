%% s_L3MakeBasicCameras
%
% This script creates basic cameras for a series of L3 cameras.
%
% The basic cameras inherit the sensor and optics from the L3 cameras but
% the L3 processing properties are ignored.
%
% Basic camera means the processing is the default processing in ISET that
% uses bilinear demosaicking.
%
% See s_L3TrainCamerasforCFAs to train L3 cameras for a variet of CFAs.
%
% (c) Stanford VISTA Team


%% File locations


% A basic camera will be trained for each of the file of the form
% L3camera_XXX.mat in the following directory.  Generally XXX is the CFA
% name.
cameraFolder = fullfile(L3rootpath, 'Cameras', 'L3');

% All basic cameras will be saved in the following subfolder of the Cameras
% folder.  The filename will be basiccamera_XXX.mat where XXX is the same
% as the L3 camera file.
saveFolder = fullfile(L3rootpath, 'Cameras', 'global');

%% If it doesn't exist, create the folder where files will be saved
if exist(saveFolder, 'dir')~=7
    mkdir(saveFolder)
end

%% Train Camera for each CFA 
cameraFiles = dir(fullfile(cameraFolder, '*.mat'));
for cameraFilenum = 1:length(cameraFiles)
    cameraFile = cameraFiles(cameraFilenum).name;
    disp(['Camera:  ', cameraFile, '  ', num2str(cameraFilenum),' / ', num2str(length(cameraFiles))])
    if length(cameraFile>9) & strcmp(cameraFile(1:9), 'L3camera_')
        data = load(fullfile(cameraFolder,cameraFile));
        if isfield(data, 'camera')
            camera = data.camera;
        else
            error('No camera found in file.')
        end
        
        camera = cameraSet(camera,'name',['Global L3 camera modified from ',cameraFile]);
        camera = cameraSet(camera,'vci name','L3 global');

        % Remove from camera any metrics
        camera.metrics=[];

        namesuffix = cameraFile(10:end);    %generally CFA name
        saveFile = fullfile(saveFolder, ['gloablcamera_', namesuffix]);
        save(saveFile, 'camera')
    end
end