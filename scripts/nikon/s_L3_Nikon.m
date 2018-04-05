%% s_L3_Nikon
%
%   This script train and test on the nikon dataset captured by Joyce
%   Farrell with L3 method
%
% HJ, VISTA TEAM, 2016

%% Init
% init ISET session
ieInit;

% init parameters
cfa = [2 1; 3 2];
p_max = 1000; % max number of patches per class per image
patch_sz = [5 5];
pad_sz = (patch_sz - 1) / 2;
illuminant_correct = true;

% there are two groups of images (cfa alignment is different) on the
% server. we pick out one group from them
indx = [2 4 5 7:10 12:14 21:29 33:35];

% init remote data toolbox client
rd = RdtClient('scien');
rd.crp('/L3/Farrell/D200/garden');
s = rd.searchArtifacts('dsc_', 'type', 'pgm');
s = s(indx);

% init parameters for SCIELAB
d = displayCreate('LCD-Apple');
d = displaySet(d, 'gamma', 'linear');  % use a linear gamma table
d = displaySet(d, 'viewing distance', 1);

rgb2xyz = displayGet(d, 'rgb2xyz');
wp = displayGet(d, 'white xyz'); % white point
params = scParams;
params.sampPerDeg = displayGet(d, 'dots per deg');

%% Training
%  We use all the odd-numbered images for training
l3t = l3TrainRidge();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.p_max = p_max;
l3t.l3c.statFunc = {@imagePatchMean};
l3t.l3c.statFuncParam = {{}};
l3t.l3c.statNames = {'mean'};
l3t.l3c.cutPoints = {logspace(-3.5, -1.6, 40)};

for ii = 1 : 2 : length(s)
    % load data
    img_name = s(ii).artifactId;
    raw = im2double(rd.readArtifact(img_name, 'type', 'pgm'));
    rgb = im2double(rd.readArtifact(img_name, 'type', 'jpg'));
    
    % classify
    l3t.l3c.classify(l3DataCamera({raw}, {rgb}, cfa));
end

% learn transforms
l3t.train();

%% Rendering
%  We render all the images and record the PSNR and SCIELAB
l3r = l3Render();
psnr_val = zeros(length(s), 1);
de = zeros(length(s), 1);

for ii = 1 : length(s)
    % load data
    img_name = s(ii).artifactId;
    raw = im2double(rd.readArtifact(img_name, 'type', 'pgm'));
    rgb = im2double(rd.readArtifact(img_name, 'type', 'jpg'));
    rgb = rgb(pad_sz(1)+1:end-pad_sz(1), pad_sz(2)+1:end-pad_sz(2), :);
    
    % render the image with L3
    l3_RGB = ieClip(l3r.render(raw, cfa, l3t), 0, 1);
    
    % illuminant correction
    % if illuminant_correct
    %     [l3_XW, r, c, ~] = RGB2XWFormat(l3_RGB);
    %     l3_XW = l3_XW * (pinv(l3_XW) * RGB2XWFormat(rgb));
    %     l3_RGB = ieClip(XW2RGBFormat(l3_XW, r, c), 0, 1);
    % end
    
    % compute PSNR
    psnr_val(ii) = psnr(l3_RGB, rgb);
    
    % compute S-CIELAB DeltaE
    xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
    xyz2 = imageLinearTransform(rgb, rgb2xyz);
    de_img = scielab(xyz1, xyz2, wp, params);
    de(ii) = mean(de_img(:));
end

% print info
fprintf('Mean PSNR: %.2f\n', mean(psnr_val));
fprintf('Mean S-CIELAB DeltaE: %.2f\n', mean(de));

%% Show example images
%  load test image
img_name = 'dsc_0768';
raw = im2double(rd.readArtifact(img_name, 'type', 'pgm'));
rgb = im2double(rd.readArtifact(img_name, 'type', 'jpg'));
rgb = rgb(pad_sz(1)+1:end-pad_sz(1), pad_sz(2)+1:end-pad_sz(2), :);

%  render
l3_RGB = ieClip(l3r.render(raw, cfa, l3t), 0, 1);

% compute S-CIELAB DeltaE
xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
xyz2 = imageLinearTransform(rgb, rgb2xyz);
de_img = scielab(xyz1, xyz2, wp, params);

% plot
vcNewGraphWin;
subplot(2, 2, 1); imshow(rgb); title('Nikon D200');
subplot(2, 2, 3); imshow(l3_RGB); title('L3');
subplot(2, 2, 2); hist(de_img(:), 100); grid on;
subplot(2, 2, 4); imagesc(de_img); colorbar;

%% Plot the learned transforms
%  plot learned transforms for low, median and high response levels
l3t.symmetricKernels;
l3t.plot('kernel image', 1, [], true);
l3t.plot('kernel image', 21, [], true);
l3t.plot('kernel image', 73, [], true);

sensor = sensorCreate;
sensor = sensorSet(sensor, 'cfa pattern', cfa);
l3t.plot('cfa pattern', 1, sensor);