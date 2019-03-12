%% t_L3SuperResolution
% Explore the super resolution based on L3 approach. The idea is change the
% pixel size according to the upscale factor. In this way, we can adjust
% the resolution of the sensor and thus the resolution of the final image.
%
% Zheng Lyu, BW 2019

%% Initiation
ieInit;
%% Set the destination folder

dFolder = fullfile(L3rootpath,'local','scenes');
%% Download the scene from RDT
rdt = RdtClient('scien');
rdt.readArtifacts('/L3/quad/scenes','destinationFolder',dFolder);

%% Load the scenes. Here we have 22 scenes
format = 'mat';
scenes = loadScenes(dFolder, format, [1:22]);

%% Use l3DataSimulation to generate raw and desired RGB image
l3dSR = l3DataSuperResolution();

% Some other scene options for evaluation
% sceneSampleOne = sceneSet(sceneCreate, 'fov', 12);
% sceneSampleTwo = sceneSet(sceneCreate('sweep'))

% Take the first scene for training.
l3dSR.sources = scenes(1:15);

% Set the upscale factor to be 8
l3dSR.upscaleFactor = 8;
%% Adjust the settings of the camera
camera = l3dSR.camera;
camera = cameraSet(camera, 'pixel pdXpos', 0);
camera = cameraSet(camera, 'pixel pdYpos', 0);

% set the fill factor to be 1
pixelSize  = cameraGet(camera, 'pixel size');
camera = cameraSet(camera, 'pixel pdWidth', pixelSize(1));
camera = cameraSet(camera, 'pixel pdHeight', pixelSize(2));

% Give the camera back to the L3 data instance.
l3dSR.camera = camera;
%% Specify to use the classification approach for super resolution.
l3tSuperResolution = l3TrainRidge('l3c', l3ClassifySR);

%% Set the parameters for the L3 training instance

% Calculate the number of the saturation conditions
nSatSituation = [1:2^numel(l3dSR.cfa)-1];

% Set up the cut points
l3tSuperResolution.l3c.cutPoints = {logspace(-1.7, -0.12, 30),...
                                        [], nSatSituation};
                                    
% Set the size of the patch                                    
l3tSuperResolution.l3c.patchSize = [7 7];

%% Invoke the training algorithm
l3tSuperResolution.train(l3dSR);

%% Evaluation process. TO BE IMPLEMENTED INTO THE checklinearfit function.
thisKernel = 100;
kernel  = l3tSuperResolution.kernels{thisKernel};
[X, y] =l3tSuperResolution.l3c.getClassData(thisKernel); 
X = padarray(X, [0 1], 1, 'pre');
y_fit = X * kernel;
thisChannel = 10;
plot(y_fit(:,thisChannel), y(:,thisChannel), 'o');
axis square; 
identityLine;

%% Render a scene to evaluate the training result
l3rSR = l3RenderSR();

% Set a test scene
thisScene = 17;
source = scenes{thisScene};
% sceneWindow(source);

% Other options for evaluation
% source = sceneCreate('rings rays');
% source = sceneCreate('sweep frequency');

% Use isetcam to compute the camera data.
sensor = cameraGet(l3dSR.camera, 'sensor');

% Converte the source to optical image if input is a scene.
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

% Get the ip for the low resolution
ipLR = cameraGet(l3dSR.camera, 'ip');
ipLR = ipCompute(ipLR, sensor);
lrImg = ipGet(ipLR, 'data srgb');

% Compute L3 rendered image
outImg = l3rSR.render(cmosaic, cfa, l3tSuperResolution, l3dSR);
%% Set the HR camera

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
subplot(1, 3, 3); imshow(xyz2srgb(outImg)); % title('l3 rendered img');