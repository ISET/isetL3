%% s_L3Object_Lab
%
%    Testing performance if we train and render to Lab color space
%    The intuition behind using Lab color space is that second norm in Lab
%    color space roughly represents the visual color difference (delatE).
%    Thus, training and rendering in Lab space could reduce the visible
%    difference between original and L3 reverse engineered pipeline
%
% HJ, VISTA TEAM, 2015

%% Init
% Init ISET session
ieInit;

% Init parameters
cfa = [2 1; 3 4]; % Bayer pattern
patch_sz = [5 5];
pad_sz = (patch_sz - 1) / 2;
   
% Init remote data toolbox
rdt = RdtClient('scien');
rdt.crp('/L3/Farrell/D200/garden');
s = rdt.searchArtifacts('dsc_', 'type', 'pgm');

%% Load train and test images
trainFile = 2; testFile = 4;

% load training image
img_name = s(trainFile).artifactId;
raw_train = im2double(rdt.readArtifact(img_name, 'type', 'pgm'));
rgb_train = im2double(rdt.readArtifact(img_name, 'type', 'jpg'));

% load test image
img_name = s(testFile).artifactId;
raw_test = im2double(rdt.readArtifact(img_name, 'type', 'pgm'));
rgb_test = im2double(rdt.readArtifact(img_name, 'type', 'jpg'));
rgb_test = rgb_test(pad_sz(1)+1:end-pad_sz(1),pad_sz(2)+1:end-pad_sz(2),:);

%% Train and test in RGB space
% Init training class
l3t = l3TrainOLS();
l3t.l3c.patchSize = patch_sz;

% learn linear filters
l3t.train(l3DataCamera({raw_train}, {rgb_train}, cfa));

% render
l3r = l3Render();
l3_RGB = ieClip(l3r.render(raw_test, cfa, l3t), 0, 1);

%% Train and test in LAB space
% Convert rgb to lab space (assume rgb is srgb)
wp = [0.95 1 1.089];  % white point
lab = ieXYZ2LAB(srgb2xyz(rgb_train), wp);

% learn linear filters
l3t.l3c.clearData();
l3t.train(l3DataCamera({raw_train}, {lab}, cfa));

% render
l3_Lab = l3r.render(raw_test, cfa, l3t);
l3_Lab_RGB = xyz2srgb(ieClip(ieLAB2XYZ(l3_Lab, wp), 0, 1));

%% Compare the quality
% Init SCIELAB parameters
d = displayCreate('LCD-Apple');
d = displaySet(d, 'gamma', 'linear');  % use a linear gamma table
d = displaySet(d, 'viewing distance', 1);
rgb2xyz = displayGet(d, 'rgb2xyz');
wpD = displayGet(d, 'white xyz'); % white point
params = scParams;
params.sampPerDeg = displayGet(d, 'dots per deg');

% Compute sCIE DeltaE value for training in RGB case
xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
xyz2 = imageLinearTransform(rgb_test, rgb2xyz);
de_RGB = scielab(xyz1, xyz2, wpD, params);

% Copmute sCIE DeltaE value for training in Lab case
xyz1 = imageLinearTransform(l3_Lab_RGB, rgb2xyz);
de_Lab = scielab(xyz1, xyz2, wpD, params);

% Print information
fprintf('Mean DeltaE (training in RGB): %.4f\n', mean(de_RGB(:)));
fprintf('Mean DeltaE (training in LAB): %.4f\n', mean(de_Lab(:)));
