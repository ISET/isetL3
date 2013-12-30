%% s_L3TrainCamerasforCFAs
%
% This script trains selected CFAs to create L3 cameras
%
% All training parameters are identical except a different CFA that is
% used. The parameters are specified in the function L3TrainCameraforCFA.
% This should probably be made more flexible or settable or something.
%
% (c) Stanford VISTA Team

%%
% s_initISET

%% Choose the CFAs to train camera

% These are all of the published arrays we know about
cfaFiles = dir(fullfile(L3rootpath,'data','sensors','CFA','published','*.mat'));

% Have the user select
listStr = cell(length(cfaFiles),1);
for ii=1:length(cfaFiles)
    listStr{ii} = cfaFiles(ii).name;
end
sel = listdlg('PromptString','Select CFAs for Training','ListString',listStr);
if isempty(sel), disp('User canceled'); return; end

%% Check or possibly make the save folder

% All L3 cameras will be saved in L3rootPath/cameras/L3
% The filename will be L3camera_XXX where XXX is the cfa filename.
saveFolder = fullfile(L3rootpath, 'cameras', 'L3');
if ~exist(saveFolder, 'dir')
    mkdir(saveFolder)
end

%% Train camera for each of the selected CFAs

selectedFiles = cfaFiles(sel);

for cfaFilenum = 1:length(selectedFiles)
    
    % Tell the user
    cfaFile = selectedFiles(cfaFilenum).name;
    disp(['CFA:  ', cfaFile, '  ', num2str(cfaFilenum),' / ', num2str(length(selectedFiles))])    
    
    % Train the camera
    camera = L3TrainCameraforCFA(cfaFile);
    
    % Save the camera
    saveFile = fullfile(saveFolder, ['L3camera_', cfaFile]);
    save(saveFile, 'camera')
end

%%
