%% t_L3LowLight
% Try to do image process under low light environment

%% init
ieInit;

%% Load scenes
scenePath = fullfile(L3rootpath,'dataSet/scene/');
format = 'mat';

scenes = loadScenes(scenePath, format, [1, 2, 3, 4, 5, 6, 7]);
%% load the data
dataPath = '/home/zhenglyu/Research/isetL3/local/';
dataName = 'huaweiSensorParm.mat';

cameraData = load(strcat(dataPath, dataName));

%% Set the camera with the Huawei parameter
camera = cameraCreate;

% Create the bayer pattern
camera = cameraSet(camera,'sensor',sensorCreateHWBayer);

camera = cameraSet(camera, 'sensor name', 'Bayer Pattern Huawei');

camera = huaWeiSetup(camera, cameraData);

% set the offset to be zero
camera = cameraSet(camera, 'sensor analog offset', 0);

% set the exposure time to be 15 ms
camera = cameraSet(camera, 'sensor exposure time', 0.03);

%% Check the parameter
sampleScene = scenes{7};
sampleScene = sceneAdjustLuminance(sampleScene, 0.07);
sampleScene = sceneSet(sampleScene, 'fov', 5);
% sampleScene = sceneSet(sampleScene, 'distance', 1);

ieAddObject(sampleScene);
sceneWindow();

camera = cameraCompute(camera, sampleScene);
sensor = cameraGet(camera, 'sensor');
ieAddObject(sensor);
sensorWindow;

imgIP = cameraGet(camera,'ip');
ieAddObject(imgIP);
ipWindow;
%{
outImg = ipGet(imgIP, 'srgb');
saveName = '/home/zhenglyu/Conference/ScienTalk2018/Figures/conv_ip_img.mat';

save(saveName, 'outImg');
%}
%% Initiate the l3d data
l3dLowLight = l3DataISET('nscenes', numel(scenes) - 3, 'scenes', {scenes{1:end - 3}}); 

%%
l3dLowLight.illuminantLev = [0.07 0.05 0.1];
l3dLowLight.inIlluminantSPD = {'D65'};
l3dLowLight.outIlluminantSPD = {'D65'};
%% Set the camera to the l3d data
l3dLowLight.set('camera', camera);

%% Set the training data
% Create training class instance.  The other possibilities are l3TrainOLS
% and l3TrainWiener.
l3t = l3TrainRidge();
%%
% set training parameters for the lookup tables.  These are the number and
% spacing of the response levels, and the training patch size
l3t.l3c.cutPoints = {logspace(-3.8, -1.8, 50), []};
l3t.l3c.patchSize = [5 5];
%l3t.l3c.channelName = ["g1", "r", "b", "g2", "w"];
l3t.l3c.satClassOption = 'none';
% Invoke the training algorithm
l3t.train(l3dLowLight);

%%
thisClass = 180;
thisChannel = 1;

checkLinearFit(l3t, thisClass, thisChannel, l3t.l3c.patchSize);

%% Check the processed output image
%{
[inImg, outImg, ~] = l3dLowLight.dataGet();
outImgcc = outImg;
for ii = 1 : length(outImg)
    outImgcc{ii} = outImgcc{ii} / max(max(outImgcc{ii}(:,:,2)));
    outImgcc{ii} = xyz2rgb(outImgcc{ii});
end

% Sampled img
thisImg1 = 1;
imshow(outImgcc{thisImg1});
vcNewGraphWin; imagesc(inImg{thisImg1});colormap(gray);

%}

%% Check out the render section
% This section is used to justify if the new scenes can be properly
% rendered.

l3r = l3Render();

% Obtain the sensor mosaic response to a scene.  Could be any scene
scene = l3dLowLight.get('scenes', 1);
scene = sceneSet(scene, 'fov', 20);
scene = sceneAdjustLuminance(scene, l3dLowLight.illuminantLev(1));

vcNewGraphWin([], 'wide');
subplot(1,3,1); 
imshow(sceneGet(scene, 'rgb')); title('Scene Image');

% Use isetcam to compute the camera data.
[camera, img]  = cameraCompute(l3dLowLight.camera, scene);
cfa     = cameraGet(l3dLowLight.camera, 'sensor cfa pattern');
cmosaic = cameraGet(camera, 'sensor volts');

% Show the raw data, before processing
subplot(1, 3, 2); 
imagesc(cmosaic); axis image; colormap(gray);
axis off; title('Camera Raw Data with Bayer Pattern');

% Compute L3 rendered image
% The L3 rendered image is blurry compared to the
% scene image. This is a result of lens blur in the camera.
outImg = l3r.render(cmosaic, cfa, l3t, false);
% outImg = outImg /max(max(outImg(:,:,2)));
outImg = outImg / max(max(outImg(:,:,2)));
% subplot(1,3,3); imshow(xyz2srgb(outImg)); title('L3 Rendered Image');
subplot(1,3,3); imshow(outImg); title('L3 Rendered Image');

% subplot(1,3,3); imshow(xyz2srgb(outImg)); title('L3 Rendered Image');

% sensorTest = cameraGet(camera,'sensor');



%%

l3r = l3Render();

% Obtain the sensor mosaic response to a scene.  Could be any scene
scene = scenes{1};
scene = sceneSet(scene, 'fov', 20);
scene = sceneAdjustLuminance(scene, l3dLowLight.illuminantLev(1));

vcNewGraphWin([], 'wide');
subplot(1,3,1); 
imshow(sceneGet(scene, 'rgb')); title('Scene Image');

% Use isetcam to compute the camera data.
[camera, img]  = cameraCompute(l3dLowLight.camera, scene);
cfa     = cameraGet(l3dLowLight.camera, 'sensor cfa pattern');
cmosaic = cameraGet(camera, 'sensor volts');

% Show the raw data, before processing
subplot(1, 3, 2); 
imagesc(cmosaic); axis image; colormap(gray);
axis off; title('Camera Raw Data with Bayer Pattern');

% Compute L3 rendered image
% The L3 rendered image is blurry compared to the
% scene image. This is a result of lens blur in the camera.
outImg = l3r.render(cmosaic, cfa, l3t, false);
outImg = outImg /max(max(outImg(:,:,2)));

subplot(1,3,3); imshow(outImg); title('L3 Rendered Image');
% subplot(1,3,3); imshow(xyz2srgb(outImg)); title('L3 Rendered Image');

