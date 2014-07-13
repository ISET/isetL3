function L3 = L3InitDesignSensor(L3)

% Initialize design sensor with default parameters
%
% L3 = L3InitDesignSensor(L3)
%
% The default settings are
%   Design filters are set to 'RGBW'. 
%   CFA pattern is set to [1, 2; 3, 4].
%   Exposure time is set to 0.1s
%   Voltage swing is set to 1.8v
%
% More defaults are found below
%
%
%
% (c) Stanford VISTA Team 2013

%% Load from L3 structure
scenes = L3Get(L3,'scene');
oi = L3Get(L3,'oi');
wave = sceneGet(scenes{1},'wave'); %use the wavelength samples from the first scene

%% Initialize sensor 
sensorD = sensorCreate; 
sensorD = sensorSet(sensorD, 'name', 'Design sensor');
sensorD = sensorSet(sensorD,'wave',wave);

%% Initialize pixel parameters 
pixel = sensorGet(sensorD,'pixel');
pixel = pixelSet(pixel,'spectralQE',ones(length(wave),1));
pixel = pixelSet(pixel,'size constant fill factor',[2.2e-6 2.2e-6]); % Pixel Size in meters
pixel = pixelSet(pixel,'conversion gain', 2.0000e-004);        % Volts/e-
pixel = pixelSet(pixel,'voltage swing', 1.8);                  % Volts/e-
pixel = pixelSet(pixel,'dark voltage', 1e-005);                % units are volts/sec
pixel = pixelSet(pixel,'read noise volts', 1.34e-003);         % units are volts
sensorD = sensorSet(sensorD,'pixel',pixel);


%% Initialize sensor parameters
sensorD = pixelCenterFillPD(sensorD, 0.45);
sensorD = sensorSet(sensorD,'dsnu level',14.1e-004); % units are volts
sensorD = sensorSet(sensorD,'prnu level',0.002218);  % units are percent

hfov = sceneGet(scenes{1},'hfov');
[rows, cols] = L3SensorSize(sensorD, hfov, scenes{1}, oi);
sensorD = sensorSet(sensorD,'size',[rows cols]);

expTime  = 0.10;  % exposure time in sec
sensorD = sensorSet(sensorD, 'exp time', expTime);

sensorD = sensorSet(sensorD, 'analog gain', 1);
sensorD = sensorSet(sensorD, 'analog offset', 0);

%% Initialize color filter array
sensorD = sensorSet(sensorD, 'filter names', {'r','g','b','w'}); %name for filters, only used to color plots
sensorD = sensorSet(sensorD, 'wave', wave); % same as the wave of scenes
sensorD = sensorSet(sensorD, 'cfa pattern', [1 2; 4 3]); %arrangement of the above filters

filename = fullfile(L3rootpath,'data','sensors','CFA','RGBW');  %name of file containing spectral curves
transmissivities = vcReadSpectra(filename, wave);   %load and interpolate filters
sensorD = sensorSet(sensorD, 'filter spectra', transmissivities);
% vcNewGraphWin; plot(wave,designS.transmissivities)

sensorD = sensorSet(sensorD,'irfilter',ones(length(wave),1));

%% Store in L3 structure
L3 = L3Set(L3,'design sensor', sensorD);
