function L3 = L3InitDesignSensor(L3)

% Initialize design sensor with default parameters
%
% L3 = L3InitDesignSensor(L3)
%
% Design filters are set to 'RGBW'. 
% CFA pattern is set to [1, 2; 3, 4].
%
% (c) Stanford VISTA Team 2013

%% Load from L3 structure
sensorM = L3Get(L3, 'monochrome sensor');
scenes = L3Get(L3,'scene');
wave = sceneGet(scenes{1}, 'wave');   %use the wavelength samples from the first scene

%% Set defaults
% Design sensor is based on an L3 monochrome sensor
sensorD = sensorM; 

% Design sensor color filter array and exposure duration
designFilters.name = fullfile(L3rootpath,'data','sensors','CFA','RGBW');  %name of file containing spectral curves
designFilters.filterNames = {'r','g','b','w'};    %name for filters, only used to color plots
cfaPattern = [1 2; 4 3];    %arrangement of the above filters
designFilters.wave = wave;
designFilters.transmissivities = vcReadSpectra(designFilters.name, wave);   %load and interpolate filters

% Build design sensor
sensorD = sensorSet(sensorD, 'name', 'Design sensor');
sensorD = sensorSet(sensorD, 'filter names', designFilters.filterNames);
sensorD = sensorSet(sensorD, 'wave', designFilters.wave);
sensorD = sensorSet(sensorD, 'filterspectra', designFilters.transmissivities);
sensorD = sensorSet(sensorD, 'cfa pattern', cfaPattern);
% vcNewGraphWin; plot(wave,designS.transmissivities)

%% Store in L3 structure
L3 = L3Set(L3,'design sensor', sensorD);
