%% s_L3LowLightBalancing
%
% This script shows how to set up L3 structures to train and create an L3
% camera with low light balancing scheme, and render images using the L3
% pipeline with the created camera.
%
% (c) Stanford VISTA Team

clear, clc, close all

% Start ISET
s_initISET
dataroot = '/biac4/wandell/data/qytian/L3Project';

%% Training part

% Create and initialize L3 structure
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
% and variance). See L3findfilters.  
%
% It's a length 3 vector with each component corresponding to the desired
% weight for output channels. In luminance channel, large weight blurs
% image. In chromance channel, large weight desaturats color.
%
% Flat and texture regions have different weights setting. In this way, we
% can blur the flat regions more to decrease noise while keeping the
% sharpness of the texture regions.
%
% It's used across the full range of luminance levels. It mainly works for
% low light condition, and has neglectable influence when it's bright. 

% Not seting the weights parameter or using three same values will not
% perform low light balancing.
weights = [1, 1, 1];  
L3 = L3Set(L3, 'global weight bias variance', weights);

% The weights below for flat and texture regions were chosen via subjective
% experiments, which give satisfying results. 
%
% In chromance channels for both flat and texture regions, we use same 
% number of 4 to desaturate the color a little bit to make the chromatic 
% noise less annoying. We do not differentiate the two opponent color 
% channels. Note the corresponding weights for flat and texture regions 
% should be same. Otherwise the color saturation won't keep consistent 
% across the whole image. 
%
% In luminance channel, we use a number of 16 for flat regions to strongly
% blur flat regions to reduce spatial noise. While for texture regions, we
% use a number of 1 to keep the sharpness of the textures. 
weights = [4, 16, 4];
weights = [4, 1, 4];
L3 = L3Set(L3, 'flat weight bias variance', weights);

weights = [4, 1, 4];
L3 = L3Set(L3, 'texture weight bias variance', weights);

% Perform training
L3 = L3Train(L3);

% Save L3
name = 'L3_RGBW_global_none_flat_4_16_4_texture_4_1_4';
name = 'L3_RGBW_global_none_flat_4_1_4_texture_4_1_4';
L3 = L3Set(L3, 'name', name);
saveL3 = fullfile(dataroot, 'l3', [L3Get(L3, 'name') '.mat']);
save(saveL3, 'L3');

%% Rendering part 
% Load L3
name = 'L3_RGBW_global_none_flat_4_16_4_texture_4_1_4.mat';
loadL3 = fullfile(dataroot, 'l3', name);
load(loadL3);

% Load scene
loadScene = fullfile(dataroot, 'scene', 'AsianWoman_1.mat');
scene = sceneFromFile(loadScene, 'multispectral');

% Create camera from L3 structure
camera = L3CameraCreate(L3);
camera = cameraSet(camera,'vci name','l3'); % specify L3 pipeline
sz = sceneGet(scene, 'size');

for meanLum = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, ...
              90, 100, 150, 200, 300, 400, 500] % various scene mean lumin 
    % Compute sRGB results
    [srgbResult, srgbIdeal, raw, camera] = cameraComputesrgb(camera, scene, meanLum, sz);
    
    % Save sRGB results
    renderType = cameraGet(camera, 'vcitype');
    L3name = L3Get(L3, 'name');
    saveImage = fullfile(dataroot, 'image', ['sRGB_' L3name '_' renderType... 
        '_meanLum_' num2str(meanLum) '.png']);
    imwrite(srgbResult, saveImage);
end

saveImage = fullfile(dataroot, 'image', 'sRGB_ideal.png');
imwrite(srgbIdeal, saveImage);























