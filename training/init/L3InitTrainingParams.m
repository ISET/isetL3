function L3 = L3InitTrainingParams(L3)

% Initialize L3 training parameters with default values
%
%   L3 = L3InitTrainingParams(L3)
%
% Default values:
%       Block size for the L3 patch is set to 9 pixels
%       Patch luminance levels are 10 linear samples that span the linear
%       Voltage range located between [0.05,0.9] * voltage swing
%       See below for more defaults
%
% (c) Stanford VISTA Team 2013
% L3 default parameters


L3 = L3Set(L3,'block size', 9);

sensorM = L3Get(L3, 'monochrome sensor');
pixel = sensorGet(sensorM, 'pixel');
voltageswing = pixelGet(pixel, 'voltageswing');
% This sampling scheme was optimized through extensive experiments for
% default RGB/W CFA with voltage swing equal to 1.8. Under low light 
% condition when the SNR changes rapidly, denser samples should be used.
% This is a general rule. Here we use geometric sampling scheme. When it's
% bright, a sparse linear sampling is enough. The number of samples was
% chosen based on subjective experiments. The cut-off point between low and
% high light conditions is chosen as 0.45, when W pixels start saturation.
% The sampling might vary for different CFAs, voltage swing etc and should 
% properly tuned. The simplest way is linear sampling as:
% nLuminanceSteps = 10;
% patchLuminanceSamples = linspace(0.05*voltageswing,0.9*voltageswing,nLuminanceSteps);
patchLuminanceSamples = [0.001, 0.0016, 0.0026, 0.0041, 0.0065, 0.0104, 0.0166, 0.0266, 0.0424, 0.0678, 0.1082, 0.1729, 0.2762,...
                           0.4505, 0.6753, 0.9, 1.1248, 1.3495, 1.5743, 0.99*voltageswing];
L3 = L3Set(L3,'luminance list', patchLuminanceSamples);

%% Defaults that were previously in L3Create
L3 = L3Set(L3,'n oversample',0);
L3 = L3Set(L3,'saturation flag', 1);
L3 = L3Set(L3,'sigma factor',1);
L3 = L3Set(L3,'random seed',0);
L3 = L3Set(L3,'max tree depth',1);
L3 = L3Set(L3,'flat percent',0.6);
L3 = L3Set(L3,'weight color transform',1);
L3 = L3Set(L3,'global weight bias variance',1);
L3 = L3Set(L3,'flat weight bias variance',1);
L3 = L3Set(L3,'texture weight bias variance',1);

