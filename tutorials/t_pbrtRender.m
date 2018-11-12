%%

%% init
ieInit;
%%

scenePath = '/scratch/ZhengLyu/Autonomous Driving/BaiduDS/scene/';
format = 'mat';

scenes = loadScenes(scenePath, format, 1);

%%
l3dPBRT = l3DataISET('nscenes', numel(scenes), 'scenes', scenes); 

%%

l3dPBRT.illuminantLev = [10, 50, 80];
l3dPBRT.hdrMode = false;
l3dPBRT.refIlluminantLev = [140, 180, 220];
l3dPBRT.inIlluminantSPD = {'D65'};
l3dPBRT.outIlluminantSPD = {'D65'};

%%
l3t = l3TrainRidge();

% set training parameters for the lookup tables.  These are the number and
% spacing of the response levels, and the training patch size
l3t.l3c.cutPoints = {logspace(-1.7, -0.12, 30), []};
l3t.l3c.patchSize = [5 5];
%l3t.l3c.channelName = ["g1", "r", "b", "g2", "w"];
l3t.l3c.satClassOption = 'none';
% Invoke the training algorithm
l3t.train(l3dPBRT);

%% Check out the render section
% This section is used to justify if the new scenes can be properly
% rendered.
%{
l3r = l3Render();

% Obtain the sensor mosaic response to a scene.  Could be any scene
scene = l3dPBRT.get('scenes', 1);
scene = sceneAdjustLuminance(scene, l3dPBRT.illuminantLev(1));

vcNewGraphWin([], 'wide');
subplot(1,3,1); 
imshow(sceneGet(scene, 'rgb')); title('Scene Image');

% Use isetcam to compute the camera data.
[camera, img]  = cameraCompute(l3dPBRT.camera, scene);
cfa     = cameraGet(l3dPBRT.camera, 'sensor cfa pattern');
cmosaic = cameraGet(camera, 'sensor volts');

% Show the raw data, before processing
subplot(1, 3, 2); 
imagesc(cmosaic); axis image; colormap(gray);
axis off; title('Camera Raw Data with Bayer Pattern');

% Compute L3 rendered image
% The L3 rendered image is blurry compared to the
% scene image. This is a result of lens blur in the camera.
outImg = l3r.render(cmosaic, cfa, l3t);
outImg = outImg / max(max(outImg(:,:,2)));
subplot(1,3,3); imshow(xyz2srgb(outImg)); title('L3 Rendered Image');
%}

%%
sceneTmp = load('pbrt_rendered.mat');
sceneTest = sceneTmp.scene_corrected{1};
vcNewGraphWin([], 'wide');
subplot(1,3,1); 
imshow(sceneGet(sceneTest, 'rgb')); title('Scene Image');

% Use isetcam to compute the camera data.
[camera, img]  = cameraCompute(l3dPBRT.camera, sceneTest);
cfa     = cameraGet(l3dPBRT.camera, 'sensor cfa pattern');
cmosaic = cameraGet(camera, 'sensor volts');

% Show the raw data, before processing
subplot(1, 3, 2); 
imagesc(cmosaic); axis image; colormap(gray);
axis off; title('Camera Raw Data with Bayer Pattern');

% Compute L3 rendered image
% The L3 rendered image is blurry compared to the
% scene image. This is a result of lens blur in the camera.
outImg = l3r.render(cmosaic, cfa, l3t);
outImg = outImg / max(max(outImg(:,:,2)));
subplot(1,3,3); imshow(xyz2srgb(outImg)); title('L3 Rendered Image');