%% t_L3SuperResolution
% Explore the super resolution based on l3
% approach.

%%
ieInit;
%% Set the destination folder

dFolder = fullfile(L3rootpath,'local','scenes');
%% Download the scene from RDT
rdt = RdtClient('scien');
rdt.readArtifacts('/L3/quad/scenes','destinationFolder',dFolder);

%% load the scenes
format = 'mat';
scenes = loadScenes(dFolder, format, [1:20]);
%% Use l3DataSimulation to generate raw and desired RGB image
l3dSR = l3DataSuperResolution();
% sceneSampleOne = sceneSet(sceneCreate, 'fov', 12);
% sceneSampleTwo = sceneSet(sceneCreate('sweep'))

l3dSR.sources = scenes(1:5);
l3dSR.upscaleFactor = 1;
%%
l3tSuperResolution = l3TrainRidge('l3c', l3ClassifySR);

%%
l3tSuperResolution.l3c.cutPoints = {logspace(-1.7, -0.12, 30),...
                                        [], [1:2^numel(l3dSR.cfa)-1]};
l3tSuperResolution.l3c.patchSize = [5 5];

% Invoke the training algorithm
l3tSuperResolution.l3c.satClassOption = 'none';
l3tSuperResolution.train(l3dSR);

%%
thisKernel = 1106;
kernel  = l3tSuperResolution.kernels{thisKernel};
[X, y] =l3tSuperResolution.l3c.getClassData(thisKernel); 
X = padarray(X, [0 1], 1, 'pre');
y_fit = X * kernel;
thisChannel = 4;
plot(y_fit(:,thisChannel), y(:,thisChannel), 'o');
axis square; 
identityLine;
%% Render
l3rSR = l3RenderSR();

% Obtain the sensor mosaic response to a scene.  Could be any scene
source = l3dSR.sources{5};
% source = scenes{4};
% source = sceneCreate('rings rays');
% source = sceneCreate('sweep frequency');

% Use isetcam to compute the camera data.
sensor = cameraGet(l3dSR.camera, 'sensor');

switch source.type
    case 'scene'
        oi = cameraGet(l3dSR.camera, 'oi');
        oi = oiCompute(oi, source);
        oiSource = oi;
    case 'opticalimage'
        oiSource = source;
end
sensor = sensorSetSizeToFOV(sensor, oiGet(oiSource, 'fov'));
sensor = sensorCompute(sensor, oiSource);
cfa     = cameraGet(l3dSR.camera, 'sensor cfa pattern');
cmosaic = sensorGet(sensor, 'volts');
ipLR = cameraGet(l3dSR.camera, 'ip');
ipLR = ipCompute(ipLR, sensor);
lrImg = ipGet(ipLR, 'data srgb');
% Compute L3 rendered image
% The L3 rendered image is blurry compared to the
% scene image. This is a result of lens blur in the camera.
outImg = l3rSR.render(cmosaic, cfa, l3tSuperResolution, l3dSR);
%% Set the HR camera
% cameraHR = camera;
% cameraHR = cameraSet(cameraHR, 'pixel size',...
%                 cameraGet(camera, 'pixel size') / l3dSR.upscaleFactor);
% cameraHR = cameraSet(cameraHR, 'sensor size',...
%                 cameraGet(camera, 'sensor size')*l3dSR.upscaleFactor);

sensorHR = sensorSet(sensor,'pixel size', ...
            sensorGet(sensor, 'pixel size') / l3dSR.upscaleFactor);
sensorHR = sensorSet(sensorHR, 'size', ...
            sensorGet(sensor, 'size') * l3dSR.upscaleFactor);
        
switch source.type
    case 'scene'
        oi = cameraGet(l3dSR.camera, 'oi');
        oi = oiCompute(oi, source);
        sensorHR = sensorCompute(sensorHR, oi);
    case 'opticalimage'
        sensorHR = sensorCompute(sensorHR, source);
end   
ipHR = cameraGet(l3dSR.camera, 'ip');
ipHR = ipCompute(ipHR, sensorHR);
hrImg = ipGet(ipHR, 'data srgb');

%% Plot the result
vcNewGraphWin;
subplot(1, 3, 1); imshow(lrImg); % title('low resolution img');
subplot(1, 3, 2); imshow(hrImg); % btitle('high resolution img');
subplot(1, 3, 3); imshow(xyz2srgb(outImg*5)); % title('l3 rendered img');