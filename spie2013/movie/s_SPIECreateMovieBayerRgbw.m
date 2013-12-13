%% s_SPIECreateMovieBayerRgbw
%
% This script renders a movie comparing the rendered images from Bayer and
% RGBW camera for different light levels.
% 
%
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Save rendered images and video in a local server
saveFolder = '/biac4/wandell/data/qytian/L3Project/spie2013/movie_bayer_rgbw';

% If it doesn't exist, create the folder where files will be saved
if exist(saveFolder, 'dir')~=7
    mkdir(saveFolder)
end

%% Load pre-trained cameras
load(fullfile(L3rootpath,'cameras','L3','L3camera_Bayer.mat')); 
L3camera_Bayer = camera;
L3camera_Bayer = cameraSet(L3camera_Bayer, 'name', 'L3camera_Bayer');

load(fullfile(L3rootpath,'cameras','L3','L3camera_RGBW1.mat')); 
L3camera_RGBW = camera;
L3camera_RGBW = cameraSet(L3camera_RGBW, 'name', 'L3camera_RGBW');

%% Load scene
scene = sceneFromFile('/biac4/wandell/data/qytian/L3Project/scene/AsianWoman_1.mat', 'multispectral');
sz = sceneGet(scene, 'size');

%% Set up video 
saveMovie = 1;
if saveMovie
    fps = 15;
    writerObj = VideoWriter(fullfile(saveFolder, 'movie_bayer_rgbw'), 'Motion JPEG AVI');
    writerObj.FrameRate = fps;
    writerObj.Quality = 95;
    open(writerObj);
end

%% Specify light levels 
luminances = [logspace(-2, 1, 100), 10:5:300];

%% Render images
if ~saveMovie
    satPercent_Bayer = rendervideoframes(L3camera_Bayer, scene, luminances, saveFolder);
    satPercent_RGBW = rendervideoframes(L3camera_RGBW, scene, luminances, saveFolder);
    saveFile = fullfile(saveFolder, 'satPercent.mat');
    save(saveFile, 'satPercent_Bayer', 'satPercent_RGBW');
end

%% Render video
if saveMovie
    figure(1); clf;
    set(gcf, 'Color', 'k', 'Position', [100 100 1400 800]);
    
    for ii = 1 : length(luminances)
        lum = luminances(ii); 
        disp(lum)
        
        name = cameraGet(L3camera_Bayer, 'name');
        loadFile = fullfile(saveFolder, [name '_srgbResult_' num2str(lum) '.png']);
        srgbResult_Bayer = imread(loadFile);
        
        name = cameraGet(L3camera_RGBW, 'name');
        loadFile = fullfile(saveFolder, [name '_srgbResult_' num2str(lum) '.png']);
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
end