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
l3d.illuminantLev = [70 75 50 10 80 85 90 100 105 110 120 130 140 150 160 170 180 190 200 230 250 300];
l3d.inIlluminantSPD = {'D65'};
l3d.outIlluminantSPD = {'D65'};

% Create camera with quadra pattern
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
l3t.l3c.patchSize = [9 9];
%l3t.l3c.channelName = ["g1", "r", "b", "g2", "w"];
% Invoke the training algorithm
l3t.l3c.satClassOption = 'compress';
l3t.train(l3d);

% If the data set is small, we interpolate the missing kernels
% l3t.fillEmptyKernels;


%% Exam the training result
%{
    % Exam the linearity of the kernels
    thisClass = 477; % 500, 624, 700
    
    [X, y_true]  = l3t.l3c.getClassData(thisClass);
    X = padarray(X, [0 1], 1, 'pre');
    y_pred = X * l3t.kernels{thisClass};
    thisChannel = 2;
    vcNewGraphWin; plot(y_true(:,thisChannel), y_pred(:,thisChannel), 'o');
    xlabel('Target value (ground truth)', 'FontSize', 15, 'FontWeight', 'bold');
    ylabel('Predicted value', 'FontSize', 15,'FontWeight', 'bold');
%     title(['Target value vs Predicted value for: class ', num2str(thisClass),...
%                         ' channel ' num2str(thisChannel)], 'FontWeight', 'bold');
    axis square;
    identityLine;

    vcNewGraphWin; imagesc(reshape(l3t.kernels{thisClass}(2:82,thisChannel),...
            [9, 9]));  colormap(gray);axis off %colorbar;
%}
%% Render

% Render a scene in the training set
% The fov can be a little different from the training scene

% create a l3 render class.  This class knows how to apply the set of
% lookup tables to the camera input data.
l3r = l3Render();

% Obtain the sensor mosaic response to a scene.  Could be any scene
scene = l3d.get('scenes', 6);

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
axis off; title('Camera Raw Data with Quadra Pattern');

% Compute L3 rendered image
% The L3 rendered image is blurry compared to the
% scene image. This is a result of lens blur in the camera.
outImg = l3r.render(cmosaic, cfa, l3t);
outImg = outImg / max(max(outImg(:,:,2)));
subplot(1,3,3); imshow(xyz2srgb(outImg)); title('L3 Rendered Image with Quadra pattern');

%% Now, render a scene that we did not use as part of the training

scene = sceneFromFile('eagle.jpg', 'rgb', 80, 'LCD-Apple');
scene = sceneSet(scene, 'fov', 20);

vcNewGraphWin([], 'wide');
subplot(1, 3, 1); imshow(sceneGet(scene, 'rgb')); title('Scene Image');

camera = cameraCompute(l3d.camera, scene);
cmosaic = cameraGet(camera, 'sensor volts');

subplot(1, 3, 2); imagesc(cmosaic); axis image; colormap(gray);
axis off; title('Camera Raw Data');

outImg2 = l3r.render(cmosaic, cfa, l3t);
outImg2 = outImg2 / max(max(outImg2(:,:,2)));
subplot(1, 3, 3); imshow(xyz2srgb(outImg2)); title('L3 Rendered Image with Quadra pattern');

%%

img_noSat = imread('renderedImage_Quadra_noSat.bmp');
img_Sat = imread('renderedImage_Quadra_Sat.bmp');
%%
imshow(img_noSat(:,:,1) - img_Sat(:,:,1));

temp = img_noSat(:,:,1) - img_Sat(:,:,1);