function [noise,snr] = L3noisegenerate(measurements,sensor)

% Simulates noise for measurements from a sensor
% 
%   [noise,snr] = L3noisegenerate(measurements,cameraparams)
%
%INPUTS:
%   measurements:  noise-free sensor measurements
%      If the measurements are patches, then they are
%      blockwidth^2 x nPatches
%   sensor:  ISET sensor containing parameters for noise simulation
%
%OUTPUTS:
%   noise:  matrix same size as measurements so
%           noisy measurements = measurements + noise
%   snr:    mean signal to noise ratio of the measurements + noise in dB
%
% Copyright Steven Lansel, 2010

%%
if ieNotDefined('measurements'), error('measurements required.'); end
if ieNotDefined('sensor'), error('sensor required.'); end


%% Make noisey version of the measurements

% vcNewGraphWin; hist(measurements(:),100)

% Just copy the voltages into the monochrome sensor values.
sensor = sensorSet(sensor,'volts',measurements);

% This computes the noise 
sensor = sensorAddNoise(sensor);
noisymeasurements = sensorGet(sensor,'volts');
% vcNewGraphWin; hist(noisymeasurements(:),100)

%%  Saturation calculation
pixel = sensorGet(sensor,'pixel');
voltageSwing = pixelGet(pixel,'voltage swing');  % pixel's actual voltage swing
ao = sensorGet(sensor,'analogOffset');
ag = sensorGet(sensor,'analogGain');
voltagemax = voltageSwing - ao/ag;       % maximum voltage for L3 train & render
noisymeasurements(noisymeasurements>voltagemax) = voltagemax;
noisymeasurements(noisymeasurements<0) = 0;


%% Pull out the pure nosie
noise = noisymeasurements - measurements;


% If needed return snr
if nargout==2
    snr=10*log10(mean(measurements(:).^2)/mean(noise(:).^2));
end

return
