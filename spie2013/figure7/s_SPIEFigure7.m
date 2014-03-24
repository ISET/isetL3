%% s_SPIEFigure7
%
% This script trains L3 for Bayer and RGB/W (with bias and variance 
% tradeoff) and compare results for low light and high light for SPIE2013 
% paper figure 7.  
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Make sure you have trained the two relevant cameras

% s_L3TrainCamerasforCFAs trains the CFA in selectedCFAList
% This will work as long as we don't change the published CFAs.
% A better method would be preferred.

cFile = fullfile(L3rootpath,'cameras','L3','L3camera_Bayer.mat');
if ~exist(cFile,'file')
    fprintf('Training %s\n',cFile)
    selectedCFAList = 1;
    s_L3TrainCamerasforCFAs % train cameras for CFAs
end

cFile = fullfile(L3rootpath,'cameras','L3','L3camera_RGBW1.mat');
if ~exist(cFile,'file')
    fprintf('Training %s\n',cFile)
    selectedCFAList = 19;
    s_L3TrainCamerasforCFAs % train cameras for CFAs
end
%% Load scene

scene = sceneFromFile(fullfile(L3rootpath,'spie2013','data','AsianWoman_1.mat'), 'multispectral');
sz = sceneGet(scene, 'size');

%% Render images, save them, and also put them in a single window.

cFile = fullfile(L3rootpath,'cameras','L3','L3camera_Bayer.mat');
foo = load(cFile); L3camera_Bayer = foo.camera;
L3camera_Bayer = cameraSet(L3camera_Bayer, 'name', 'L3camera_Bayer');


cFile = fullfile(L3rootpath,'cameras','L3','L3camera_RGBW1.mat');
foo = load(cFile); L3camera_RGBW = foo.camera;
L3camera_RGBW = cameraSet(L3camera_RGBW, 'name', 'L3camera_RGBW');

f = vcNewGraphWin;
luminances = [1, 80];
loop = 0;
for lum = luminances
    srgbResult_Bayer = cameraComputesrgb(L3camera_Bayer, scene, lum, sz,[],[],1);
    figure(f); subplot(2,2,1 + loop); imagescRGB(srgbResult_Bayer);
    cName = cameraGet(L3camera_Bayer,'name');
    cName = strrep(cName,'L3camera_','');
    title(sprintf('Camera %s at lum %0.1f\n',cName,lum));
    
    srgbResult_RGBW = cameraComputesrgb(L3camera_RGBW, scene, lum, sz,[],[],1);
    figure(f); subplot(2,2,3 + loop); imagescRGB(srgbResult_RGBW);
    cName = cameraGet(L3camera_RGBW,'name');
    cName = strrep(cName,'L3camera_','');
    title(sprintf('Camera %s at %0.1f\n',cName,lum));
    
    saveFile = ['srgbResult_Bayer_lum' num2str(lum) '.png'];
    imwrite(srgbResult_Bayer, saveFile);
    
    saveFile = ['srgbResult_RGBW_lum' num2str(lum) '.png'];
    imwrite(srgbResult_RGBW, saveFile);
    
    loop = loop + 1;
 end
 
 %% End
 
 
 
 