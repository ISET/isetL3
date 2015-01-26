%% s_saveFbRgb.mat
%
% This script reads and saves RGB images for quick preview. The RGB images
% were from the processing of the five-band camera software. Locate this
% script in the same directory of the stored scenes.
%
% Five-band images were capture by Henryk Blasinski, Qiyuan Tian and Joyce
% Farrell around campus on 1/16/2015.
%
%
% (c) Stanford VISTA Team 2015

clear, clc, close all
filenames = dir('*.mat');

for ii = 1 : length(filenames)
    thisFile = load(filenames(ii).name);
    RGB = thisFile.RGB;
    [pathstr,thisFileName,ext] = fileparts(filenames(ii).name);     
    imwrite(RGB, [thisFileName, '.png']);
end

