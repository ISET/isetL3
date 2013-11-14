%% Let's convert this to a demo.


%% s_L3TrainCamersforBalancing
%
% This script shows how to set up L3 structures to train and create an L3
% camera with low light balancing scheme. 
%
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Create and initialize L3 structure
L3 = L3Initialize();  % use default parameters

% Find transform from XYZ to opponent color space that depends on W. We
% will perform low light balancing on this new space instead of XYZ space.
A = L3findRGBWcolortransform(L3);
L3 = L3Set(L3, 'weight color transform', A);

% Set bias and variance weights for different contrast types, i.e. global,
% flat and texture. 
%
% Larger value means variance (noise) is more costly and should be avoided.
% Value of 1 implies minimum squared error is desired (equal weight to bias
% and variance), and no balancing is performed.
%
% Bias and variance weights can be a length 3 vector with each component
% corresponding to the desired weight for output opponent color channels.
% The first and third correspond to chromance channels, while the second
% corresponds to luminance channel. Bias and variance weights can also be a
% scale, which will be used for all the three channels.
%
% In luminance channel, large weight blurs image. In chromance channel,
% large weight desaturats color.
%
% Flat and texture regions should have different weights setting. In this
% way, we can blur the flat regions more to decrease noise while keeping
% the sharpness of the texture regions.
%
% It's used across the full range of luminance levels. It mainly works for
% low light condition, and has neglectable influence when it's bright. 
% 
% Setting bias and variance weights to 1, [1, 1, 1] or not setting it
% (default is 1) performs no balancing, which is equivalent to the way to
% train camera without balancing in script s_L3TrainCamera. 

% Setting bias and variance weights for 'global' method
weights = [4, 4, 4];  
L3 = L3Set(L3, 'global weight bias variance', weights);

% Setting bias and variance weights for flat and texture regions for 'L3'
% method. The weights used below were chosen via subjective experiments of
% QT, SL and MF.
%
% In chromance channels (1st and 3rd) for both flat and texture regions, we
% use the same medium number 4 to desaturate the color a little bit to make
% the chromatic noise less annoying. We do not differentiate the two
% opponent color channels. Note the corresponding weights for flat and
% texture regions should be identical. Otherwise the color saturation won't
% keep consistent across the whole image.
%
% In luminance channel (2nd), we use a large number 16 for flat regions to
% strongly blur them to reduce spatial noise. While for texture regions, we
% use a small number 1 (no balancing at all) to keep the sharpness of the
% textures.
weights = [4, 16, 4];
L3 = L3Set(L3, 'flat weight bias variance', weights);

weights = [4, 1, 4];
L3 = L3Set(L3, 'texture weight bias variance', weights);

%% Perform training
L3 = L3Train(L3);

%% Setup L3 camera
camera = L3CameraCreate(L3);

%% Use the camera with s_L3Render, cameraCompute, or cameraComputesRGB











