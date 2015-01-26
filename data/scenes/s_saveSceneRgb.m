%% s_saveSceneRgb.mat
%
% This script reads and saves RGB images from scenes for quick preview. 
%
%
% (c) Stanford VISTA Team, Jan 2015

clear, clc, close all
filenames = dir('*scene.mat');

for ii = 1 : length(filenames)
    thisFile = load(filenames(ii).name);
    RGB = sceneShowImage(thisFile.scene);
    [pathstr,thisFileName,ext] = fileparts(filenames(ii).name);     
    imwrite(RGB, [thisFileName, '.png']);
end

