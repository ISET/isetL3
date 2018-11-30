%% Huawei Camera sensor properties setup

%% init
ieInit;

%% load the data
dataPath = '/home/zhenglyu/Research/isetL3/local/';
dataName = 'huaweiSensorParm.mat';

cameraData = load(strcat(dataPath, dataName));

%% load the scene
scenePath = '/scratch/ZhengLyu/sampleDataSet/scene';
format = 'mat';

scenes = loadScenes(scenePath, format, 5);
%% Set the camera with the Huawei parameter
camera = cameraCreate;

% Create the quadra pattern
camera = cameraSet(camera,'sensor',sensorCreateQuad);

camera = cameraSet(camera, 'sensor name', 'Quadra pattern default');

camera = huaWeiSetup(camera, cameraData);

%% Check the parameter
sampleScene = scenes{1};
sampleScene = sceneAdjustLuminance(sampleScene, 10);
sampleScene = sceneSet(sampleScene, 'fov', 5);
sampleScene = sceneSet(sampleScene, 'distance', 1);
ieAddObject(sampleScene);
sceneWindow();

camera = cameraCompute(camera, sampleScene);
sensor = cameraGet(camera, 'sensor');
ieAddObject(sensor);
sensorWindow;

img = cameraGet(camera,'ip');
ieAddObject(img);
ipWindow;

%% Create the l3 data structure
l3dHuawei = l3DataISET('nscenes', numel(scenes), 'scenes', scenes);

l3dHuawei.illuminantLev = [10, 50, 80];
l3dHuawei.inIlluminantSPD = {'D65'};
l3dHuawei.outIlluminantSPD = {'D65'};

% Set the camera
l3dHuawei.set('camera', camera);

%% Create the training dataset
l3t = l3TrainRidge();

l3t.l3c.cutPoints = {logspace(-1.2, -0.8, 30), []};
l3t.l3c.patchSize = [5 5];

l3t.l3c.satClassOption = 'compress';
% Invoke the training algorithm
l3t.train(l3dHuawei);

%% Exam the training result
%{
    % Exam the linearity of the kernels
    thisClass = 45; 
    
    [X, y_true]  = l3t.l3c.getClassData(thisClass);
    X = padarray(X, [0 1], 1, 'pre');
    y_pred = X * l3t.kernels{thisClass};
    thisChannel = 3;
    vcNewGraphWin; plot(y_true(:,thisChannel), y_pred(:,thisChannel), 'o');
    xlabel('Target value (ground truth)', 'FontSize', 15, 'FontWeight', 'bold');
    ylabel('Predicted value', 'FontSize', 15,'FontWeight', 'bold');
%     title(['Target value vs Predicted value for: class ', num2str(thisClass),...
%                         ' channel ' num2str(thisChannel)], 'FontWeight', 'bold');
    axis square;
    identityLine;
    vcNewGraphWin; imagesc(reshape(l3t.kernels{thisClass}(2:26,thisChannel),...
            [5, 5]));  colormap(gray);axis off %colorbar;
%}

%% try the rendered img
l3r = l3Render();

sampleScene = l3dHuawei.get('scenes', 1);
sampleScene = sceneAdjustLuminance(sampleScene, l3dHuawei.illuminantLev(1));
sampleScene = sceneSet(sampleScene, 'fov', 15);
sampleScene = sceneSet(sampleScene, 'distance', 0.5);

vcNewGraphWin([], 'wide');
subplot(1,3,1); 
imshow(sceneGet(sampleScene, 'rgb')); title('Scene Image');

% Use isetcam to compute the camera data.
[camera, img]  = cameraCompute(l3dHuawei.camera, sampleScene);
cfa     = cameraGet(l3dHuawei.camera, 'sensor cfa pattern');
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

%%
                