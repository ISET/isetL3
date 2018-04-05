%% Illustrate the kernels of the number of luminance levels
%
%  In this scirpt, we train on one image captured by Nikon D200 camera and
%  tested on another image under the same camera settings (lens, exposure).
%
%  The pixels are classified only by the luminance and the pixel type. We
%  vary the number of luminance levels used and generate a video to
%  demonstrate its effect on image quality.
%
%  HJ/BW, VISTA TEAM, 2016

%% Init
% Init ISET SESSION
ieInit;

% Init parameters
cfa = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
patch_sz = [5 5];
pad_sz = (patch_sz-1)/2;

% Init remote data toolbox
rd = RdtClient('scien');
rd.crp('/L3/Farrell/D200/garden');

% init parameters for SCIELAB
d = displayCreate('LCD-Apple');
d = displaySet(d, 'gamma', 'linear');  % use a linear gamma table
d = displaySet(d, 'viewing distance', 1);

rgb2xyz = displayGet(d, 'rgb2xyz');
wp = displayGet(d, 'white xyz'); % white point
params = scParams;
params.sampPerDeg = displayGet(d, 'dots per deg');

%% Load training and testing image
% list all image artifacts
s = rd.listArtifacts;

% load training image
trainFile = 'dsc_0785';   % Flower image
train_rgb = im2double(rd.readArtifact(trainFile, 'type', 'jpg'));
train_raw = im2double(rd.readArtifact(trainFile, 'type', 'pgm'));

testFile = 'dsc_0784';
test_raw = im2double(rd.readArtifact(testFile, 'type', 'pgm'));

%% Plot kernels under different luminance levels
%  number of luminance levels
levels = [4 7 10 20];

% Build l3 data and render class
l3d = l3DataCamera({train_raw}, {train_rgb}, cfa);
l3r = l3Render();

% Train using different luminance levels and render the test image
vcNewGraphWin; hold on;
for ii = 1 : length(levels)
    l3t = l3TrainOLS();
    l3t.l3c.patchSize = patch_sz;
    l3t.l3c.cutPoints = {logspace(-3.2, -2, levels(ii)), []};
    
    % learn linear filters
    l3t.train(l3d);
    
    % plot kernels
    % l3t.plot('kernels mesh', 1);
    
    k = cell2mat(l3t.kernels(1:4:end)');
    stairs([0 l3t.l3c.cutPoints{1} 0.0157], [k(14, 2:3:end)./sum(abs(k(:, 2:3:end))) 0]);
end