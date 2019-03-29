%% t_L3SuperResolutionInterp

%% Initiation
ieInit;

%% Set the destination folder

dFolder = fullfile(L3rootpath,'local','scenes');

%% Download the scene from RDT
rdt = RdtClient('scien');
rdt.readArtifacts('/L3/quad/scenes','destinationFolder',dFolder);

%% Load the scenes. Here we have 22 scenes from the COCO dataset.
% Common objects in context.

format = 'mat';
scenes = loadScenes(dFolder, format, 1:3);

%% Use l3DataSimulation to generate raw and desired RGB image

% 
l3dSR = l3DataSuperResolution();

% Some other scene options for evaluation
% sceneSampleOne = sceneSet(sceneCreate, 'fov', 12);
% sceneSampleTwo = sceneSet(sceneCreate('sweep'))

% Take the first scene for training.
l3dSR.sources = scenes(1:3);

% Set the upscale factor to be 4
l3dSR.upscaleFactor = 4;

%% Adjust the settings of the camera
camera = l3dSR.camera;

% Let's try to use this instead:
% 
sensor = cameraGet(camera,'sensor');
% sensor = sensorSet(sensor, 'pixel size', 1.5e-6);
fillFactor = 1;
sensor = pixelCenterFillPD(sensor,fillFactor);
camera = cameraSet(camera,'sensor',sensor);

% data = load('NikonD100Sensor.mat', 'isa'); sensor = data.isa;
% camera = cameraSet(camera, 'sensor', sensor);
% The default photodetector position has an offset.  We should look
% into this generally for ISETCam.
% camera = cameraSet(camera, 'pixel pdXpos', 0);
% camera = cameraSet(camera, 'pixel pdYpos', 0);
% 
% % set the fill factor to be 1
% pixelSize  = cameraGet(camera, 'pixel size');
% camera = cameraSet(camera, 'pixel pdWidth', pixelSize(1));
% camera = cameraSet(camera, 'pixel pdHeight', pixelSize(2));

% Give the camera back to the L3 data instance.
l3dSR.camera = camera;

%%
[raw, tgt, pType] = l3dSR.dataGet();