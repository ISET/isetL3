%% s_SPIEFigure7
%
% This script trains L3 for Bayer and RGB/W (with bias and variance 
% tradeoff) and compare results for low light and high light for SPIE2013 
% paper figure 6.  
%
% (c) Stanford VISTA Team

%% Start ISET
% s_initISET

%% Load pre-trained cameras

% The standard Bayer camera
load(fullfile(L3rootpath,'cameras','L3','L3camera_Bayer.mat')); 
L3camera_Bayer = camera;
L3camera_Bayer = cameraSet(L3camera_Bayer, 'name', 'L3camera_Bayer');

% The RGB/W camera
load(fullfile(L3rootpath,'cameras','L3','L3camera_RGBW1.mat')); 
L3camera_RGBW = camera;
L3camera_RGBW = cameraSet(L3camera_RGBW, 'name', 'L3camera_RGBW');

%% Load scene
% I wonder if we could put the woman at a URL and download from there?
scene = sceneFromFile(fullfile(L3rootpath,'spie2013','data','AsianWoman_1.mat'), 'multispectral');
sz = sceneGet(scene, 'size');

%% Render images, save them, and also put them in a single window.

f = vcNewGraphWin;
luminances = [1, 80];
loop = 0;
for lum = luminances
    srgbResult_Bayer = cameraComputesrgb(L3camera_Bayer, scene, lum, sz);
    figure(f); subplot(2,2,1 + loop); imagescRGB(srgbResult_Bayer);
    
    srgbResult_RGBW = cameraComputesrgb(L3camera_RGBW, scene, lum, sz);
    figure(f); subplot(2,2,3 + loop); imagescRGB(srgbResult_Bayer);
    
    saveFile = ['srgbResult_Bayer_lum' num2str(lum) '.png'];
    imwrite(srgbResult_Bayer, saveFile);
    
    saveFile = ['srgbResult_RGBW_lum' num2str(lum) '.png'];
    imwrite(srgbResult_RGBW, saveFile);
    
    loop = loop + 1;
 end
 

 %%
 
 
 
 