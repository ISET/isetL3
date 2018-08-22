%% Apply L3 method to exam the effect of imaging in low light.
% Scene luminance is varied.

%% 
ieInit;

%% Set parameters

FOV = 30;
luminance = [1 5 10 50 100];
luminanceHigh = 150;
expTime = 0.5;
fNumber = 5.6;
analogGain = 8000;

% Initiate parameters for the l3 training
cfa = [2 1; 3 2];
p_max = 1000;
patch_sz = [5 5];
pad_sz = (patch_sz - 1)/2;

% cutpoint settings (need to form the proper range for each luminance)
minCutPoint =[-6.5, -5.6, -5.3, -4.9, -4.2];
maxCutPoint =[-5.6, -4.9, -4.5, -3.8, -3.4];

%% Create groundtruth under high luminance

% Define the full path to the image.
fname = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs.mat');

% Load the scene
scene = sceneFromFile(fname, 'multispectral');

% Set the scene FOV
scene = sceneSet(scene, 'hfov', FOV);
scene = sceneAdjustLuminance(scene, luminanceHigh);
ieAddObject(scene); sceneWindow;

%% Generate sRGB image under high luminance
% Create a new camera
camera = cameraCreate;

% Set the parameters 

% Set the ISO speed
camera = cameraSet(camera, 'sensor analogGain', analogGain);

% f = 5.6 according to the paper.
camera = cameraSet(camera, 'optics fnumber', fNumber); 

% Exposure time is first set to be 1/30 s
camera = cameraSet(camera, 'sensor exp time', expTime);

% Compute 
camera = cameraCompute(camera,scene);

%% Visualize the sensor data and sRGB image
rawGrndTrue = cameraGet(camera,'sensor volts');
vcNewGraphWin;
imagesc(rawGrndTrue); axis image; colormap(gray);
axis off; title('Raw image for groundtruth');

sRGBGrndTrue = cameraGet(camera,'ip data srgb'); 
vcNewGraphWin; 
imagesc(sRGBGrndTrue); axis image; axis off; title('sRGB image for groundtruth');

%% Change the luminance for scenes and train

rawImg = cell(1, length(luminance));
sRGBImg = cell(1, length(luminance));

l3Img = cell(1, length(luminance));
de_img = cell(1, length(luminance));
de = zeros(1, length(luminance));

for ii = 1 : length(luminance)
    % Create a new l3t training data.
    l3t = l3TrainRidge();

    % Set the parameters
    l3t.l3c.patchSize = patch_sz;
    l3t.l3c.p_max = p_max;
    l3t.l3c.statFunc = {@imagePatchMean};
    l3t.l3c.statFuncParam = {{}};
    l3t.l3c.statNames = {'mean'};

    l3t.l3c.channelName = ["g1", "r", "b", "g2", "w"];
    
    l3t.l3c.cutPoints = {logspace(minCutPoint(ii), maxCutPoint(ii), 40)};
    
    scene = sceneAdjustLuminance(scene, luminance(ii));
    
    % Create a new camera
    camera = cameraCreate;

    % Set the parameters 

    % Set the ISO speed
    camera = cameraSet(camera, 'sensor analogGain', analogGain);

    % f = 5.6 according to the paper.
    camera = cameraSet(camera, 'optics fnumber', fNumber); 

    % Exposure time is first set to be 1/30 s
    camera = cameraSet(camera, 'sensor exp time', expTime);
    
    camera = cameraCompute(camera,scene);
    
    rawImg{ii} = cameraGet(camera,'sensor volts');
    sRGBImg{ii} = cameraGet(camera, 'ip data srgb');
    
    l3t.l3c.classify(l3DataCamera({rawImg{ii}}, {sRGBGrndTrue}, cfa));
    
    % train
    l3t.train();
    
    %% Render the image with the trained L3 model
    l3r = l3Render();
    
    l3Img{ii} = ieClip(l3r.render(rawImg{ii}, cfa, l3t), 0, 1);
    
    vcNewGraphWin; imagesc(l3Img{ii}); axis image; axis off;
    title(['L3 image under ' num2str(luminance(ii)) ' cd/m^2']);

    vcNewGraphWin; imagesc(sRGBImg{ii}); axis image; axis off;
    title(['sRGB image under ' num2str(luminance(ii)) ' cd/m^2']);
    
    %% Comptue S-CIELAB difference
    % Init parameters
    d = displayCreate('LCD-Apple');
    d = displaySet(d, 'gamma', 'linear');  % use a linear gamma table
    d = displaySet(d, 'viewing distance', 1);
    rgb2xyz = displayGet(d, 'rgb2xyz');
    wp = displayGet(d, 'white xyz'); % white point
    params = scParams;
    params.sampPerDeg = displayGet(d, 'dots per deg');
    
    xyz1 = imageLinearTransform(l3Img{ii}, rgb2xyz);
    xyz2 = imageLinearTransform(sRGBImg{ii}, rgb2xyz);
    de_img{ii} = scielab(xyz1, xyz2(3:end - 2, 3:end - 2, :), wp, params);
    de(ii) = mean(de_img{ii}(:));
    
    vcNewGraphWin; imagesc(de_img{ii}); 
    axis image; axis off; colorbar; title(['S-CIELAB dE under ' num2str(luminance(ii)) ' cd/m^2']);
end

%% Plot the luminance vs. mean S-CIELAB

vcNewGraphWin;
plot(luminance, de, '-o');
xlabel('luminance (cd/m^2)'); ylabel('mean S-CIELAB dE');

