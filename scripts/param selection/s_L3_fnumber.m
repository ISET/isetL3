%% s_L3_fnumber
%
% L3 learns different transforms for different f-numbers.  This is because
% the statistics of the input change when the lens blurring changes.
%
% We need to understand what is the right thing when, say, we have a large
% aperture and thus small depth of field.  In that case, the image contains
% a mixture of sharp and blurred.  If we have a small aperture, it is all
% sharp, and so forth.
%
%
%  HJ, VISTA TEAM, 2016
%% Init
% init ISET session
ieInit

% init L3 parameters
patchSz = [5 5];  % patch size
lum_levels = logspace(-2, -0.2, 30);

%% L3 training and rendering
% init L3 training structure
l3t = l3TrainRidge();
l3t.l3c.cutPoints = {lum_levels, []};
l3t.l3c.patchSize = patchSz;
l3t.verbose = false;
l3t.l3c.verbose = false;

% Init default RGB Bayer camera
camera = cameraCreate;
camera = cameraSet(camera,'pixel size constant fill factor',1.4e-6);
% sensor = cameraGet(camera,'sensor');
% sensorShowCFA(sensor,false,[],3);

% Diameter
% for f/# 2, 8 and 16 are 2.44, 9.76, 19.5


%% learn L3 transforms with different optics
for fnumber = [4 ]
    % l3Data class
    camera = cameraSet(camera, 'oi fnumber', fnumber);
    
    % Show the PSF for this optics
    %     oi = cameraGet(camera,'oi');
    %     oi = oiSet(oi,'name',sprintf('F/# %.1f',fnumber));
    %     oiPlot(oi,'psf 550');

    l3d = l3DataSimulation('camera', camera);
    
    % Learn L3 transforms
    l3t.l3c.clearData;
    l3t.train(l3d);
    
    % Plot kernels
    l3t.symmetricKernels;
    l3t.plot('kernel image', 29);
    
    % show optical image
    oi = l3d.camera.oi;
    oi = oiCompute(oi, l3d.sources{1});
    vcNewGraphWin; imshow(oiGet(oi, 'rgb image'));
    title(sprintf('fnumber %d', fnumber));
end

%% 
