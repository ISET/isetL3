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
nLuminanceSteps = 10;
patchLuminanceSamples = linspace(0.05*voltageswing,0.9*voltageswing,nLuminanceSteps);
L3 = L3Set(L3,'luminance list', patchLuminanceSamples);


%% Defaults that were previously in L3Create
L3 = L3Set(L3,'n oversample',0);
L3 = L3Set(L3,'saturation flag', 1);
L3 = L3Set(L3,'sigma factor',1);
L3 = L3Set(L3,'random seed',0);
L3 = L3Set(L3,'max tree depth',1);
L3 = L3Set(L3,'flat percent',0.6);
L3 = L3Set(L3,'weight color transform',1);
L3 = L3Set(L3,'weight bias variance',1);

