%% s_KernelSymmetric
%
%  Make the kernels up/down and left/right symmetric, when possible
%
% HJ, VISTA TEAM, 2015

%% Init
% init ISET session
ieInit;

% init parameters
cfa = [2 1; 3 4]; % Bayer pattern
patch_sz = [5 5];
pad_sz   = (patch_sz - 1) / 2;
   
% Init remote data toolbox
rdt = RdtClient('scien');
rdt.crp('/L3/Farrell/D200/garden');
s = rdt.searchArtifacts('dsc_', 'type', 'pgm');

%% Train
%  load training images
trainFile = 2;
img_name = s(trainFile).artifactId;
raw = im2double(rdt.readArtifact(img_name, 'type', 'pgm'));
rgb = im2double(rdt.readArtifact(img_name, 'type', 'jpg'));

% Init training class
l3t = l3TrainOLS();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {logspace(-3.4, -1.8, 10), []};

% learn linear filters
l3t.train(l3DataCamera({raw}, {rgb}, cfa));

%% Render on test image
% load test raw image
testFile = 4;
raw = im2double(rdt.readArtifact(s(testFile).artifactId, 'type', 'pgm'));

% render
l3r = l3Render();
l3_RGB = ieClip(l3r.render(raw, cfa, l3t), 0, 1);

% show image
vcNewGraphWin; imshow(l3_RGB); title('L3 Rendered Image');

%% Interpolate kernels and render again
cfaSymmetry = [2 1; 3 2];
l3t.symmetricKernels(cfaSymmetry);
l3_Symmetry = ieClip(l3r.render(raw, cfa, l3t), 0, 1);

% show image
vcNewGraphWin;
imshow(l3_Symmetry); title('L3 Rendered 2 (symmetric)');

% Show the difference in the two images
vcNewGraphWin; imagescRGB(abs(l3_RGB - l3_Symmetry));
