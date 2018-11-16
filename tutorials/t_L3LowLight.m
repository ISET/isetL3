%% t_L3LowLight
% Try to do image process under low light environment

%% init
ieInit;

%% Load scenes
scenePath = '/scratch/ZhengLyu/sampleDataSet/scene';
format = 'mat';

scenes = loadScenes(scenePath, format, 2);

%% 
l3dLowLight = l3DataISET('nscenes', numel(scenes), 'scenes', scenes); 
% l3dLowLight = l3DataISET();
% Todo: 1) Define how to make the scene very dark. 2) Determine how to make
% the target image implemented into the target dataset. 3) How to train the
% model.

%%
l3dLowLight.illuminantLev = [50, 10, 80];
l3dLowLight.inIlluminantSPD = {'D65'};
l3dLowLight.outIlluminantSPD = {'D65'};


%% Set the camera with the Huawei parameter
camera = cameraCreate;

% Create the quadra pattern
camera = cameraSet(camera,'sensor',sensorCreateQuad);

% Set the row & col of the sensor
sensorRow = 5160;
sensorCol = 6880;
camera = cameraSet(camera, 'sensor row', sensorRow);

% 

% Exposure time is set to be 30 ms
camera = cameraSet(camera, 'sensor exp time', 0.03);
camera = cameraSet(camera, 'sensor analog gain', 1);
l3dLowLight.set('camera', camera);
%{
[inImg, outImg, ~] = l3dLowLight.dataGet();
vcNewGraphWin(); imagesc(inImg{1}); colormap(gray);

vcNewGraphWin(); imagesc(xyz2srgb(outImg{1} / max(max(outImg{1}(:,:,2)))));

% Make sure we are using a proper parameter
sceneTest = sceneAdjustLuminance(scenes{1}, 0.7);
camera = cameraCompute(camera, sceneTest);
cameraWindow(camera,'ip')


camera = cameraSet(camera, 'sensor analog gain', 1);
[~,img2] = cameraCompute(camera, sceneTest);


vcNewGraphWin(); imagesc(img2); title('img2')
%}

%% Set the training data
% Create training class instance.  The other possibilities are l3TrainOLS
% and l3TrainWiener.
l3t = l3TrainRidge();
%%
% set training parameters for the lookup tables.  These are the number and
% spacing of the response levels, and the training patch size
l3t.l3c.cutPoints = {logspace(-3.5, -1.5, 30), []};
l3t.l3c.patchSize = [5 5];
%l3t.l3c.channelName = ["g1", "r", "b", "g2", "w"];
l3t.l3c.satClassOption = 'none';
% Invoke the training algorithm
l3t.train(l3dLowLight);

%% Exam the training result
%{
    % Exam the linearity of the kernels
    thisClass = 5; 
    
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
    vcNewGraphWin; imagesc(reshape(l3t.kernels{thisClass}(2:26,thisChannel),...
            [5, 5]));  colormap(gray);axis off %colorbar;
%}

%% Check the processed output image
%{
[inImg, outImg, ~] = l3dLowLight.dataGet();
outImgcc = outImg;
for ii = 1 : length(outImg)
    outImgcc{ii} = outImgcc{ii} / max(max(outImgcc{ii}(:,:,2)));
    outImgcc{ii} = xyz2rgb(outImgcc{ii});
end

% Sampled img
thisImg1 = 1;
imshow(outImgcc{thisImg1});
vcNewGraphWin; imagesc(inImg{thisImg1});colormap(gray);


%}

%% Check out the render section
% This section is used to justify if the new scenes can be properly
% rendered.
%{
l3r = l3Render();

% Obtain the sensor mosaic response to a scene.  Could be any scene
scene = l3dLowLight.get('scenes', 1);
scene = sceneAdjustLuminance(scene, l3dLowLight.illuminantLev(1));

vcNewGraphWin([], 'wide');
subplot(1,3,1); 
imshow(sceneGet(scene, 'rgb')); title('Scene Image');

% Use isetcam to compute the camera data.
[camera, img]  = cameraCompute(l3dLowLight.camera, scene);
cfa     = cameraGet(l3dLowLight.camera, 'sensor cfa pattern');
cmosaic = cameraGet(camera, 'sensor volts');

% Show the raw data, before processing
subplot(1, 3, 2); 
imagesc(cmosaic); axis image; colormap(gray);
axis off; title('Camera Raw Data with Bayer Pattern');

% Compute L3 rendered image
% The L3 rendered image is blurry compared to the
% scene image. This is a result of lens blur in the camera.
outImg = l3r.render(cmosaic, cfa, l3t);
outImg = outImg / max(max(outImg(:,:,2)));
subplot(1,3,3); imshow(xyz2srgb(outImg)); title('L3 Rendered Image');

sensorTest = cameraGet(camera,'sensor');

%}

%{
% Take the image 
camera = cameraSet(camera, 'ip result', xyz2srgb(outImg));
cameraWindow(camera, 'ip');
%}


