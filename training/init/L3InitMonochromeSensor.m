function L3 = L3InitMonochromeSensor(L3)
% Initialize L3 monochrome sensor with default parameters.
%
%  L3 = L3InitMonochromeSensor(L3)
%
% The default settings for the optics are
%   Exposure time is set to 0.1s
%   Voltage swing is set to 1.8v
%
% More defaults are found below
%
% (c) Stanford VISTA Team 2013

%% Load from L3 structure
scenes = L3Get(L3,'scene');
oi = L3Get(L3,'oi');
wave = sceneGet(scenes{1},'wave');


%% Initialize sensor 
sensorM = sensorCreate('monochrome');
sensorM = sensorSet(sensorM,'exposure time', 1);
sensorM = sensorSet(sensorM,'wave',wave);

sensorM = sensorSet(sensorM,'filter spectra',ones(length(wave),1));
sensorM = sensorSet(sensorM,'irfilter',ones(length(wave),1));
sensorM = sensorSet(sensorM,'quantization method','analog');

%% Initialize pixel parameters 
pixel = sensorGet(sensorM,'pixel');
pixel = pixelSet(pixel,'spectralQE',ones(length(wave),1));

pixel = pixelSet(pixel,'size constant fill factor',[2.2e-6 2.2e-6]); % Pixel Size in meters
pixel = pixelSet(pixel,'conversion gain', 2.0000e-004);        % Volts/e-
pixel = pixelSet(pixel,'voltage swing', 1.8);                  % Volts/e-
pixel = pixelSet(pixel,'dark voltage', 1e-005);                % units are volts/sec
pixel = pixelSet(pixel,'read noise volts', 1.34e-003);         % units are volts

%% Finalize sensor parameters
sensorM = sensorSet(sensorM,'pixel',pixel);
sensorM = pixelCenterFillPD(sensorM, 0.45);

sensorM = sensorSet(sensorM,'dsnu level',14.1e-004); % units are volts
sensorM = sensorSet(sensorM,'prnu level',0.002218);  % units are percent

hfov = sceneGet(scenes{1},'hfov');
[rows, cols] = L3SensorSize(sensorM,hfov,scenes{1},oi);
sensorM = sensorSet(sensorM,'size',[rows cols]);

 
%% Set defaults
expTime  = 0.10;  % exposure time in sec
sensorM = sensorSet(sensorM, 'exp time', expTime);

voltageswing = 1.8;
pixel = sensorGet(sensorM, 'pixel');
pixel = pixelSet(pixel, 'voltage swing', voltageswing);
sensorM = sensorSet(sensorM, 'pixel', pixel);

%% Store in L3 structure
L3 = L3Set(L3, 'monochrome sensor', sensorM);
