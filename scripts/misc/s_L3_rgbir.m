%% s_L3_rgbir
%
%  Simulate and evaluate an RGB-IR camera with 2x2 color filter array
%
% 
% HJ, VISTA TEAM, 2016

%% Init
% init ISET session
ieInit;

% init parameters
cfa = [2 1; 3 4];
patchSz = [5 5];
padSz = (patchSz-1)/2;
nTrain = 1; % train on first images and test on the second one
expFrac = 0.1:0.1:1;
wave = 420:10:950;
pixelSz = 2.75e-6;

% init remote data toolbox
rdt = RdtClient('isetbio');
rdt.crp('/resources/scenes/hyperspectral/stanford_database');
s = rdt.listArtifacts;

%% Create L3 data structure
% load rgb-ir camera model
camera = cameraCreate;
camera = cameraSet(camera, 'oi wave', wave);
camera = cameraSet(camera, 'sensor wave', wave);
camera = cameraSet(camera, 'sensor cfa pattern', cfa);
fspec  = ieReadSpectra('rgbIR_spd.mat', wave);
camera = cameraSet(camera, 'sensor filter spectra', fspec);
camera = cameraSet(camera, 'sensor ir filter', ones(length(wave), 1));
camera = cameraSet(camera, 'pixel spectral qe', ones(length(wave), 1));
camera = cameraSet(camera, 'sensor filter name', ...
                     {'red', 'green', 'blue', 'ir'});
camera = cameraSet(camera, 'pixel size constant fill factor', pixelSz);

% load rgb-ir scenes
scenes = cell(nTrain+1, 1);
indx = 1;
for ii = 1 : nTrain + 1
    while ~strcmp(s(indx).type, 'mat'), indx = indx + 1; end
    scenes{ii} = sceneFromBasis(rdt.readArtifact(s(indx).artifactId));
    scenes{ii} = sceneSet(scenes{ii}, 'wave', wave);
    indx = indx + 1;
end

% create l3 data structure
% In some cases, we might want to turn off the noise
% camera = cameraSet(camera, 'sensor noise flag', 0);
l3d = l3DataSimulation('camera', camera, 'expFrac', expFrac, 'sources', scenes);
[raw, xyz] = l3d.dataGet(nTrain+1); % the extra 1 is for testing

%% Learn local linear kernels
l3t = l3TrainRidge();
l3t.l3c.patchSize = patchSz;
l3t.l3c.cutPoints = {logspace(-2.5, -.5, 40), []};
trainIndx = 1:nTrain*length(l3d.expFrac);
l3t.train(l3DataCamera(raw(trainIndx), xyz(trainIndx), cfa));

%% Plot
%  plot center pixel weight of green towards the output red channel as a
%  function of response level
cPixelType = 1; % green
indx = l3t.l3c.query('pixelType', cPixelType);
k = cat(3, l3t.kernels{indx});
k = k(2:end, :, :);
k = bsxfun(@rdivide, abs(k), sum(abs(k)));
k = reshape(k(13, :, :), l3t.nChannelOut, [])';
respLev = l3t.l3c.classCenters{1};
respLev(1) = 0;
respLev(end) = cameraGet(camera, 'sensor voltage swing');
vcNewGraphWin; plot(respLev, k);
xlabel('Mean response level'); ylabel('Normalized center pixel weight');

%  plot the total weight of white pixel as a function of response level
wWeight = zeros(l3t.l3c.nLabels, l3t.nChannelOut);
for ii = cPixelType : l3t.l3c.nPixelTypes : l3t.l3c.nLabels
    curCFA = l3t.l3c.getClassCFA(ii);
    curK = l3t.kernels{ii}(2:end, :);
    wWeight(ii, :) = sum(abs(curK(curCFA==4, :))) ./ sum(abs(curK));
end
vcNewGraphWin; plot(respLev, wWeight(cPixelType:l3t.l3c.nPixelTypes:end, :));

%% Render and test
l3r = l3Render();
l3_xyz = l3r.render(raw{end}, cfa, l3t);
l3_xyz(l3_xyz < 0) = 0;
% vcNewGraphWin; imshow(xyz2srgb(l3_xyz / max(max(l3_xyz(:,:,2)))));
% vcNewGraphWin; imshow(xyz2srgb(ideal_xyz/max(max(ideal_xyz(:, :, 2)))));

ideal_xyz = xyz{end}(padSz(1)+1:end-padSz(1), padSz(2)+1:end-padSz(2), :);
de = deltaEab(l3_xyz, ideal_xyz, max(max(ideal_xyz)));
fprintf('Median DeltaE for RGB-IR: %.2f\n', median(de(:)));

%% Spatial resolution (MTF50)
% fill empty kernels
l3t.fillEmptyKernels;
l3t.symmetricKernels;
l3t.smoothKernels;

% create scene of slanted bar
scene = sceneCreate('slanted bar', [], [], [], wave);
scene = sceneSet(scene, 'h fov', 4);

% adjust illuminat
il = mean(RGB2XWFormat(sceneGet(scenes{1}, 'energy')));
scene = sceneAdjustIlluminant(scene, il, true);

ip = cameraGet(camera, 'ip');
camera = cameraSet(camera, 'sensor auto exposure', true);
camera = cameraSet(camera, 'sensor noise flag', 0);
camera = cameraCompute(camera, scene);

% render
l3r = l3Render();
l3_XYZ = l3r.render(cameraGet(camera, 'sensor volts'), cfa, l3t);

% compute MTF50 for L3 rendered image
[~, lrgb] = xyz2srgb(l3_XYZ);
lrgb(lrgb < 0) = 0;
ip = ipSet(ip, 'result', lrgb);
mtfData = ieISO12233(ip, cameraGet(camera, 'sensor'));
fprintf('MTF50 (RGBW): %.2f\n', mtfData.mtf50);

%% Compare with RGB-empty and Bayer camera
% change IR sensitivity to zero to black it out
fK = fspec; fK(:, 4) = 0;
cameraK = cameraSet(camera, 'sensor filter spectra', fK);

% create l3 data structure
l3d = l3DataSimulation('camera', cameraK, 'expFrac', expFrac, 'sources', scenes);
[raw, xyz] = l3d.dataGet(nTrain+1); % the extra 1 is for testing

% training
l3t = l3TrainRidge();
l3t.l3c.patchSize = patchSz;
l3t.l3c.cutPoints = {logspace(-3, -1, 40), []};
l3t.train(l3DataCamera(raw(trainIndx), xyz(trainIndx), cfa));

% rendering
l3r = l3Render();
l3_xyz = l3r.render(raw{end}, cfa, l3t);
% vcNewGraphWin; imshow(xyz2srgb(l3_xyz / max(max(l3_xyz(:,:,2)))));

ideal_xyz = xyz{end}(padSz(1)+1:end-padSz(1), padSz(2)+1:end-padSz(2), :);
de = deltaEab(l3_xyz, ideal_xyz, max(max(ideal_xyz)));
fprintf('Median DeltaE for RGB-Empty: %.2f\n', median(de(:)));

% change CFA to Bayer pattern
cfaBayer = [2 1; 3 2];
cameraB = cameraSet(camera, 'sensor cfa pattern', cfaBayer);

% create l3 data structure
l3d = l3DataSimulation('camera', cameraB, 'expFrac', expFrac, 'sources', scenes);
[raw, xyz] = l3d.dataGet(nTrain+1); % the extra 1 is for testing

% training
l3t = l3TrainRidge();
l3t.l3c.patchSize = patchSz;
l3t.l3c.cutPoints = {logspace(-3, -1, 40), []};
l3t.train(l3DataCamera(raw(trainIndx), xyz(trainIndx), cfa));

% rendering
l3r = l3Render();
l3_xyz = l3r.render(raw{end}, cfa, l3t);
% vcNewGraphWin; imshow(xyz2srgb(l3_xyz / max(max(l3_xyz(:,:,2)))));

ideal_xyz = xyz{end}(padSz(1)+1:end-padSz(1), padSz(2)+1:end-padSz(2), :);
de = deltaEab(l3_xyz, ideal_xyz, max(max(ideal_xyz)));
fprintf('Median DeltaE for Bayer: %.2f\n', median(de(:)));

%% MTF50 for Bayer
% fill empty kernels
l3t.fillEmptyKernels;
l3t.symmetricKernels;
l3t.smoothKernels;

% create scene of slanted bar
scene = sceneCreate('slanted bar', [], [], [], wave);
scene = sceneSet(scene, 'h fov', 4);

% adjust illuminat
il = mean(RGB2XWFormat(sceneGet(scenes{1}, 'energy')));
scene = sceneAdjustIlluminant(scene, il, true);

ip = cameraGet(cameraB, 'ip');
cameraB = cameraSet(cameraB, 'sensor auto exposure', true);
cameraB = cameraSet(cameraB, 'sensor noise flag', 0);
cameraB = cameraCompute(cameraB, scene);

% render
l3r = l3Render();
l3_XYZ = l3r.render(cameraGet(cameraB, 'sensor volts'), cfa, l3t);

% compute MTF50 for L3 rendered image
[~, lrgb] = xyz2srgb(l3_XYZ);
lrgb(lrgb < 0) = 0;
ip = ipSet(ip, 'result', lrgb);
mtfData = ieISO12233(ip, cameraGet(cameraB, 'sensor'));
fprintf('MTF50 (Bayer): %.2f\n', mtfData.mtf50);