function L3camera = L3TrainCameraforCFA(cfaFile)

%% L3TrainCameraforCFA
%
% This function creates an L3 camera for a specified CFA file.
%
% Besides the CFA, all values for the camera are specified inside the
% function.  Perhaps we will commit to a set of values for training scenes,
% optics, sensor, and L3 parameters and investigate the impact of the CFA
% only.  The goal of this function is to easily enable that.
% 
% This is modeled after s_L3TrainCamera.
%
% (c) Stanford VISTA Team

%% Load the scenes for training
% Scenes is a cell array of all the scenes to use for training.
sNames = dir(fullfile(L3rootpath,'Data','Scenes','*scene.mat'));

% The training scenes are set to the following horizontalFOV.  This
% determines the size of the sensor used during training.   Larger
% values should be used for horizontalFOV when images are larger.  Do not
% use a horizontalFOV value that is so large the sensor is oversampling the
% original scene.
horizontalFOV = 4;  %degrees

% Sometimes we want the learned camera to operate on a different field of
% view than set for the training scenes.  After training, the size of the
% sensor is adjusted so that the output camera has the following value for
% its horizontal field of view.  There may be some slight differences
% between image statistics for different FOV values caused by the optics,
% but hopefully this is small.
desiredhorizontalFOV = 30;  %degrees

nScenes = length(sNames);

scenes = cell(nScenes,1);
for ii=1:nScenes
    thisName  = fullfile(L3rootpath,'Data','Scenes',sNames(ii).name);
    data = load(thisName,'scene');
    scenes{ii}  = data.scene;
    
    scenes{ii} = sceneSet(scenes{ii},'hfov',horizontalFOV);
    % vcAddAndSelectObject(scenes{ii}); 
end
% sceneWindow;


%% Design sensor exposure duration
expTime  = 0.1;  % exposure time in sec

%% Ideal Filters (desired output channels)
% Monochrome sensor with the ideal (desired) filters
idealS.name = 'XYZQuanta';  %name of file containing spectral curves
idealS.filterNames = {'rX','gY','bZ'};  %name for filters, only used to color plots

%% L3 training parameters
blockSize = 9;               % Size of the solution patch used by L3
nLuminanceSteps = 10;
voltageswing = 1.8;
% patchLuminanceSamples = linspace(0.1*voltageswing,0.85*voltageswing,nLuminanceSteps);
patchLuminanceSamples = exp(linspace(log(0.05*voltageswing),log(0.9*voltageswing),nLuminanceSteps));

%% Optics parameters
fnumber = 4;
focallength = 3e-3;  %units are meters


%% Rest of script forms the L3camera using the above parameters
%% Create oi (optics)
oi = oiCreate;
optics = oiGet(oi,'optics');
optics = opticsSet(optics,'f number',fnumber);
optics = opticsSet(optics,'focal length',focallength);   % units are meters
oi     = oiSet(oi,'optics',optics);

%% Create the design sensor (sensorD) and set its exposure duration
sensorM = L3SensorCreate(scenes{1},oi);
sensorM = sensorSet(sensorM,'exp time',expTime);
pixel = sensorGet(sensorM,'pixel');
pixel = pixelSet(pixel,'voltage swing',voltageswing);
sensorM = sensorSet(sensorM,'pixel',pixel);

%% Load color filters
wave = sceneGet(scenes{1},'wave');   %use the wavelength samples from the first scene
idealS.wave = wave;
idealS.transmissivities = vcReadSpectra(idealS.name,wave);   %load and interpolate filters
sensorD = sensorM;

%% Build design sensor
cfaData = load(cfaFile);

sensorD = sensorSet(sensorD,'wave',wave);
sensorD = sensorSet(sensorD,'filterspectra',vcReadSpectra(cfaFile,wave));
sensorD = sensorSet(sensorD,'filter names',cfaData.filterNames);
sensorD = sensorSet(sensorD,'name','Design sensor');
sensorD = sensorSet(sensorD,'cfa pattern',cfaData.filterOrder);
% vcNewGraphWin; plot(wave,designS.transmissivities)

%% Initialize the L3 structure and store key variables
% This is a natural break point.  We could create everything in a separate
% script above and then train here on the list of scenes.

L3 = L3Create;
L3 = L3Set(L3,'oi',oi);
L3 = L3Set(L3,'monochrome sensor',sensorM);
L3 = L3Set(L3,'ideal filters',idealS);
L3 = L3Set(L3,'design sensor',sensorD);
L3 = L3Set(L3,'block size', blockSize);
L3 = L3Set(L3,'luminance list',patchLuminanceSamples);

%% Attach the cell array of scenes.
L3 = L3Set(L3,'scene',scenes);
[desiredIm, inputIm] = L3SensorImageNoNoise(L3);

%% Perform training
L3 = L3Train(L3,desiredIm,inputIm);

%% Adjust sensor size to get desired horizontal field of view
L3 = L3AdjustSensorSize(L3,desiredhorizontalFOV,scenes{1},oi);

%% Setup L3 camera
L3camera = cameraCreate('L3',L3);

%% Go to s_L3render to use the camera.
