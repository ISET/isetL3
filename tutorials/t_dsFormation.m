%% t_dsFormation
% Create the database used in the L3. Given the location to the images and
% the target Path, we can create the scene and add them to the current
% database.

% ZL/BW, 2018

%% init
ieInit;

%% Specification
% Specify the path to the images and the path to the scene. Also specify
% the format of the image. In the future we need to modify it to read all
% format of the inages
imgPath = '/scratch/ZhengLyu/sampleDataSet/img';
scenePath = '/scratch/ZhengLyu/sampleDataSet/scene';
imgFormat = 'jpg';

dsFormat = 'mat';
%% Generate the scene database
dsPath = dsFromImg(imgPath, scenePath,imgFormat);

%% Some demostration of the scene
cd(dsPath);
format = strcat('*.', dsFormat);
filesToLoad = dir(format);

% Get the first scene data
firstSceneName = filesToLoad(3).name;
scene = sceneFromFile(firstSceneName, 'multispectral');

ieAddObject(scene); sceneWindow;