% s_L3_DCardinal
%
%    Learning transformation kernel for images from David Cardinal
%
%  HJ, VISTA TEAM, 2015

% Init parameters
ieInit;
cfa = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
patch_sz = [5 5];
pad_sz   = (patch_sz - 1) / 2;
% offset = [-3, -29];
offset = [2, 1];

% %
% if sz(1) > sz(2) % vertical
%     offset = [24 1];
% else % horizontal
%     offset = [1 -23];
% end

% Load image list
base = 'http://scarlet.stanford.edu/validation/SCIEN/L3/DCardinal/';
outDir = '~/SimResults/L3/DCardinal/TrainOneTestSelf/';

s = lsScarlet([base 'PGM/D600'], '.pgm');

% Init sCIELab parameters
d = displayCreate('LCD-Apple');
d = displaySet(d, 'gamma', 'linear');  % use a linear gamma table
d = displaySet(d, 'viewing distance', 1);
rgb2xyz = displayGet(d, 'rgb2xyz');
wp = displayGet(d, 'white xyz'); % white point
params = scParams;
params.sampPerDeg = displayGet(d, 'dots per deg');
de_quantile = zeros(length(s), 9);


for ii = 1 : length(s)
    I_raw = im2double(imread([base 'PGM/D600/' s(ii).name]));
    
    tif_name = lower(s(ii).name);
    tif_name = [tif_name(1:end-4) '_dxo_nodist.tif'];
    tif = im2double(imread([base 'TIFF/D600/' tif_name]));
    
    % Make tif size a multiple of cfa size
    if isodd(size(tif, 1)), tif = tif(1:end-1, :, :); end
    if isodd(size(tif, 2)), tif = tif(:, 1:end-1, :); end
    
    % Adjust raw size. The offset of the image is still to be determined
    I_raw = rawAdjustSize(I_raw, [size(tif, 1) size(tif, 2)], pad_sz, offset);
    
    % Training
    % build l3Data class
    % raw and jpg are cell arrays of 4 images by default
    % [raw, tif] = cutImages(I_raw, tif, [size(tif, 1) size(tif, 2)]/2);
    l3d = l3DataCamera({I_raw}, {tifSharp}, cfa);
    
    %  Init training class
    l3t = l3TrainOLS();
    l3t.l3c.cutPoints = {quantile(I_raw(:), 0.05:0.05:0.95), 1/128};
    
    % Set training parameters
    l3t.l3c.patchSize = patch_sz;
    
    % learn linear filters
    l3t.train(l3d);
    
    % Rendering
    l3r = l3Render();
    l3_RGB = ieClip(l3r.render(I_raw, cfa, l3t), 0, 1);
    % imwrite(l3_RGB, [outDir s(ii).name(1:end-4) '.JPG']);
    
    % Compute sCIELab
    xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
    xyz2 = imageLinearTransform(tif, rgb2xyz);
    de = scielab(xyz1, xyz2, wp, params);
    de_quantile(ii, :) = quantile(de(:), 0.1:0.1:0.9);
end

%%
fileName = 'edl_lakeinle_0850_dxo_nodist';
jpg = im2double(imread([base 'processed/' fileName '.jpg']));
raw = im2double(imread([base 'processed/' fileName '.pgm']));

% training
l3t = l3TrainOLS();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {logspace(-3.8, -1.5, 60), []};
l3t.train(l3DataCamera({raw}, {jpg}, cfa));

% train on sharpened version
jpgSharp = imsharpen(jpg);
l3t = l3TrainOLS();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {quantile(raw(:), linspace(0.01, 0.99, 40)), []};
l3t.train(l3DataCamera({raw}, {jpgSharp}, cfa));

% render
l3_RGB = ieClip(l3r.render(raw, cfa, l3t), 0, 1);
imshow(l3_RGB);

% testing
fileName = 'ma_mountaingorillas_0510_dxo_nodist';
jpgTest = im2double(imread([base 'processed/' fileName '.jpg']));
rawTest = im2double(imread([base 'processed/' fileName '.pgm']));


l3_RGB = ieClip(l3r.render(rawTest(:, 2:end-1), cfa, l3t), 0, 1);
imshow(l3_RGB);