%% s_L3render
%
% After creating L3 cameras, say, s_L3TrainCamera, we 
% render an image using the L3 pipeline using this script
%
% See also: s_L3TrainCamera, L3render, cameraCompute, cameraComputesrgb
%
% (c) Stanford Vista Team 2012


%% Parameters
meanLuminance = 100;
fovScene      = 10;

%% Load scene included in L3 directory
% ii = 5;
% sNames     = dir(fullfile(L3rootpath,'data','scenes','*scene.mat'));
% thisName   = fullfile(L3rootpath,'data','scenes',sNames(ii).name);
% data       = load(thisName,'scene');
% scene  = data.scene;

%% Alternative Scenes
scene = sceneFromFile('StuffedAnimals_tungsten-hdrs','multispectral');
% scene = sceneCreate('zone plate',[1000,1000]); %sz = number of pixels of scene
% scene = sceneCreate('freq orient');
% scene = sceneCreate('moire orient');

%% Adjust FOV of camera to match scene, no extra pixels needed. 
camera = cameraSet(camera,'sensor fov',fovScene);

%% Change the scene so its wavelength samples matches the camera
wave = cameraGet(camera,'sensor','wave');
scene = sceneSet(scene,'wave',wave');

%% Change scene illuminant if it is different than used for training
scene = L3AdjustSceneIlluminant(scene, camera);

%% Find white point
whitept = sceneGet(scene,'illuminant xyz');
whitept = whitept/max(whitept);

%White point scaling is consistent with how the images are scaled for
%display where the brightest XYZ value in the ideal image is scaled to 1.

%% Set scene FOV and mean luminance
scene = sceneSet(scene,'hfov',fovScene);
scene = sceneAdjustLuminance(scene,meanLuminance);

%% Calculate ideal XYZ image
[camera,xyzIdeal] = cameraCompute(camera,scene,'idealxyz');
xyzIdeal = xyzIdeal/max(xyzIdeal(:));   %scale to full display range

%% Estimate of amount of light at sensor
% Get an estimate of the irradiance at the sensor (lux-sec).  This depends
% on the aperture and exposure time.
oi     = cameraGet(camera,'oi');
lux    = oiGet(oi,'mean illuminance');
sensor = cameraGet(camera,'sensor');
eTime  = sensorGet(sensor,'exp time','sec');
fprintf('Light at sensor %.3f (luxSec)\n',lux*eTime);

%% Calculate L^3 result
% Make sure this is set for an L3 pipeline.
camera = cameraSet(camera,'vci name','L3');
[camera, lrgbL3] = cameraCompute(camera,'oi');   % OI is already calculated

%% Calculate global L^3
camera  = cameraSet(camera,'vci name','L3 global');
[camera, lrgbGlobal]  = cameraCompute(camera,'sensor');

%% Basic ISET pipeline result
% We should set up some typical defaults in the vci so that the system runs
% right.  Not done yet.
camera = cameraSet(camera,'vci name','default');
[camera, lrgbBasic] = cameraCompute(camera,'sensor');

%% Remove black border from all images
L3         = cameraGet(camera,'L3');
lumIdx     = L3Get(L3,'luminance index');

xyzIdeal    = L3imcrop(L3,xyzIdeal); 
lrgbL3       = L3imcrop(L3,lrgbL3);
lrgbGlobal   = L3imcrop(L3,lrgbGlobal);
lrgbBasic    = L3imcrop(L3,lrgbBasic);
lumIdx      = L3imcrop(L3,lumIdx);

%% Scale and convert to sRGB
[srgbIdeal, lrgbIdeal] = xyz2srgb(xyzIdeal);

lrgbL3       = lrgbL3 * mean(lrgbIdeal(:)) / mean(lrgbL3(:));
lrgbGlobal   = lrgbGlobal * mean(lrgbIdeal(:)) / mean(lrgbGlobal(:));
lrgbBasic    = lrgbBasic * mean(lrgbIdeal(:)) / mean(lrgbBasic(:));

srgbL3      = lrgb2srgb(ieClip(lrgbL3,0,1));
srgbGlobal  = lrgb2srgb(ieClip(lrgbGlobal,0,1));
srgbBasic   = lrgb2srgb(ieClip(lrgbBasic,0,1));

%% Show the three results
vcNewGraphWin;  imagesc(srgbIdeal); axis image
title('Ideal')

%% Show the L3 result
vcNewGraphWin; imagesc(srgbL3); axis image
title('L3')

%% Show the Global L3 result
vcNewGraphWin; imagesc(srgbGlobal); axis image
title('L3 Global')

%% Show the basic ISET result
vcNewGraphWin; imagesc(srgbBasic); axis image
title('Basic Pipeline')

%% Show luminance index used for each patch
vcNewGraphWin;
imagesc(lumIdx)
title('Luminance Index')

