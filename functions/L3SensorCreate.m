function sensor = L3SensorCreate(scene,oi,varargin)
%Create an L3 monochrome sensor used for training
%
%   sensor = L3SensorCreate(scene,oi,varargin)
%
% The sensor wavelength and size properties match the scene and oi. In the
% future we will allow sending in param-val pairs
%
% The sensor created here has the spectral QE set to match the filters
% alone. (The photodetector, single filter, and irfilter spectral curves
% are all set to one).
%
% (c) Stanford VISTA Team

%%
if ieNotDefined('scene'), error('Scene required'); end
if ieNotDefined('oi'), error('Scene required'); end

hfov = sceneGet(scene,'hfov');
wave = sceneGet(scene,'wave');

%% Initialize sensor 
sensor = sensorCreate('monochrome');
sensor = sensorSet(sensor,'exposure time', 1);
sensor = sensorSet(sensor,'wave',wave);

sensor = sensorSet(sensor,'filter spectra',ones(length(wave),1));
sensor = sensorSet(sensor,'irfilter',ones(length(wave),1));
sensor = sensorSet(sensor,'quantization method','analog');

%% Initialize pixel parameters 
pixel = sensorGet(sensor,'pixel');
pixel = pixelSet(pixel,'spectralQE',ones(length(wave),1));
pixel = pixelSet(pixel,'size',[2.2e-6 2.2e-6]);                % Pixel Size in meters
pixel = pixelSet(pixel,'conversion gain', 2.0000e-004);        % Volts/e-
pixel = pixelSet(pixel,'voltage swing', 1.8);                  % Volts/e-
pixel = pixelSet(pixel,'dark voltage', 1e-005);                % units are volts/sec
pixel = pixelSet(pixel,'read noise volts', 1.34e-003);         % units are volts

%% Finalize sensor parameters
sensor = sensorSet(sensor,'pixel',pixel);
sensor = pixelCenterFillPD(sensor, 0.45);

sensor = sensorSet(sensor,'dsnu level',14.1e-004); % units are volts
sensor = sensorSet(sensor,'prnu level',0.002218);  % units are percent

[rows, cols] = L3SensorSize(sensor,hfov,scene,oi);
sensor = sensorSet(sensor,'size',[rows cols]);

%% Varargin param-val pairs interpreted here

if isempty(varargin), return;
else
    nArgs = length(varargin);
    for ii=1:2:(nArgs-1)
        sensor = sensorSet(sensor,varargin{ii},varargin{ii+1});
    end
end

end