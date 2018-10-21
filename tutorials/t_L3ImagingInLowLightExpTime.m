%% Apply L3 method to exam the effect of imaging in low light.
% The exposure time will be changed, and the truth is the 
% Try to compare the result reported in the article: 
% "Learning to See in the Dark"
% Link: https://arxiv.org/abs/1805.01934

%% 
ieInit;

%% Create a scene with low illuminance
% Define the path to the image. An image from isetcam data folder was given 
% as an example.

%fname = fullfile(isetRootPath,'data','images','multispectral','Feng_Office-hdrs.mat');
% fname = fullfile(isetRootPath,'data','images','multispectral','CaucasianMale.mat');
fname = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs.mat');
scene = sceneFromFile(fname, 'multispectral');

%scene = sceneSet(scene, 'hfov', 30);
%scene = sceneAdjustLuminance(scene, 1);  % 1 cd/m2 and 10 fov = 0.1 lux (?)
ieAddObject(scene); sceneWindow;

%% Use the camera to generate the raw and sRGB image in low light.
% Create a new camera
camera = cameraCreate;

% Set the parameters 

% Set the ISO speed
camera = cameraSet(camera, 'sensor analogGain', 8000);

% f = 5.6 according to the paper.
camera = cameraSet(camera, 'optics fnumber',5.6); 

% Exposure time is first set to be 1/30 s
camera = cameraSet(camera, 'sensor exp time', 0.0333);

% Compute 
camera = cameraCompute(camera,scene);

%% Visualize the sensor data and sRGB image
rawShortExp = cameraGet(camera,'sensor volts');
vcNewGraphWin;
imagesc(rawShortExp); axis image; colormap(gray);
axis off; title('Raw image for 1/30 s exposure time');

sRGBShortExp = cameraGet(camera,'ip data srgb'); 
vcNewGraphWin; 
imagesc(sRGBShortExp); axis image; axis off; title('sRGB image for 1/30 s exposure time');

%% Change the exposure time to get a brighter image.
camera = cameraCreate;

% Set the ISO speed
camera = cameraSet(camera, 'sensor analogGain', 8000);

% f = 5.6 according to the paper.
camera = cameraSet(camera, 'optics fnumber',5.6);

camera = cameraSet(camera, 'sensor exp time', 20);
% Compute 
camera = cameraCompute(camera,scene);

%% Visualize the sensor data and sRGB image
rawLongExp = cameraGet(camera,'sensor volts');
vcNewGraphWin;
imagesc(rawLongExp); axis image; colormap(gray);
axis off; title('Raw image for 20 s exposure time');

sRGBLongExp = cameraGet(camera,'ip data srgb');
vcNewGraphWin;
imagesc(sRGBLongExp); axis image; axis off; title('sRGB image for 20 s exposure time');

%% Initiate parameters

cfa = [2 1; 3 2];
p_max = 20000;
patch_sz = [7 7];
pad_sz = (patch_sz - 1)/2;

% cutpoint settings
minCutPoint = -7.3;
maxCutPoint = -6.8;
%% Training
l3t = l3TrainRidge();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.p_max = p_max;
l3t.l3c.statFunc = {@imagePatchMean};
l3t.l3c.statFuncParam = {{}};
l3t.l3c.statNames = {'mean'};
l3t.l3c.cutPoints = {logspace(minCutPoint, maxCutPoint, 40)};
l3t.l3c.channelName = ["g1", "r", "b", "g2", "w"];
% classify
l3t.l3c.classify(l3DataCamera({rawShortExp}, {sRGBLongExp}, cfa));

% train
l3t.train();

%%
l3r = l3Render();
l3_RGB = l3r.render(rawShortExp, cfa, l3t);

l3_RGB = l3_RGB / max(max(l3_RGB(:,:,2)));

vcNewGraphWin; 
imagesc(l3_RGB); axis image; axis off; title('L3 image');