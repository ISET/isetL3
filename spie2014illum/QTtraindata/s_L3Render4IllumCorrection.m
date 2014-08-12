%% s_L3Train4IllumCorrection.m
% 
% Use this script along with function modifyCamera to study the color
% correction matrices and render images. 
% 
% The newly trained L3 structures contain a complete set of L3 filters and
% correction matrices, namely:
% 1, L3 filters from some light to some light
% 2, L3 filters from some light to D65
% 3, One global correction matrix
% 4, Cluster dependent correction matrices 
%
% The correction matrices are all derived from data.
%
% See modifyCamera to see how the filters and correction matrics are
% stored.
%
% (c) Stanford VISTA Team 2014

clear, clc, close all

%% Start ISET
s_initISET

%% Load camera
illum = 'Tungsten'; % specify light
cfa = 'Bayer'; % specify CFA
cameraName = ['L3camera_' cfa '_' illum '.mat'];
fName = fullfile(L3rootpath, 'spie2014illum', 'QTtraindata', 'data', cameraName);
load(fName); 

%% Load scene
scene = sceneFromFile('AsianWoman_1.mat', 'multispectral');
sz = sceneGet(scene, 'size');

%% Render
for option = [1 : 4]
    % Modify camera
    L3camera= modifyCamera(camera, option); 
    
    for lum = [1, 80] % luminance levels
        % render the scene under the specified light
        srgbResult = cameraComputesrgb_illum(L3camera, scene, lum, sz, [], [], 0);
        switch option
            case 1
                name = ['srgb_' cfa '_' illum '_lum_' num2str(lum) '.png'];
            case 2
                name = ['srgb_' cfa '_' illum '_l3corrected_lum_' num2str(lum) '.png'];
            case 3
                name = ['srgb_' cfa '_' illum '_globallycorrected_lum_' num2str(lum) '.png'];
            case 4
                name = ['srgb_' cfa '_' illum '_locallycorrected_lum_' num2str(lum) '.png'];
        end
        imwrite(srgbResult, name);
        
    end % end lum
end % end option




 