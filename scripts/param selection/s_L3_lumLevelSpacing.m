%% s_L3LinearVSLogLumLevels
%
% Compare the performance of linear and logarithmic luminance levels
%
% (HJ) VISTA TEAM, 2016

%% Init
ieInit;
cfa = [2 1; 3 4];
patch_sz = [5 5];
pad_sz = (patch_sz - 1) / 2;

%% Load Data from remote server
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

%% Measure performanace for different luminance levels
levels = [1 4 5 7 9 12 16 20 27 35 46 61 80];
de_log = zeros(length(levels), 1);
de_linear = zeros(length(levels), 1);
psnr_log = zeros(length(levels), 1);
psnr_linear = zeros(length(levels), 1);

for ii = 1 : length(levels)
    % create training class instance
    l3t_log = l3TrainRidge();
    l3t_log.l3c.cutPoints = {logspace(-3.2, -1.8, levels(ii)), []};
    l3t_log.l3c.dataKernel = @(x) [x; x.^2];
    l3t_log.l3c.patchSize = patch_sz;
    
    l3t_linear = l3t_log.copy();
    l3t_linear.l3c.cutPoints = {linspace(10^-3.2, 10^-1.8, levels(ii)), []};
    
    % Invoke the training algorithm
    l3t_log.train(l3DataCamera({raw}, {rgb}, cfa));
    l3t_linear.train(l3DataCamera({raw}, {rgb}, cfa));
    
    % Rendering
    % create a l3 render class
    l3r = l3Render();
    
    % Render the image
    l3_RGB_log = ieClip(l3r.render(raw_test, cfa, l3t_log, false), 0, 1);
    l3_RGB_linear = ieClip(l3r.render(raw_test, cfa, l3t_linear, false), 0, 1);
    
    % Compare images (PSNR and SCIELAB)
    %  Compute PSNR
    psnr_log(ii) = psnr(l3_RGB_log, rgb_test);
    psnr_linear(ii) = psnr(l3_RGB_linear, rgb_test);
    
    fprintf('PSNR for log-spaced lum levels is %.2f db\n', psnr_log(ii));
    fprintf('PSNR for linear-spaced lum levels is %.2f db\n', psnr_linear(ii));
    
    %  Compute SCIELAB
    %  Suppose we show the two images on a calibrated display
    d = displayCreate('LCD-Apple');
    d = displaySet(d, 'gamma', 'linear');  % use a linear gamma table
    d = displaySet(d, 'viewing distance', 1);
    
    rgb2xyz = displayGet(d, 'rgb2xyz');
    wp = displayGet(d, 'white xyz'); % white point
    xyz1 = imageLinearTransform(l3_RGB_log, rgb2xyz);
    xyz2 = imageLinearTransform(l3_RGB_linear, rgb2xyz);
    xyz_ref = imageLinearTransform(rgb_test, rgb2xyz);
    
    params = scParams;
    params.sampPerDeg = displayGet(d, 'dots per deg');
    de = scielab(xyz1, xyz_ref, wp, params);
    de_log(ii) = mean(de(:));
    
    de = scielab(xyz2, xyz_ref, wp, params);
    de_linear(ii) = mean(de(:));
    
    fprintf('SCIELAB for log-spaced lum is: %.2f\n', de_log(ii));
    fprintf('SCIELAB for linear-spaced lum is: %.2f\n', de_linear(ii));
    
end

% plot the performance
vcNewGraphWin;
plot(levels, de_log(:), '--', 'lineWidth', 2); hold on;
plot(levels, de_linear(:), '-', 'lineWidth', 2);
legend('log spaced', 'linear spaced');
xlabel('Number of reponse levels'); ylabel('S-CIELAB \DeltaE');

%% END