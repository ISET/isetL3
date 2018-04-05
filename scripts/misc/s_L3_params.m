%% s_L3Object_NikonParams
%
% Reverse engineer Nikon Camera
%
% (HJ) VISTA TEAM, 2015

%% Init
ieInit;

% Init parameters
% Init training parameters
cfa = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
patch_sz = [5 5];
pad_sz   = (patch_sz - 1) / 2;
offset = [1, 2];

% Init training data parameters
base = 'http://scarlet.stanford.edu/validation/SCIEN/L3/nikond200/';
nLumLevels = 10:5:60;
contLevels = [1/16 1/32 1/64 1/128 1/256];
s = lsScarlet([base 'JPG'], '.JPG');

% Init SCIELAB parameters
d = displayCreate('LCD-Apple');
d = displaySet(d, 'gamma', 'linear');  % use a linear gamma table
d = displaySet(d, 'viewing distance', 1);
rgb2xyz = displayGet(d, 'rgb2xyz');
wp = displayGet(d, 'white xyz'); % white point
params = scParams;
params.sampPerDeg = displayGet(d, 'dots per deg');
de_quantile_lum = zeros(length(nLumLevels), floor(length(s)/2), 9);
de_quantile_cont = zeros(length(contLevels), floor(length(s)/2), 9);

%% Test effects of luminance levels
for n = nLumLevels
    outDir = sprintf('~/SimResults/L3/Nikon/TrainOddTestEven/lum_fast_%d/', n);
    if ~exist(outDir, 'dir'), mkdir(outDir); end

    % Training
    % Set training parameters
    l3t = l3TrainOLS();
    l3t.l3c = l3ClassifyFast();
    l3t.l3c.patchSize = patch_sz;
    l3t.l3c.cutPoints = {logspace(-4, -1.2, n), 1/16};
    
    for jj = 1 : 2 : length(s)
        % print info
        cprintf('*Keywords', 'Training on Image: %s\n', s(jj).name);
        
        % load raw and jpg image
        img_name = s(jj).name(1:end-4);
        [I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
        
        % build l3Data class
        l3d = l3DataCamera({I_raw}, {jpg}, cfa);
        
        % adding classify data
        l3t.l3c.classify(l3d);
    end
    
    % learn linear filters
    l3t.train();
    
    % save trained kernels
    l3t.l3c.clearData();
    save([outDir 'l3t.mat'], 'l3t', 'cfa');
    
    % Rendering
    l3r = l3Render();
    
    for jj = 2 : 2 : length(s)
        % print info
        cprintf('*Keywords', 'Rendering on Image: %s\n', s(jj).name);
        
        % load raw and jpg image
        img_name = s(jj).name(1:end-4);
        [I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
        
        l3_RGB = l3r.render(I_raw, cfa, l3t);
        l3_RGB = ieClip(l3_RGB, 0, 1);
        
        % save l3 rendered RGB image
        imwrite(l3_RGB, [outDir img_name '.JPG']);
        
        % SCIELAB
        xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
        xyz2 = imageLinearTransform(jpg, rgb2xyz);
        de = scielab(xyz1, xyz2, wp, params);
        de_quantile_lum(n, jj/2, :) = quantile(de(:), 0.1:0.1:0.9);
    end
end

% plot the deltaE value
vcNewGraphWin; plot(nLumLevels, mean(de_quantile_lum(nLumLevels,:,5), 2));
grid on; hold on; xlabel('Number of luminance leveles');
ylabel('sCIE DeltaE');

%% Test effects of contrast levels
for n = 1 : length(contLevels)
    outDir = sprintf('~/SimResults/L3/Nikon/TrainOddTestEven/cont_%d/', n);
    if ~exist(outDir, 'dir'), mkdir(outDir); end

    % Training
    % Set training parameters
    l3t = l3TrainOLS();
    l3t.l3c = l3ClassifyFast();
    l3t.l3c.patchSize = patch_sz;
    l3t.l3c.cutPoints = {logspace(-4, -1.2, 20), contLevels(1:n)};
    
    for jj = 1 : 2 : length(s)
        % print info
        cprintf('*Keywords', 'Training on Image: %s\n', s(jj).name);
        
        % load raw and jpg image
        img_name = s(jj).name(1:end-4);
        [I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
        
        % build l3Data class
        [raw, jpg] = cutImages(I_raw, jpg, [size(jpg, 1) size(jpg, 2)]/2);
        l3d = l3DataCamera(raw, jpg, cfa);
        
        % adding classify data
        l3t.l3c.classify(l3d);
    end
    
    % learn linear filters
    l3t.train();
    
    % save trained kernels
    l3t.l3c.clearData();
    save([outDir 'l3t.mat'], 'l3t', 'cfa');
    
    % Rendering
    l3r = l3Render();
    
    for jj = 2 : 2 : length(s)
        % print info
        cprintf('*Keywords', 'Rendering on Image: %s\n', s(jj).name);
        
        % load raw and jpg image
        img_name = s(jj).name(1:end-4);
        [I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
        
        l3_RGB = l3r.render(I_raw, cfa, l3t);
        l3_RGB = ieClip(l3_RGB, 0, 1);
        
        % save l3 rendered RGB image
        imwrite(l3_RGB, [outDir img_name '.JPG']);
        
        % SCIELAB
        xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
        xyz2 = imageLinearTransform(jpg, rgb2xyz);
        de = scielab(xyz1, xyz2, wp, params);
        de_quantile_cont(n, jj/2, :) = quantile(de(:), 0.1:0.1:0.9);
    end
end

% plot
vcNewGraphWin; plot(contLevels, mean(de_quantile_cont(:,:,5), 2));
grid on; hold on; xlabel('Number of Contrast Levels');
ylabel('sCIE DeltaE');

%% Adding a little non-linearty
outDir = '~/SimResults/L3/Nikon/TrainOddTestEven/nonLinear/';
if ~exist(outDir, 'dir'), mkdir(outDir); end
de_quantile_nl = zeros(floor(length(s)/2), 9);

% Training
% Set training parameters
l3t = l3TrainOLS();
l3t.l3c = l3ClassifyFast();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {logspace(-4, -1.2, 20), 1/16};
l3t.l3c.dataKernel = @(x) [x; x.^2];


for jj = 1 : 2 : length(s)
    % print info
    cprintf('*Keywords', 'Training on Image: %s\n', s(jj).name);
    
    % load raw and jpg image
    img_name = s(jj).name(1:end-4);
    [I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
    
    % build l3Data class
    l3d = l3DataCamera({I_raw}, {jpg}, cfa);
    
    % adding classify data
    l3t.l3c.classify(l3d);
end

% learn linear filters
l3t.train();

% save trained kernels
l3t.l3c.clearData();
save([outDir 'l3t.mat'], 'l3t', 'cfa');

% Rendering
l3r = l3Render();

for jj = 2 : 2 : length(s)
    % print info
    cprintf('*Keywords', 'Rendering on Image: %s\n', s(jj).name);
    
    % load raw and jpg image
    img_name = s(jj).name(1:end-4);
    [I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
    
    l3_RGB = l3r.render(I_raw, cfa, l3t);
    l3_RGB = ieClip(l3_RGB, 0, 1);
    
    % save l3 rendered RGB image
    imwrite(l3_RGB, [outDir img_name '.JPG']);
    
    % SCIELAB
    xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
    xyz2 = imageLinearTransform(jpg, rgb2xyz);
    de = scielab(xyz1, xyz2, wp, params);
    de_quantile_nl(jj/2, :) = quantile(de(:), 0.1:0.1:0.9);
end


%% How about using a larger patch size
outDir = '~/SimResults/L3/Nikon/TrainOddTestEven/patch7/';
if ~exist(outDir, 'dir'), mkdir(outDir); end
de_quantile_p7 = zeros(floor(length(s)/2), 9);
patch_sz = [9 9];
pad_sz   = (patch_sz - 1) / 2;

% Training
% Set training parameters
l3t = l3TrainOLS();
l3t.l3c = l3ClassifyFast();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {logspace(-4, -1.2, 20), 1/16};
% l3t.l3c.dataKernel = @(x) [x; x.^2];
  tgtt mn 

for jj = 1 : 2 : length(s)
    % print info
    cprintf('*Keywords', 'Training on Image: %s\n', s(jj).name);
    
    % load raw and jpg image
    img_name = s(jj).name(1:end-4);
    [I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
    
    % build l3Data class
    l3d = l3DataCamera({I_raw}, {jpg}, cfa);
    
    % adding classify data
    l3t.l3c.classify(l3d);
end

% learn linear filters
l3t.train();

% save trained kernels
l3t.l3c.clearData();
save([outDir 'l3t.mat'], 'l3t', 'cfa');

% Rendering
l3r = l3Render();

for jj = 2 : 2 : length(s)
    % print info
    cprintf('*Keywords', 'Rendering on Image: %s\n', s(jj).name);
    
    % load raw and jpg image
    img_name = s(jj).name(1:end-4);
    [I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
    
    l3_RGB = l3r.render(I_raw, cfa, l3t);
    l3_RGB = ieClip(l3_RGB, 0, 1);
    
    % save l3 rendered RGB image
    imwrite(l3_RGB, [outDir img_name '.JPG']);
    
    % SCIELAB
    xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
    xyz2 = imageLinearTransform(jpg, rgb2xyz);
    de = scielab(xyz1, xyz2, wp, params);
    de_quantile_p7(jj/2, :) = quantile(de(:), 0.1:0.1:0.9);
end

% END