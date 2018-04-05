%% s_L3_RGBC
%    training rgbc with ISET simulation
%
%  HJ, VISTA TEAM, 2015

% Initialize
ieInit;
patchSize = [9 9];
padSize = (patchSize-1)/2;

% l3 Data object
load rgbcCamera.mat

l3d = l3DataISET;
l3d.camera = camera;

% Set illuminant properties
% illuminant levels are the brightness of the scene (cd/m2). If the camera
% is in auto-exposure mode, the exposure time is determined by the first
% entry in the illuminantLev list
l3d.illuminantLev = [70 10 20 30 40 50 60 90];
l3d.inIlluminantSPD = {'D65'};
l3d.outIlluminantSPD = {'D65'};

% Training
l3t = l3TrainRidge();
l3t.l3c.patchSize = patchSize;
l3t.l3c.cutPoints = {logspace(-2, -.6, 40), 1/32};
l3t.train(l3d);

% Rendering
% first, we render on one of the training images
l3r = l3Render;
cfa = cameraGet(camera, 'sensor cfa pattern');
[raw, tgt, ~] = l3d.dataGet(3);
outImg = l3r.render(raw{1}, cfa, l3t);

outImg = outImg / max(max(outImg(:,:,2)));
vcNewGraphWin; imshow(xyz2srgb(outImg));

% Load test image
raw = rgbcRawRead('8835RGBC-1000lux-D65-color-1x-14ms-30fps.raw');
raw = ieScale(raw, 0, 1/2);

% render
l3_xyz_test = l3r.render(raw, cfa, l3t);
[~, l3_lrgb_test] = xyz2srgb(l3_xyz_test);
l3_lrgb_test = ieClip(l3_lrgb_test / quantile(l3_lrgb_test(:), 0.99),0,1);
vcNewGraphWin; imshow(lrgb2srgb(l3_lrgb_test));

% Let's try training the shifted version
offset = [0 1; 0 -1; 1 0; -1 0];
xyz = l3_xyz_test(2:end-1, 2:end-1, :);
[in, out, ~] = l3d.dataGet(); initOut = out;
for ii = 1 : size(offset, 1)
    out = cellfun(@(x) circshift(x, offset(ii, :)), initOut, ...
        'UniformOutput', false);
    curData = l3DataCamera(in ,out, cfa);
    l3t.train(l3d, true);
    
    curXYZ = l3r.render(raw, cfa, l3t);
    xyz = xyz + curXYZ((2:end-1)+offset(ii,1),(2:end-1)+offset(ii,2),:);
end

[~, rgb] = xyz2srgb(xyz);
rgb = ieClip(rgb / quantile(rgb(:), 0.99),0,1);
vcNewGraphWin; imshow(lrgb2srgb(rgb));

% directly using the data for training
rgb = im2double(imread('8835RGBC-1000lux-D65-color-1x-14ms-30fps_OVPGBasic_8830RGBW_LENC_rgbw8x8_lenc_d65.bmp'));
rgb = rgb(padSize(1)+1:end-padSize(1), padSize(2)+1:end-padSize(2), :);
l3d = l3DataCamera({raw}, {rgb}, cfa);

l3t = l3TrainRidge();
l3t.l3c.patchSize = patchSize;
l3t.l3c.cutPoints = {logspace(-2.0, -.1, 30), 1/64};
l3t.train(l3d);

% 
l3_RGB = l3r.render(raw, cfa, l3t);
l3_RGB = ieClip(l3_RGB, 0, 1);

vcNewGraphWin; imshow(l3_RGB);