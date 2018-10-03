%% t_L3DataISET
%
% Tutorial using L3 with data generated with ISET simulations
%
% (HJ) VISTA TEAM, 2015

%% Init
ieInit

%% l3Data class

% Init the class we use for data simulation
l3d = l3DataISET();
l3d.illuminantLev = [50 10 80];
l3d.inIlluminantSPD = {'D65'};
l3d.outIlluminantSPD = {'D65'};

% Create camera and get autoexposure
camera = cameraCreate;
camera = cameraSet(camera,'sensor',sensorCreateQuad);

l3d.camera = camera;

%% Training

% Create training class instance.  The other possibilities are l3TrainOLS
% and l3TrainWiener.
l3t = l3TrainRidge();

% set training parameters for the lookup tables.  These are the number and
% spacing of the response levels, and the training patch size
l3t.l3c.cutPoints = {logspace(-1.7, -0.12, 30), []};
l3t.l3c.patchSize = [5 5];
%l3t.l3c.channelName = ["g1", "r", "b", "g2", "w"];
% Invoke the training algorithm
l3t.train(l3d);

% If the data set is small, we interpolate the missing kernels
% l3t.fillEmptyKernels;
%% Render

% Render a scene in the training set
% The fov can be a little different from the training scene

% create a l3 render class.  This class knows how to apply the set of
% lookup tables to the camera input data.
l3r = l3Render();

% Obtain the sensor mosaic response to a scene.  Could be any scene
scene = l3d.get('scenes', 1);

vcNewGraphWin([], 'wide');
subplot(1,3,1); 
imshow(sceneGet(scene, 'rgb')); title('Scene Image');

% Use isetcam to compute the camera data.
camera  = cameraCompute(l3d.camera, scene);
cfa     = cameraGet(l3d.camera, 'sensor cfa pattern');
cmosaic = cameraGet(camera, 'sensor volts');

% Show the raw data, before processing
subplot(1, 3, 2); 
imagesc(cmosaic); axis image; colormap(gray);
axis off; title('Camera Raw Data');

% Compute L3 rendered image
% The L3 rendered image is blurry compared to the
% scene image. This is a result of lens blur in the camera.
outImg = l3r.render(cmosaic, cfa, l3t);
outImg = outImg / max(max(outImg(:,:,2)));
subplot(1,3,3); imshow(xyz2srgb(outImg)); title('L3 Rendered Image');

%% Now, render a scene that we did not use as part of the training

scene = sceneFromFile('hats.jpg', 'rgb', 50, 'LCD-Apple');
scene = sceneSet(scene, 'fov', 20);

vcNewGraphWin([], 'wide');
subplot(1, 3, 1); imshow(sceneGet(scene, 'rgb')); title('Scene Image');

camera = cameraCompute(l3d.camera, scene);
cmosaic = cameraGet(camera, 'sensor volts');

subplot(1, 3, 2); imagesc(cmosaic); axis image; colormap(gray);
axis off; title('Camera Raw Data');

outImg = l3r.render(cmosaic, cfa, l3t);
outImg = outImg / max(max(outImg(:,:,2)));
subplot(1, 3, 3); imshow(xyz2srgb(outImg)); title('L3 Rendered Image');

%%