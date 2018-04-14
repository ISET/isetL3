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

%{
remoteDirectory = '/resources/scenes/multiband/yasuma';
scenes = rdtScenesLoad('nscenes',[7 9], ...
    'remote directory', remoteDirectory, ...
    'print',false);

for ii=1:length(scenes)
 scenes{ii} = sceneSet(scenes{ii},'fov',15);
end
%}

scene = scenes{1};

% Create camera and get autoexposure
camera = cameraCreate;
camera = cameraSet(camera,'sensor',sensorCreateQuad);
camera = cameraCompute(camera,scene);
SHORT  = cameraGet(camera,'sensor exp time');

% Now turn into HDR-LS mode
LONG = 2*SHORT;
eTimes = [SHORT LONG SHORT LONG; 
    LONG SHORT LONG SHORT;
    SHORT LONG SHORT LONG; 
    LONG SHORT LONG SHORT];
camera = cameraSet(camera,'sensor exp time',eTimes);
camera = cameraCompute(camera,scene);
cameraWindow(camera,'sensor'); truesize

l3d.camera = camera;

%% Set up training data

l3d.sources = rdtScenesLoad('nscenes',[3 5 7 9], ...
              'remote directory','/resources/scenes/multiband/yasuma', ...
              'print',false);
          
l3d.expFrac = [2, 1, 0.5];      % No idea

%{
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
%}

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

l3t.fillEmptyKernels;

%% Render one training optical image

% What in the world is dataGet doing!  I told it to recompute, which
% improved the situation.  But check out the logic in there and write some
% more comments.s
recompute = true;
[raw, target, ~] = l3d.dataGet(1,recompute);
raw = raw{1}; target = target{1};

l3r = l3Render();
cfa = cameraGet(l3d.camera, 'sensor cfa pattern');
outImg = l3r.render(raw, cfa, l3t);

%%
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

vcNewGraphWin([], 'wide');
subplot(1, 3, 1); imshow(cameraGet(camera, 'oi rgb image')); 
title('Optical Image');

% You can see the Long/Short pixels in this image by zooming
rgb = cameraGet(camera, 'sensor rgb');
subplot(1, 3, 2); imagesc(rgb); axis image;
axis off; title('Camera Raw Data');

% The rendering on the cmosaic is problematic, too.
outImg = l3r.render(cmosaic, cfa, l3t);
outImg = outImg / max(max(outImg(:)));
subplot(1, 3, 3); imshow(xyz2srgb(outImg)); title('L3 Rendered Image');

%%