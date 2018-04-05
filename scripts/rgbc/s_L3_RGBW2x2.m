%% s_L3_RGBW2x2
%
%  Simulate and evaluate an RGBW camera with 2x2 color filter array
%
% 
%HJ, VISTA TEAM, 2016

%% Init
ieInit;
cfa = [2 1; 3 4];
patchSz = [5 5];
nTrain = 4; % train on first 4 images
% expFrac = [1 0.5 0.1 0.008 0.006 0.003];
expFrac = [0.1:0.2:0.9 1.2 1.5];

%% Create RGBW camera
% create rgbw camera with 2x2 color filter array
load rgbcCamera.mat  % this is the standard 8x8 rgbc model from omv
camera = cameraSet(camera, 'sensor cfa pattern', cfa);

% scale RGB spectra
fspec = cameraGet(camera, 'sensor filter spectra');
% fspec(:, 1:3) = fspec(:, 1:3)/2;
camera = cameraSet(camera, 'sensor filter spectra', fspec);

%% create l3 data structure
l3d = l3DataSimulation('camera', camera, 'expFrac', expFrac);
l3d.loadSources(nTrain+1, 'oi');
for ii = 1 : nTrain+1
    l3d.sources{ii} = oiSet(l3d.sources{ii}, 'optics f length', 0.004);
    l3d.sources{ii} = oiSet(l3d.sources{ii}, 'optics f number', 4);
end
[raw, xyz] = l3d.dataGet(nTrain+1); % the extra 1 is for testing

% white balance the xyz with gray world assumption. This could make the
% dark image closer to grayscale (instead of brownish). But it would
% decrease l3 performance (grayworld white balance is totally global
% instead of local and very image dependent)
% 
% for ii = 1 : length(xyz)
%     scale = max(max(xyz{ii})); 
%     scale = scale / scale(2) ./ reshape([0.95 1 1.089], [1 1 3]);
%     xyz{ii} = bsxfun(@rdivide, xyz{ii}, scale);
% end

%% Learn local linear kernels
l3t = l3TrainRidge();
l3t.l3c.patchSize = patchSz;

min_cut = log10(10 * cameraGet(camera, 'sensor conversion gain'));
max_cut = log10(0.98 * cameraGet(camera, 'sensor voltage swing'));
l3t.l3c.cutPoints = {logspace(min_cut, max_cut, 40), []}; 

trainIndx = 1:nTrain*length(l3d.expFrac);
l3t.train(l3DataCamera(raw(trainIndx), xyz(trainIndx), cfa));
% l3t.smoothKernels(cfa);

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
vcNewGraphWin; plot(wWeight(cPixelType:l3t.l3c.nPixelTypes:end));

%  plot percentage of saturated pixels
threshold = 0.95 * cameraGet(camera, 'pixel voltage swing');
sat_pixels = zeros(l3t.l3c.nLabels/l3t.l3c.nPixelTypes, 4);
tot_pixels = zeros(l3t.l3c.nLabels/l3t.l3c.nPixelTypes, 4);
indx = 1;
for ii = cPixelType : l3t.l3c.nPixelTypes : l3t.l3c.nLabels
    pattern = l3t.l3c.getClassCFA(ii);
    for cc = 1 : 4 % input channel
        data = l3t.l3c.p_data{ii}(pattern == cc, :);
        sat_pixels(indx, cc) = sum(data(:) > threshold);
        tot_pixels(indx, cc) = numel(data);
    end
    indx = indx + 1;
end
vcNewGraphWin; plot(respLev, sat_pixels ./ tot_pixels);

%% Render and test
l3r = l3Render();
vcNewGraphWin([], 'wide');

% get full exposure time
if strcmp(l3d.sources{end}.type, 'scene')
    oi = oiCompute(l3d.sources{end}, cameraGet(camera, 'oi'));
else
    oi = l3d.sources{end};
end

rgbw_exp = autoExposure(oi, cameraGet(camera, 'sensor'), 0.98, 'specular');
for ii = 1 : length(l3d.expFrac)
    l3_xyz = l3r.render(raw{end+1-ii}, cfa, l3t);
    l3_xyz = l3_xyz / quantile(l3_xyz(:), 0.98);
    l3_xyz(l3_xyz>1) = 1;
    subplot(2, length(expFrac), ii); imshow(xyz2srgb(l3_xyz));
    % vcNewGraphWin; imshow(xyz2srgb(xyz));
    title(sprintf('RGBW - %.2f ms', 1e3*rgbw_exp*l3d.expFrac(end+1-ii)));
end

%% Spatial resolution - slanted bar analysis
% This section is not very stable. By a small chance, it could not detect
% the border and result in an error.
% create scene of slanted bar
scene = sceneCreate('slanted bar');
scene = sceneSet(scene, 'h fov', 4);

ip = cameraGet(camera, 'ip');
camera = cameraSet(camera, 'sensor auto exposure', true);
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

%% Color accuray
% create scene of macbeth color checker
scene = sceneCreate('macbeth d65');
c = cameraSet(camera, 'sensor noise flag', 0);

% compute camera response and ideal output
l3d = l3DataSimulation('camera', c, 'sources', {scene});
l3d.expFrac = 1;

[raw, ideal_XYZ] = l3d.dataGet(1);
raw = raw{1}; ideal_XYZ = ideal_XYZ{1};
padSz = (patchSz-1)/2;
ideal_XYZ = ideal_XYZ(padSz(1)+1:end-padSz(1), padSz(2)+1:end-padSz(2), :);

% render
l3r = l3Render;
l3_XYZ = l3r.render(raw, cfa, l3t);

% scale XYZ to right luminance
scale = sceneGet(scene, 'mean lum') / mean(mean(ideal_XYZ(:, :, 2)));
l3_XYZ = l3_XYZ * scale; l3_XYZ(l3_XYZ < 0) = 0;
ideal_XYZ = ideal_XYZ * scale;

% suppose the white point is a D65 white, slightly brighter than the white
% patch in the image
wp = [0.95 1 1.089] * max(max(ideal_XYZ(:, :, 2))) * 1.1;

% compute de
de = deltaEab(l3_XYZ, ideal_XYZ, wp);

% vcNewGraphWin; imagesc(de); colorbar;
fprintf('RGBW Color accuray (median deltaE): %.2f\n', median(de(:)));

% According to the deltaE values, we can see that the color accuracy is
% fairly poor (greater than 5). This is mainly due to the training data
% selection. If we use the oi data (generated by TL), the color accuracy is
% much better (less than 2). As a comparison, if we directly train towards
% the macbeth color checker and test with it, we get a mean deltaE less
% than 1 (between .25 to .75, the variation is because we only use one
% training image with very few useful patches)
%
% In the following sections, we will see how these compares with Bayer
% pattern cameras.
%

%% Compare with bayer pattern camera
%  change cfa pattern to bayer
cfa = [2 1; 3 2];
camera = cameraSet(camera, 'sensor cfa pattern', cfa);
bayer_exp = autoExposure(oi,cameraGet(camera,'sensor'),0.99,'specular');
bayer_expFrac = expFrac * rgbw_exp / bayer_exp;

%  compute raw and xyz
l3d = l3DataSimulation('camera', camera, 'expFrac', bayer_expFrac);
l3d.loadSources(nTrain+1, 'oi');
for ii = 1 : nTrain+1
    l3d.sources{ii} = oiSet(l3d.sources{ii}, 'optics f length', 0.004);
    l3d.sources{ii} = oiSet(l3d.sources{ii}, 'optics f number', 4);
end
[raw, xyz] = l3d.dataGet(nTrain+1);

% white balance the xyz with gray world assumption
% for ii = 1 : length(xyz)
%     scale = max(max(xyz{ii})); 
%     scale = scale / scale(2) ./ reshape([0.95 1 1.089], [1 1 3]);
%     xyz{ii} = bsxfun(@rdivide, xyz{ii}, scale);
% end

% training
l3t = l3TrainRidge(); l3t.l3c.patchSize = patchSz;
l3t.l3c.cutPoints = {logspace(min_cut, max_cut, 80), []}; 
l3t.train(l3DataCamera(raw(trainIndx), xyz(trainIndx), cfa));

% render
l3r = l3Render();

for ii = 1 : length(l3d.expFrac)
    xyz = l3r.render(raw{end+1-ii}, cfa, l3t);
    xyz = xyz / max(max(xyz(:,:,2)));
    subplot(2, length(expFrac), length(expFrac)+ii); imshow(xyz2srgb(xyz));
    % vcNewGraphWin; imshow(xyz2srgb(xyz));
    title(sprintf('Bayer - %.2f ms', 1e3*bayer_exp*l3d.expFrac(end+1-ii)));
end


%% Spatial resolution - slanted bar analysis
scene = sceneCreate('slanted bar');
scene = sceneSet(scene, 'h fov', 4);

ip = cameraGet(camera, 'ip');
camera = cameraSet(camera, 'sensor auto exposure', true);
camera = cameraCompute(camera, scene);

% render
l3r = l3Render();
l3_XYZ = l3r.render(cameraGet(camera, 'sensor volts'), cfa, l3t);

% compute MTF50 for L3 rendered image
[~, lrgb] = xyz2srgb(l3_XYZ);
lrgb(lrgb < 0) = 0;
ip = ipSet(ip, 'result', lrgb);
mtfData = ieISO12233(ip, cameraGet(camera, 'sensor'));
fprintf('MTF50 (Bayer): %.2f\n', mtfData.mtf50);

oi = cameraGet(camera, 'oi');
otf = oiGet(oi, 'optics otf', oi, [], 550);
fSupport = oiGet(oi, 'fSupport', 'mm');
freq = fftshift(fSupport(:, :, 1));
[~, indx] = min(abs(otf(1, 1:end/3)-0.5));
optics_mtf50 = freq(1, indx);
fprintf('Optics limited MTF50: %.2f\n', optics_mtf50);

%% Color accuracy
% create scene of macbeth color checker
scene = sceneCreate('macbeth d65');
c = cameraSet(camera, 'sensor noise flag', 0);

% compute camera response and ideal output
l3d = l3DataSimulation('camera', c, 'sources', {scene});
l3d.expFrac = 1;

[raw, ideal_XYZ] = l3d.dataGet(1);
raw = raw{1}; ideal_XYZ = ideal_XYZ{1};
padSz = (patchSz-1)/2;
ideal_XYZ = ideal_XYZ(padSz(1)+1:end-padSz(1), padSz(2)+1:end-padSz(2), :);

% render
l3r = l3Render;
l3_XYZ = l3r.render(raw, cfa, l3t);

% scale XYZ to right luminance
scale = sceneGet(scene, 'mean lum') / mean(mean(ideal_XYZ(:, :, 2)));
l3_XYZ = l3_XYZ * scale; l3_XYZ(l3_XYZ < 0) = 0;
ideal_XYZ = ideal_XYZ * scale;

% suppose the white point is a D65 white, slightly brighter than the white
% patch in the image
wp = [0.95 1 1.089] * max(max(ideal_XYZ(:, :, 2))) * 1.1;

% compute de
de = deltaEab(l3_XYZ, ideal_XYZ, wp);

% vcNewGraphWin; imagesc(de); colorbar;
fprintf('Bayer Color accuray (median deltaE): %.2f\n', median(de(:)));