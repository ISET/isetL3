%% t_L3LowLight
% Try to do image process under low light environment

%% init
ieInit;

%% Load scenes
scenePath = fullfile(L3rootpath,'dataSet/scene/');
format = 'mat';

scenes = loadScenes(scenePath, format, [1:10]);
%% load camera data
dataPath = '/home/zhenglyu/Research/isetL3/local/';
dataName = 'huaweiSensorParm.mat';

cameraData = load(strcat(dataPath, dataName));

%% Set the camera with the Huawei parameter
camera = cameraCreate;

% Create the bayer pattern
camera = cameraSet(camera,'sensor',sensorCreateHWBayer);

camera = cameraSet(camera, 'sensor name', 'Bayer Pattern Huawei');

camera = huaWeiSetup(camera, cameraData);
sampleScene = scenes{1};
wave = sceneGet(sampleScene, 'wave');
xyzValue = ieReadSpectra('XYZ.mat', wave);
xyzFilter = xyzValue / max(max(xyzValue));
camera = cameraSet(camera, 'sensor filter transmissivities', xyzFilter);

% set the offset to be zero
camera = cameraSet(camera, 'sensor analog offset', 0);

% set the exposure time to be 15 ms
camera = cameraSet(camera, 'sensor exposure time', 0.03);

%% Check the parameter
sampleScene = scenes{1};
sampleScene = sceneAdjustLuminance(sampleScene, 0.05);

ieAddObject(sampleScene);
sceneWindow();

cameraXYZ = camera;


cameraXYZ = cameraSet(cameraXYZ, 'sensor filter transmissivities', xyzFilter);

cameraXYZ = cameraCompute(cameraXYZ, sampleScene);

sensorXYZ = cameraGet(cameraXYZ, 'sensor');

oi = cameraGet(cameraXYZ, 'oi');


sensor = sensorXYZ;

sensorNF = sensorXYZ;

sensorNF = sensorSet(sensorNF, 'noise flag', -1);

outImgTrue = sensorComputeFullArray(sensorNF, oi, xyzFilter);
outImgNoise = sensorComputeFullArray(sensor, oi, xyzFilter);

vcNewGraphWin;
imshow(xyz2srgb(outImgTrue*100));

vcNewGraphWin;
imshow(xyz2srgb(outImgNoise*100));

ieAddObject(sensor);
sensorWindow;

imgIP = cameraGet(cameraXYZ,'ip');
ieAddObject(imgIP);
ipWindow;
%{
% outImgTrue = ipGet(imgIP, 'srgb');

saveName = '/home/zhenglyu/Conference/ScienTalk2018/Figures/convIp005Img7.mat';

save(saveName, 'outImg');
%}
%% Initiate the l3d data
l3dLowLight = l3DataISET('nscenes', numel(scenes)-3, 'scenes', {scenes{1:end-3}}); 
% l3dLowLight = l3DataISET();
%%
l3dLowLight.illuminantLev = [0.05, 0.25, 0.4];
l3dLowLight.inIlluminantSPD = {'D65'};
l3dLowLight.outIlluminantSPD = {'D65'};
%% Set the camera to the l3d data
l3dLowLight.set('camera', camera);

%% Set the training data
% Create training class instance.  The other possibilities are l3TrainOLS
% and l3TrainWiener.
l3t = l3TrainRidge();

%%
cg = cameraGet(camera, 'pixel conversionGain');
% set training parameters for the lookup tables.  These are the number and
% spacing of the response levels, and the training patch size
% l3t.l3c.cutPoints = {logspace(-1.7, -0.12, 30), []}; % for [50 10 80]
% l3t.l3c.cutPoints = {logspace(-3, -1, 40), []}; % for [0.5 0.1 0.8]
% l3t.l3c.cutPoints = {logspace(-4.5, -2, 40), []}; % for [0.05 0.01 0.08]
% l3t.l3c.cutPoints = {[0:0.0011 / 5 * 2:0.01], []}; % for [0.05 0.01 0.08]

% l3t.l3c.cutPoints = {[0 * cg: 500 * cg:500 *cg], []}; % to be used for 0.05, 0.25, 0.4
l3t.l3c.cutPoints = {[10 * cg: 10 * cg:300 *cg], []}; % to be used for 0.05, 0.25, 0.4
% l3t.l3c.cutPoints = {logspace(-3.6450, -1.1679, 30), []}; % to be used for 0.05, 0.25, 0.4
% l3t.l3c.cutPoints = {logspace(log10(10), log10(300), 30)*cg, []}
l3t.l3c.patchSize = [5 5];
%l3t.l3c.channelName = ["g1", "r", "b", "g2", "w"];
l3t.l3c.satClassOption = 'none';
% Invoke the training algorithm90=cdsacgot
l3t.train(l3dLowLight);

%% Check for single channel
thisClass = 1;
thisChannel = 3;
[X, y_pred, y_true] = checkLinearFit(l3t, thisClass, thisChannel, l3t.l3c.patchSize);
cg = cameraGet(camera, 'pixel conversionGain');
y_pred_ele = y_pred / cg;

y_true_ele = y_true / cg;

[X, y_true]  = l3t.l3c.getClassData(thisClass);
%% Conduct a full evaluation on the kernel
mse = u_kernelEvaluation(l3t);
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
scene = sceneSet(scene, 'fov', 10);
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
% outImg = outImg / max(max(outImg(:,:,2)));
subplot(1,3,3); imshow(outImg); title('L3 Rendered Image');
% subplot(1,3,3); imshow(outImg*10); title('L3 Rendered Image');

subplot(1,3,3); imshow(xyz2srgb(outImg * 100)); title('L3 Rendered Image');

% sensorTest = cameraGet(camera,'sensor');



%% Try to render a new image

l3r = l3Render();

% Obtain the sensor mosaic response to a scene.  Could be any scene
scene = scenes{9};
scene = sceneSet(scene, 'fov', 10);
scene = sceneAdjustLuminance(scene, l3dLowLight.illuminantLev(1));

vcNewGraphWin([], 'wide');
% subplot(1,3,1); 
% imshow(sceneGet(scene, 'rgb')); title('Scene Image');

% Use isetcam to compute the camera data.
[camera, img]  = cameraCompute(l3dLowLight.camera, scene);
cfa     = cameraGet(l3dLowLight.camera, 'sensor cfa pattern');
cmosaic = cameraGet(camera, 'sensor volts');

% Show the raw data, before processing
% subplot(1, 3, 2); 
% imagesc(cmosaic); axis image; colormap(gray);
% axis off; title('Camera Raw Data with Bayer Pattern');

% Compute L3 rendered image
% The L3 rendered image is blurry compared to the
% scene image. This is a result of lens blur in the camera.
outImg = l3r.render(cmosaic, cfa, l3t, false);
outImg = xyz2srgb(outImg);

% subplot(1,3,3); imshow(outImg); title('L3 Rendered Image');
% subplot(1,3,3); imshow(xyz2srgb(outImg)); title('L3 Rendered Image');
%%
vcNewGraphWin;
imshow(outImg); title('L3 Rendered Image');
%% save img
outPath = '/home/zhenglyu/Course/PSYCH221/005ElectronLine30Scene9.mat';
save(outPath, 'outImg');

%% save ground truth
outImgTrue = xyz2srgb(outImgTrue*100);
outPath = '/home/zhenglyu/Course/PSYCH221/grndTrueScene8.mat';
save(outPath, 'outImgTrue');

%% save original img
outImgNoise = xyz2srgb(outImgNoise*100);
outPath = '/home/zhenglyu/Course/PSYCH221/noiseScene1.mat';
save(outPath, 'outImgNoise');