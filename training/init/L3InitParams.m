function L3 = L3InitParams(L3)

% Initialize L3 training and rendering parameters with default values
%
%   L3 = L3InitParams(L3)
%
% Default values:
%       Block size for the L3 patch is set to 9 pixels
%       
%       See below for more defaults
%
% (c) Stanford VISTA Team 2013
% L3 default parameters


L3 = L3Set(L3,'block size', 9);

% This sampling scheme was optimized through extensive experiments for
% default RGB/W CFA with voltage swing equal to 1.8. Under low light 
% condition when the SNR changes rapidly, denser samples should be used.
% This is a general rule. Here we use geometric sampling scheme. When it's
% bright, a sparse linear sampling is enough. The number of samples was
% chosen based on subjective experiments. The cut-off point between low and
% high light conditions is chosen as 0.45, when W pixels start saturation.
% The sampling might vary for different CFAs, voltage swing etc and should
% be properly tuned. The simplest way is linear sampling as:

% Following reduces voltage swing to account for the reduced voltage swing
% after we subtract off the offset.  For example original data is in
% interval [ao/ag, voltageswing] but new range is [0, voltageswing-ao/ag]
voltagemax = L3Get(L3,'voltage max');

nLuminanceSteps = 20;
patchLuminanceSamples = linspace(0.01*voltagemax,0.99*voltagemax,nLuminanceSteps);

% following was made specifically for RGBW assuming votlageswing=1.8
% patchLuminanceSamples = [0.001, 0.0016, 0.0026, 0.0041, 0.0065, 0.0104, 0.0166, 0.0266, 0.0424, 0.0678, 0.1082, 0.1729, 0.2762,...
%                            0.4505, 0.6753, 0.9, 1.1248, 1.3495, 1.5743, 0.99*voltageswing];
L3 = L3Set(L3,'luminance list', patchLuminanceSamples);

%% Defaults that were previously in L3Create
L3 = L3Set(L3,'n oversample',0);
L3 = L3Set(L3,'saturation flag', 1);
L3 = L3Set(L3,'random seed',0);
L3 = L3Set(L3,'max tree depth',1);
L3 = L3Set(L3,'flat percent',0.6);
L3 = L3Set(L3,'min non sat channels', 0);  
% we can control how many non-saturation channels we want. To estimate XYZ
% we need 3 good channels. It's initialized to be turned off.

%% Bias and Variance Weights
% Find color space conversion matrix
A = L3findweightcolortransform(); 
L3 = L3Set(L3, 'weight color transform', A);

% Set bias and variance tradeoff weights. It's initialized to be turned off.
weights = [1, 1, 1];  
L3 = L3Set(L3, 'global weight bias variance', weights); 
L3 = L3Set(L3, 'flat weight bias variance', weights);
L3 = L3Set(L3, 'texture weight bias variance', weights);

% Following is the optimal bias and variance tradeoff weights specifically 
% designed for RGB/W CFA.

% weights = [4, 4, 4];  
% L3 = L3Set(L3, 'global weight bias variance', weights);
% weights = [4, 16, 4]; 
% L3 = L3Set(L3, 'flat weight bias variance', weights);
% weights = [4, 1, 4]; 
% L3 = L3Set(L3, 'texture weight bias variance', weights);

%% The training and rendering illuminant
L3 = L3Set(L3, 'training illuminant', 'D65.mat');
L3 = L3Set(L3, 'rendering illuminant', 'D65.mat');

%% Maximum number of training patches for each patch type
% Following is a smaller value for quick testing.  This should probably be
% increased for actual results.  81000 is similar to number of patches in
% previous method (prior 11/2013) for 2x2 CFA.  On a regular laptop, around
% 400000 is feasible but slow.
L3 = L3Set(L3,'max training patches', 100000);

%% Set flat and texture transition contrast bounds
% Flat and texture filters are optimized on differnt set of training
% patches and thus are differnt. Thus the transition between flat and
% texture regions is not smooth. This is a problem for Wiener filters and
% becomes more obvious if we perform bias and variance tradeoff, i.e. we
% blur the flat regions more than texture regions. Thus during the
% transition regions, we linearly interpolate the filters in order to
% smoothen the transition. The bounds are specified as the ratios of the 
% flat and texture contrast threshold. They are not necessarily symmetic 
% on each side.
L3 = L3Set(L3, 'transition contrast low', 0.95);
L3 = L3Set(L3, 'transition contrast high', 1.15);
