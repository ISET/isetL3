%% s_L3TrainCamera
%
% This script trains and creates an L3 camera.
%
% The top half of the script sets important parameters for the camera and
% L3 processing.
%
% The bottom half of the script uses the parameters and calls the training
% function, L3Train.m.
%
% BW (c) Stanford VISTA Team

%%
s_initISET

%% Load the scenes for training

% Scenes is a cell array of all the scenes to use for training.
sNames = dir(fullfile(L3rootpath,'Data','Scenes','*scene.mat'));
horizontalFOV = 4;

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


%% Design sensor color filter array and exposure duration
designS.name = 'RGBW';  %name of file containing spectral curves
designS.filterNames = {'r','g','b','w'};    %name for filters, only used to color plots
cfaPattern = [1 2; 3 4];    %arrangement of the above filters

expTime  = 0.010;  % exposure time in sec

%% Ideal Filters (desired output channels)
% Monochrome sensor with the ideal (desired) filters
idealS.name = 'XYZQuanta';  %name of file containing spectral curves
idealS.filterNames = {'rX','gY','bZ'};  %name for filters, only used to color plots

%% L3 training parameters
blockSize = 5;               % Size of the solution patch used by L3
nLuminanceSteps = 10;
voltageswing = 1.8;
patchLuminanceSamples = linspace(0.1*voltageswing,0.75*voltageswing,nLuminanceSteps);

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
designS.wave = wave;
designS.transmissivities = vcReadSpectra(designS.name,wave);   %load and interpolate filters

%% Build design sensor
sensorD = sensorSet(sensorD,'wave',designS.wave);
sensorD = sensorSet(sensorD,'filterspectra',designS.transmissivities);
sensorD = sensorSet(sensorD,'filter names',designS.filterNames);
sensorD = sensorSet(sensorD,'name','Design sensor');
sensorD = sensorSet(sensorD,'cfa pattern',cfaPattern);
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

%% Setup L3 camera
camera = cameraCreate('L3',L3);

%% Go to s_L3render to use the camera.
