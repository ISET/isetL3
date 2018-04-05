%% Example for using saturation types
%
% Exploring how to set up the saturation classes and train with
% saturated pictures.
%
% (HJ) VISTA TEAM, 2016

%% Init
ieInit

%% l3Data class
% Init data class
l3d = l3DataSimulation();

% Set up parameters for generating training data
nImg = 3;

% Exposure fraction up to auto-exposure.  2 means over-exposed
l3d.expFrac = [1.5, .9, 0.2];

% For the oi case, we are loading some of Trisha's OIs
l3d.loadSources(nImg, 'oi');

% The spatial sampling is coarse because of the large focal length
%    ieAddObject(l3d.sources{1}); oiWindow;
% So, we change the focal length here
for ii = 1 : nImg
    if strcmp(l3d.sources{ii}.type, 'opticalimage')
        % Adjust focal length so that the spatial samples are dense
        % It is also possible to leave the focal length but
        % adjust the field of view.
        % l3d.sources{ii} = oiSet(l3d.sources{ii},'fov', 2);
        l3d.sources{ii} = oiSet(l3d.sources{ii},'optics f length', 0.01);
    end
end

% Notice that the spatial sampling is now much finer
%    ieAddObject(l3d.sources{1}); oiWindow;

cfa = cameraGet(l3d.camera, 'sensor cfa pattern');

% Name of the pixels, used to label the patch statistics
pixelTypeName = arrayfun(@(x) sprintf('Pixel %d', x), cfa, ...
    'UniformOutput', false);

%% Set the training parameters
% create training class instance
l3t = l3TrainOLS();

% Define the statistics operators
l3t.l3c.statFunc = {@imagePatchMeanAndContrast, @imagePatchMax};

% The name of the statistics
l3t.l3c.statNames = [{'mean'}, {'contrast'}, pixelTypeName(:)'];

% The cell array contains
% {linear response thresholds, threshold for texture vs flat,
% saturation levels for each of the four pixel types}
linearThresholds = {logspace(-1.7, -0.23, 40)};
contrast = {[]};   % ignore contrast
vSwing = cameraGet(l3d.camera, 'pixel voltage swing');
vSat = 0.95 * vSwing;
satThresholds    = {vSat, vSat, vSat};
l3t.l3c.cutPoints = cat(2, linearThresholds, contrast, satThresholds);

% Optional parameters for the statistics function
l3t.l3c.statFuncParam = {{}, {}};

% Patch size
l3t.l3c.patchSize = [5 5];

% Invoke the training algorithm
l3t.train(l3d);
% l3t.fillEmptyKernels;

%% Render one training optical image
whichOI = 7;
whichSource = floor(whichOI/3)+1;
[raw, target, ~] = l3d.dataGet(whichOI);
raw = raw{whichOI}; target = target{whichOI};

l3r = l3Render();
cfa = cameraGet(l3d.camera, 'sensor cfa pattern');
outImg = l3r.render(raw, cfa, l3t);

vcNewGraphWin([], 'wide');
subplot(1, 3, 1); imshow(oiGet(l3d.sources{whichSource}, 'rgb image')); 
title('Optical Image');

target = target / max(max(target(:,:,2)));
subplot(1, 3, 2); imshow(xyz2srgb(target)); title('Ideal Image');

outImg = outImg / max(max(outImg(:,:,2)));
subplot(1, 3, 3); imshow(xyz2srgb(outImg)); title('L3 Rendered Image');

%% Now render synthetic scenes

scene = sceneCreate;
camera = cameraCompute(l3d.camera,scene);
raw = cameraGet(camera,'sensor volts');
outImg = l3r.render(raw, cfa, l3t);
outImg = outImg / max(max(outImg(:,:,2)));
vcNewGraphWin; imshow(xyz2srgb(outImg)); title('L3 Rendered Image');

scene = sceneCreate('frequency orientation');
camera = cameraCompute(l3d.camera,scene);
raw = cameraGet(camera,'sensor volts');
outImg = l3r.render(raw, cfa, l3t);
outImg = outImg / max(max(outImg(:,:,2)));
vcNewGraphWin; imshow(xyz2srgb(outImg)); title('L3 Rendered Image');

fname = fullfile(isetRootPath, 'data','images','multispectral', 'StuffedAnimals_tungsten-hdrs.mat'); 
scene  = sceneFromFile(fname,'multispectral');
camera = cameraCompute(l3d.camera,scene);
raw = cameraGet(camera,'sensor volts');
outImg = l3r.render(raw, cfa, l3t);
outImg = outImg / max(max(outImg(:,:,2)));
vcNewGraphWin; imshow(xyz2srgb(outImg)); title('L3 Rendered Image');

scene = sceneAdjustIlluminant(scene,'D65.mat');
camera = cameraCompute(l3d.camera,scene);
raw = cameraGet(camera,'sensor volts');
outImg = l3r.render(raw, cfa, l3t);
outImg = outImg / max(max(outImg(:,:,2)));
vcNewGraphWin; imshow(xyz2srgb(outImg)); title('L3 Rendered Image');
