%% t_L3DataISET
%
% Tutorial using L3 with data generated with ISET simulations
%
% (HJ) VISTA TEAM, 2015

%% Init
ieInit

%% l3Data class

% Init the class we use for data simulation
l3d = l3DataSimulation();

% Set up parameters for generating training data
nImg = 7;                       % Number of images used for training
l3d.expFrac = [2, 1, 0.5];      % No idea
l3d.loadSources(nImg, 'all');   % Which default images to load

% Some of the source inputs can be optical images, apparently.  Not sure
% what is going on here.  I think I would eliminate this option (BW).
for ii = 1 : nImg
    if strcmp(l3d.sources{ii}.type, 'opticalimage')
        % Adjust focal length.  This is odd, though.
        disp('Adjusting source optical image');
        l3d.sources{ii} = oiSet(l3d.sources{ii},'optics f length', 0.01);
    end
end

%% Training

% Create training class instance.  The training classes are
%  l3TrainRidge  - Ridge regression (Tikhonov)
%  l3TrainWiener - Wiener regression
%  l3TrainOLS    - Ordinary least squares
%
% The super class for all of these is l3TrainS
%
l3t = l3TrainRidge();

% set training parameters
l3t.l3c.cutPoints = {logspace(-1.7, -0.12, 40), []};
l3t.l3c.patchSize = [5 5];

% Invoke the training algorithm
l3t.train(l3d);
% l3t.fillEmptyKernels;

%% Render one training optical image
[raw, target, ~] = l3d.dataGet(3);
raw = raw{3}; target = target{3};

l3r = l3Render();
cfa = cameraGet(l3d.camera, 'sensor cfa pattern');
outImg = l3r.render(raw, cfa, l3t);

vcNewGraphWin([], 'wide');
subplot(1, 3, 1); imshow(sceneGet(l3d.sources{1}, 'rgb image')); 
title('Optical Image');

target = target / max(max(target(:,:,2)));
subplot(1, 3, 2); imshow(xyz2srgb(target)); title('Ideal Image');

outImg = outImg / max(max(outImg(:,:,2)));
subplot(1, 3, 3); imshow(xyz2srgb(outImg)); title('L3 Rendered Image');

%% Render another scene
% create a l3 render class
l3r = l3Render();
cfa = cameraGet(l3d.camera, 'sensor cfa pattern');
% l3d.camera = cameraSet(l3d.camera, 'oi', l3d.sources{1});

% We render a test scene
scene = sceneCreate;
scene = sceneSet(scene, 'fov', 15);

camera = cameraCompute(l3d.camera, scene);
cmosaic = cameraGet(camera, 'sensor volts');

vcNewGraphWin([], 'wide');
subplot(1, 3, 1); imshow(cameraGet(camera, 'oi rgb image')); 
title('Optical Image');

subplot(1, 3, 2); imagesc(cmosaic); axis image; colormap(gray);
axis off; title('Camera Raw Data');

outImg = l3r.render(cmosaic, cfa, l3t);
outImg = outImg / max(max(outImg(:)));
subplot(1, 3, 3); imshow(xyz2srgb(outImg)); title('L3 Rendered Image');

%%