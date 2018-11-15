%% t_L3Object
%
% Examples on how to use l3 object.
%
% I think the pgm file is the raw sensor and the jpg file is the
% rendered file.  Hence, in this case we are using the L3 object to
% train to match a particular camera rendering algorithm.
%
% (HJ) VISTA TEAM, 2015

%% Init
ieInit;

%% Set up the training parameters a bit
cfa = [2 1; 3 4];
patch_sz = [5 5];
pad_sz = (patch_sz - 1) / 2;

%% Load Data from remote server
%  init remote data toolbox client
rd = RdtClient('scien');
rd.crp('/L3/Farrell/D200/garden');
s = rd.searchArtifacts('dsc_', 'type', 'pgm');

% Load data
trainFile = 23;
raw = im2double(rd.readArtifact(s(trainFile).artifactId, 'type', 'pgm'));
rgb = im2double(rd.readArtifact(s(trainFile).artifactId, 'type', 'jpg'));

%% Training
% create training class instance
l3t = l3TrainRidge();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.satClassOption = 'none';

% Invoke the training algorithm
l3t.train(l3DataCamera({raw}, {rgb}, cfa));

%% Rendering
% load another image for testing
testFile = 28; imgName = s(testFile).artifactId;
raw_test = im2double(rd.readArtifact(imgName, 'type', 'pgm'));
rgb_test = im2double(rd.readArtifact(imgName, 'type', 'jpg'));
rgb_test = rgb_test(pad_sz(1)+1:end-pad_sz(1),pad_sz(2)+1:end-pad_sz(2),:);

% create a l3 render class
l3r = l3Render();

% Render the image
l3_RGB = ieClip(l3r.render(raw_test, cfa, l3t), 0, 1);

% visualize the images
vcNewGraphWin; imshow(l3_RGB); title('L3 Rendered')
vcNewGraphWin; imshow(rgb_test); title('JPG')

%% Compare images (PSNR and SCIELAB)
%  Compute PSNR
psnr_val = psnr(l3_RGB, rgb_test);
fprintf('Peak Signal-Noise ratio is %.2f db\n', psnr_val);

%  Compute SCIELAB
%  Suppose we show the two images on a calibrated display
d = displayCreate('LCD-Apple');
d = displaySet(d, 'gamma', 'linear');  % use a linear gamma table
d = displaySet(d, 'viewing distance', 1);

rgb2xyz = displayGet(d, 'rgb2xyz');
wp = displayGet(d, 'white xyz'); % white point
xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
xyz2 = imageLinearTransform(rgb_test, rgb2xyz);

params = scParams;
params.sampPerDeg = displayGet(d, 'dots per deg');
de = scielab(xyz1, xyz2, wp, params);
vcNewGraphWin; imagesc(de);
vcNewGraphWin; hist(de(:), 100);

fprintf('Mean SCIELAB DeltaE is: %.2f\n', mean(de(:)));

%% END