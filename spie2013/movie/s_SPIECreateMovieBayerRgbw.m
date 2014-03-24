%% s_SPIECreateMovieBayerRgbw
%
% This script renders a movie comparing the rendered images from Bayer and
% RGBW camera for different light levels. The movie is for SPIE oral
% presentation.
% 
%
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Make sure you have trained the two relevant cameras

% s_L3TrainCamerasforCFAs trains the CFA in selectedCFAList
% This will work as long as we don't change the published CFAs.
% A better method would be preferred.

cFile = fullfile(L3rootpath,'cameras','L3','L3camera_Bayer.mat');
if ~exist(cFile,'file')
    fprintf('Training %s\n',cFile)
    selectedCFAList = 1;
    s_L3TrainCamerasforCFAs % train cameras for CFAs
end

cFile = fullfile(L3rootpath,'cameras','L3','L3camera_RGBW1.mat');
if ~exist(cFile,'file')
    fprintf('Training %s\n',cFile)
    selectedCFAList = 19;
    s_L3TrainCamerasforCFAs % train cameras for CFAs
end

%% Load cameras
cFile = fullfile(L3rootpath,'cameras','L3','L3camera_Bayer.mat');
foo = load(cFile); L3camera_Bayer = foo.camera;
L3camera_Bayer = cameraSet(L3camera_Bayer, 'name', 'L3camera_Bayer');


cFile = fullfile(L3rootpath,'cameras','L3','L3camera_RGBW1.mat');
foo = load(cFile); L3camera_RGBW = foo.camera;
L3camera_RGBW = cameraSet(L3camera_RGBW, 'name', 'L3camera_RGBW');

%% Load scene
scene = sceneFromFile(fullfile(L3rootpath,'spie2013','data','AsianWoman_1.mat'), 'multispectral');
sz = sceneGet(scene, 'size');

%% Set up video 
fps = 15;
writerObj = VideoWriter('movie_bayer_rgbw', 'Motion JPEG AVI');
writerObj.FrameRate = fps;
writerObj.Quality = 95;
open(writerObj);

%% Specify light levels 
% 100 frames log spaced between 0.01 to 10 cd/m2
% 50 frames lineraly spaced between 10 to 300 cd/m2
luminances = [logspace(-2, 1, 100), 10:5:300]; 

%% Render images
framesFolder = 'frames_bayer_rgbw'; % folder storing rendered movie frames

% If it doesn't exist, create the folder and render images
if exist(framesFolder, 'dir')~=7
    disp('***None video frames exist. Start rendering');
    mkdir(framesFolder)
    
    satPercent_Bayer = rendervideoframes(L3camera_Bayer, scene, luminances, framesFolder);
    satPercent_RGBW = rendervideoframes(L3camera_RGBW, scene, luminances, framesFolder);
    save('satPercent_Bayer_RGBW.mat', 'satPercent_Bayer', 'satPercent_RGBW');
end

%% Render video
figure(1); clf;
set(gcf, 'Color', 'k', 'Position', [100 100 1400 800]);

for ii = 1 : length(luminances)
    lum = luminances(ii); 
    disp(lum)

    name = cameraGet(L3camera_Bayer, 'name');
    loadFile = fullfile(framesFolder, [name '_srgbResult_' num2str(lum) '.png']);
    srgbResult_Bayer = imread(loadFile);

    name = cameraGet(L3camera_RGBW, 'name');
    loadFile = fullfile(framesFolder, [name '_srgbResult_' num2str(lum) '.png']);
    srgbResult_RGBW = imread(loadFile);

    srgbResult = [srgbResult_Bayer, zeros(sz(1), 50, 3), srgbResult_RGBW];
    imshow(srgbResult)

    h = text(300, 600, 'Bayer', 'FontSize', 25);
    set(h, 'Color', 'w');

    h = text(1000, 600, 'RGBW', 'FontSize', 25);
    set(h, 'Color', 'w');

    for barPos = [1, 34, 67, 100, 119, 139, 159]
        h = text((barPos-1) / length(luminances) * size(srgbResult, 2), 650, '|', 'FontSize', 25);
        set(h, 'Color', 'w');
    end

    h = text((ii-1) / length(luminances) * size(srgbResult, 2), 650, 'o', 'FontSize', 25);
    set(h, 'Color', 'w');

    h = text(1340, 630, [num2str(lum, 3) 'cd/m^2'], 'FontSize', 10);
    set(h, 'Color', 'w');

    F = getframe(1);
    writeVideo(writerObj, F);

    pause(0.1)
end
close(writerObj);
    
%% End
