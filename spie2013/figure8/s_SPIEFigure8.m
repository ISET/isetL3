%% s_SPIEFigure8
%
% This script demonstrates L3's automatic design for novel CFAs.  This
% corresponds to SPIE2013 paper figure 8.  
%
% (c) Stanford VISTA Team

%% Make sure you have trained the three relevant cameras

% s_L3TrainCamerasforCFAs trains the CFA in selectedCFAList
% This will work as long as we don't change the published CFAs.
% A better method would be preferred.

cFile = fullfile(L3rootpath,'cameras','L3','L3camera_RGBW2.mat');
if ~exist(cFile,'file')
    fprintf('Training %s\n',cFile)
    selectedCFAList = 20;
    s_L3TrainCamerasforCFAs % train cameras for CFAs
end

cFile = fullfile(L3rootpath,'cameras','L3','L3camera_RGBW8.mat');
if ~exist(cFile,'file')
    fprintf('Training %s\n',cFile)
    selectedCFAList = 26;
    s_L3TrainCamerasforCFAs % train cameras for CFAs
end

cFile = fullfile(L3rootpath,'cameras','L3','L3camera_RWBW.mat');
if ~exist(cFile,'file')
    fprintf('Training %s\n',cFile)
    selectedCFAList = 30;
    s_L3TrainCamerasforCFAs % train cameras for CFAs
end


%% Render using the three trained cameras

scene = sceneFromFile(fullfile(L3rootpath,'spie2013','data','AsianWoman_1.mat'), 'multispectral');
sz = sceneGet(scene, 'size');

%% Render images, save them, and also put them in a single window.

lum = 50;  % Cd/m2

cFile = fullfile(L3rootpath,'cameras','L3','L3camera_RGBW2.mat');
foo = load(cFile); L3camera_RGBW2 = foo.camera;
srgbResult = cameraComputesrgb(L3camera_RGBW2, scene, lum, sz,[],[],1);
save('RGBW2','srgbResult')
sensorShowCFA(cameraGet(L3camera_RGBW2,'sensor'));

%%
cFile = fullfile(L3rootpath,'cameras','L3','L3camera_RGBW8.mat');
foo = load(cFile); L3camera_RGBW8 = foo.camera;
% p = cameraGet(L3camera_RGBW8,'sensor pattern');
% L3camera_RGBW8 = cameraSet(L3camera_RGBW8,'sensor cfa pattern and size',p);
% camera = L3camera_RGBW8; save(cFile,'camera');

srgbResult = cameraComputesrgb(L3camera_RGBW8, scene, lum, sz,[],[],1);
save('RGBW8','srgbResult')
sensorShowCFA(cameraGet(L3camera_RGBW8,'sensor'));

%%
cFile = fullfile(L3rootpath,'cameras','L3','L3camera_RWBW.mat');
% foo = load(cFile); L3camera_RWBW = foo.camera;
% p = cameraGet(L3camera_RWBW,'sensor pattern');
% L3camera_RWBW = cameraSet(L3camera_RWBW,'sensor cfa pattern and size',p);
% camera = L3camera_RWBW; save(cFile,'camera');

srgbResult = cameraComputesrgb(L3camera_RWBW, scene, lum, sz,[],[],1);
save('RWBW','srgbResult')
sensorShowCFA(cameraGet(L3camera_RWBW,'sensor'));

%% End