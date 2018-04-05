%% s_L3_FitQuality
%
%  This script computes the S-CIELAB for training data in each class and
%  plots the relationship between fitting accuracy with response levels
%
%  HJ, VISTA TEAM, 2016

%% Init
% init ISET session
ieInit;

% init parameters
cfa = [2 1; 3 4];
p_max = 1000; % max number of patches per class per image
patch_sz = [5 5];
pad_sz = (patch_sz - 1) / 2;
illuminant_correct = true;

% init remote data toolbox client
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

% Load training data
trainFile = 'dsc_0785';   % Flower image
train_rgb = im2double(rd.readArtifact(trainFile, 'type', 'jpg'));
train_raw = im2double(rd.readArtifact(trainFile, 'type', 'pgm'));

testFile = 'dsc_0784';
test_raw = im2double(rd.readArtifact(testFile, 'type', 'pgm'));
test_rgb = im2double(rd.readArtifact(testFile, 'type', 'jpg'));
test_rgb = test_rgb(pad_sz(1)+1:end-pad_sz(1),pad_sz(2)+1:end-pad_sz(2),:);

%% Training and testing
l3t = l3TrainOLS();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {logspace(-3.2, -1.8, 60), []};
l3t.train(l3DataCamera({train_raw}, {train_rgb}, cfa));

l3r = l3Render();
l3_rgb = ieClip(l3r.render(test_raw, cfa, l3t), 0, 1);

l3_xyz = imageLinearTransform(l3_rgb, rgb2xyz); 
ref_xyz = imageLinearTransform(test_rgb, rgb2xyz);

params = scParams;
params.sampPerDeg = displayGet(d, 'dots per deg');
de = scielab(l3_xyz, ref_xyz, wp, params);

%% Plot
labels = l3t.l3c.classify(l3DataCamera({test_raw}, {test_rgb}, cfa), true);
labels = labels{1}(1:end-1, 1:end-1);
classDE = zeros(l3t.l3c.nLabels, 1);
for ii = 1 : l3t.l3c.nLabels
    classDE(ii) = mean(de(labels == ii));
end

classDE = reshape(classDE, l3t.l3c.nPixelTypes, []);
vcNewGraphWin;
classC = l3t.l3c.classCenters{1}; classC(end) = 0.0186;
plot(classC, classDE);
set(gca, 'xscale', 'log'); xlim([10^-3.2, 10^-1.7]);
xlabel('Response level'); ylabel('Mean S-CIELab'); grid on;

% histogram
vcNewGraphWin; 
[count, centers] = hist(classDE(:), 15);
plot(centers, smooth(count));