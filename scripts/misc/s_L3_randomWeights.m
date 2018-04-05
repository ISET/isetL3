%% s_L3_randomWeights
%    Explore the performance of L3 using random kernel in classificaiton
%
%  HJ, VISTA TEAM, 2016

%% Init
ieInit;
patchSz = [5 5];
pad_sz = (patchSz-1)/2;
cfa = [2 1; 3 2];
nTrials = 10;

% S-CIELAB parameters
d = displayCreate('LCD-Apple');
d = displaySet(d, 'gamma', 'linear');  % use a linear gamma table
d = displaySet(d, 'viewing distance', 1);

rgb2xyz = displayGet(d, 'rgb2xyz');
wp = displayGet(d, 'white xyz'); % white point
params = scParams;
params.sampPerDeg = displayGet(d, 'dots per deg');

%% Load training and testing images
%  init remote data toolbox client
rd = RdtClient('scien');
rd.crp('/L3/Farrell/D200/garden');
s = rd.searchArtifacts('dsc_', 'type', 'pgm');

% Load data
trainFile = 'dsc_0785';   % Flower image
raw = im2double(rd.readArtifact(trainFile, 'type', 'pgm'));
rgb = im2double(rd.readArtifact(trainFile, 'type', 'jpg'));

% load another image for testing
testFile = 'dsc_0784';
raw_test = im2double(rd.readArtifact(testFile, 'type', 'pgm'));
rgb_test = im2double(rd.readArtifact(testFile, 'type', 'jpg'));
rgb_test = rgb_test(pad_sz(1)+1:end-pad_sz(1),pad_sz(2)+1:end-pad_sz(2),:);

%% Compute rendering performance
de = zeros(nTrials, 1);
for ii = 1 : nTrials
    % create training class instance
    l3t = l3TrainRidge();
    
    % set training parameters
    s = imagePatchRandom(raw, cfa, patchSz);
    l3t.l3c.statFunc = {@imagePatchRandom};
    l3t.l3c.statFuncParam = {{}};
    l3t.l3c.statNames = {'random'};
    l3t.l3c.cutPoints = {quantile(s(:), linspace(0.01, 0.99, 60))};
    l3t.l3c.patchSize = patchSz;
    
    % learn linear transforms
    l3t.train(l3DataCamera({raw}, {rgb}, cfa));
    
    % Rendering
    % create a l3 render class
    l3r = l3Render();
    
    % Render the image
    l3_RGB = ieClip(l3r.render(raw_test, cfa, l3t, false), 0, 1);
       
    %  Compute SCIELAB
    xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
    xyz_ref = imageLinearTransform(rgb_test, rgb2xyz);
    
    
    de_img = scielab(xyz1, xyz_ref, wp, params);
    de(ii) = mean(de_img(:));
    
    fprintf('SCIELAB in trial %d: %.2f\n', ii, de(ii));
end