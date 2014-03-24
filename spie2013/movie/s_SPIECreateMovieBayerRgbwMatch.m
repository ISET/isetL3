%% s_SPIECreateMovieMatchBayerRgbw
%
% This script renders a movie matching similar visual quality images
% rendered at different light levels from Bayer and RGBW L3 camera. The
% movie is for SPIE oral presentation.
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
writerObj = VideoWriter('movie_bayer_rgbw_match', 'Motion JPEG AVI');
writerObj.FrameRate = fps;
writerObj.Quality = 95;
open(writerObj);

%% Specify light levels 
luminances_RGBW = logspace(-2, log(2)/log(10), 80); % luminance levels for RGBW

ratio = 3.5; % ratio of Bayer luminances levels versus RGBW levels 
luminances_Bayer = luminances_RGBW * ratio; % luminance levels for Bayer

%% Render images
framesFolder = 'frames_bayer_rgbw_match'; % folder storing rendered movie frames

% If it doesn't exist, create the folder and render images
if exist(framesFolder, 'dir')~=7
    disp('***None video frames exist. Start rendering');
    mkdir(framesFolder)
    
    satPercent_Bayer = rendervideoframes(L3camera_Bayer, scene, luminances_Bayer, framesFolder);
    satPercent_RGBW = rendervideoframes(L3camera_RGBW, scene, luminances_RGBW, framesFolder);
    save('satPercent_Bayer_RGBW_Match.mat', 'satPercent_Bayer', 'satPercent_RGBW');
end

%% Render video

figure(1); clf;
set(gcf, 'Color', 'k', 'Position', [100 100 1400 800]);

for ii = 1 : length(luminances_RGBW)
    lum = luminances_RGBW(ii); 
    disp(lum)

    name = cameraGet(L3camera_Bayer, 'name');
    loadFile = fullfile(framesFolder, [name '_srgbResult_' num2str(lum * ratio) '.png']);
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

    h = text(1, 640, [num2str(lum * ratio, 3), ' cd/m^2'], 'FontSize', 25);
    set(h, 'Color', 'w');

    h = text(sz(2)+50, 640, [num2str(lum, 3), ' cd/m^2'], 'FontSize', 25);
    set(h, 'Color', 'w');

    F = getframe(1);
    writeVideo(writerObj, F);

    pause(0.1)
end
close(writerObj);
