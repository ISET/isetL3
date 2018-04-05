%% s_L3Object_NonLinear
%
%    Testing if adding nonlinear term could help improve L3 performance
%
% HJ, VISTA TEAM, 2015

% Init ISET SESSION
ieInit;

%% Init parameters
cfa = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
patch_sz = [5 5];
pad_sz   = (patch_sz - 1) / 2;

% Init remote data
rdt = RdtClient('scien');
rdt.crp('/L3/Farrell/D200/garden');
s = rdt.searchArtifacts('dsc_', 'type', 'pgm');

% Allocate space to store results
nImages = length(s);
de_quantile = zeros(floor(length(s)/2), 9);
de_quantile_nl = zeros(floor(length(s)/2), 9);
de_quantile_xyz = zeros(floor(length(s)/2), 9);
de_quantile_nl_xyz = zeros(floor(length(s)/2), 9);

% Init sCIELab parameters
d = displayCreate('LCD-Apple');
d = displaySet(d, 'gamma', 'linear');  % use a linear gamma table
d = displaySet(d, 'viewing distance', 1);
rgb2xyz = displayGet(d, 'rgb2xyz');
wp = displayGet(d, 'white xyz'); % white point
params = scParams;
params.sampPerDeg = displayGet(d, 'dots per deg');

%% Training and rendering with linear kernel
% Set training parameters
l3t = l3TrainOLS();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {logspace(-3, -1.2, 20), []};
l3t.l3c.p_max = 1e4;

% training
for jj = 1 : 2 : length(s)
    % print info
    cprintf('*Keywords', 'Training on Image: %s\n', s(jj).artifactId);
    
    % load raw and jpg image
    img_name = s(jj).artifactId;
    raw = im2double(rdt.readArtifact(img_name, 'type', 'pgm'));
    rgb = im2double(rdt.readArtifact(img_name, 'type', 'jpg'));

    % adding classify data
    l3t.l3c.classify(l3DataCamera({raw}, {rgb}, cfa));
end

% learn linear filters
l3t.train();

% Rendering
l3r = l3Render();
for jj = 2 : 2 : length(s)
    % print info
    cprintf('*Keywords', 'Rendering on Image: %s\n', s(jj).artifactId);
    
    % load raw and jpg image
    img_name = s(jj).artifactId;
    raw = im2double(rdt.readArtifact(img_name, 'type', 'pgm'));
    rgb = im2double(rdt.readArtifact(img_name, 'type', 'jpg'));
    rgb = rgb(pad_sz(1)+1:end-pad_sz(1), pad_sz(2)+1:end-pad_sz(2), :);
    
    % render
    l3_RGB = ieClip(l3r.render(raw, cfa, l3t), 0, 1);
    
    % SCIELAB
    xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
    xyz2 = imageLinearTransform(jpg, rgb2xyz);
    de = scielab(xyz1, xyz2, wp, params);
    de_quantile(jj/2, :) = quantile(de(:), 0.1:0.1:0.9);
end

%% Training and rendering with non-linear kernel
% Set training parameters
l3t = l3TrainOLS();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {logspace(-3, -1.2, 20), []};
l3t.l3c.dataKernel = @(x) [x; x.^2.4];
l3t.l3c.p_max = 1e4;

for jj = 1 : 2 : length(s)
    % print info
    cprintf('*Keywords', 'Training on Image: %s\n', s(jj).artifactId);
    
    % load raw and jpg image
    img_name = s(jj).artifactId;
    raw = im2double(rdt.readArtifact(img_name, 'type', 'pgm'));
    rgb = im2double(rdt.readArtifact(img_name, 'type', 'jpg'));
    
    % adding classify data
    l3t.l3c.classify(l3DataCamera({raw}, {rgb}, cfa));
end

% learn linear transforms
l3t.train();

% Rendering
l3r = l3Render();
for jj = 2 : 2 : length(s)
    % print info
    cprintf('*Keywords', 'Rendering on Image: %s\n', s(jj).artifactId);
    
    % load raw and jpg image
    img_name = s(jj).artifactId;
    raw = im2double(rdt.readArtifact(img_name, 'type', 'pgm'));
    rgb = im2double(rdt.readArtifact(img_name, 'type', 'jpg'));
    rgb = rgb(pad_sz(1)+1:end-pad_sz(1), pad_sz(2)+1:end-pad_sz(2), :);
    
    % render
    l3_RGB = ieClip(l3r.render(raw, cfa, l3t), 0, 1);
    
    % SCIELAB
    xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
    xyz2 = imageLinearTransform(jpg, rgb2xyz);
    de = scielab(xyz1, xyz2, wp, params);
    de_quantile_nl(jj/2, :) = quantile(de(:), 0.1:0.1:0.9);
end

% It can be seen that non-linear term greatly improve L3 performance. But
% we guess this is because of the non-linearity in sRGB color space. Next,
% we will try to redo the experiment in XYZ space

%% Training and rendering with linear kernel in XYZ
% Set training parameters
l3t = l3TrainOLS();
l3t.l3c = l3ClassifyFast();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {logspace(-4, -1.2, 20), 1/32};

for jj = 1 : 2 : length(s)
    % print info
    cprintf('*Keywords', 'Training on Image: %s\n', s(jj).artifactId);
    
    % load raw and jpg image
    img_name = s(jj).name(1:end-4);
    [I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
    l3d = l3DataCamera({I_raw}, {srgb2xyz(jpg)}, cfa);
    
    % adding classify data
    l3t.l3c.classify(l3d);
end

% learn linear filters
l3t.train();

% Rendering
l3r = l3Render();
for jj = 2 : 2 : length(s)
    % print info
    cprintf('*Keywords', 'Rendering on Image: %s\n', s(jj).artifactId);
    
    % load raw and jpg image
    img_name = s(jj).name(1:end-4);
    [I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
    
    l3_XYZ = l3r.render(I_raw, cfa, l3t);
    l3_RGB = ieClip(xyz2srgb(l3_XYZ), 0, 1);
    
    % SCIELAB
    xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
    xyz2 = imageLinearTransform(jpg, rgb2xyz);
    de = scielab(xyz1, xyz2, wp, params);
    de_quantile_xyz(jj/2, :) = quantile(de(:), 0.1:0.1:0.9);
end

%% Training and rendering with non-linear kernel
% Set training parameters
l3t = l3TrainOLS();
l3t.l3c = l3ClassifyFast();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {logspace(-4, -1.2, 20), 1/32};
l3t.l3c.dataKernel = @(x) [x; x.^2.4];

for jj = 1 : 2 : length(s)
    % print info
    cprintf('*Keywords', 'Training on Image: %s\n', s(jj).name);
    
    % load raw and jpg image
    img_name = s(jj).name(1:end-4);
    [I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
    l3d = l3DataCamera({I_raw}, {srgb2xyz(jpg)}, cfa);
    
    % adding classify data
    l3t.l3c.classify(l3d);
end

% learn linear filters
l3t.train();

% Rendering
l3r = l3Render();
for jj = 2 : 2 : length(s)
    % print info
    cprintf('*Keywords', 'Rendering on Image: %s\n', s(jj).name);
    
    % load raw and jpg image
    img_name = s(jj).name(1:end-4);
    [I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
    
    l3_XYZ = l3r.render(I_raw, cfa, l3t);
    l3_RGB = xyz2srgb(l3_XYZ);
    l3_RGB = ieClip(l3_RGB, 0, 1);
    
    % SCIELAB
    xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
    xyz2 = imageLinearTransform(jpg, rgb2xyz);
    de = scielab(xyz1, xyz2, wp, params);
    de_quantile_nl_xyz(jj/2, :) = quantile(de(:), 0.1:0.1:0.9);
end

%% Print results
fprintf('Mean de (linear): %.4f\n', mean(de_quantile(:, 5)));
fprintf('Mean de (nonlinear): %.4f\n', mean(de_quantile_nl(:, 5)));
fprintf('Mean de (linear xyz): %.4f\n', mean(de_quantile_xyz(:, 5)));
fprintf('Mean de (nonlinear xyz): %.4f\n', mean(de_quantile_nl_xyz(:, 5)));