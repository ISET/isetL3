%% s_SPIECreateMovieMatchBayerRgbw
%
% This script renders a movie matching similar visual quality images
% rendered at different light levels from Bayer and RGBW L3 camera. 
% 
%
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Save rendered images and video in a local server
saveFolder = '/biac4/wandell/data/qytian/L3Project/spie2013/movie_match_bayer_rgbw';

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
    writerObj = VideoWriter(fullfile(saveFolder, 'movie_match_bayer_rgbw'), 'Motion JPEG AVI');
    writerObj.FrameRate = fps;
    writerObj.Quality = 95;
    open(writerObj);
end

%% Specify light levels 
luminances = logspace(-2, log(2)/log(10), 80);
ratio = 3.5;

%% Render images
if ~saveMovie
    satPercent_Bayer = rendervideoframes(L3camera_Bayer, scene, luminances * ratio, saveFolder);
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
        loadFile = fullfile(saveFolder, [name '_srgbResult_' num2str(lum * ratio) '.png']);
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

        h = text(1, 640, [num2str(lum * ratio, 3), ' cd/m^2'], 'FontSize', 25);
        set(h, 'Color', 'w');

        h = text(sz(2)+50, 640, [num2str(lum, 3), ' cd/m^2'], 'FontSize', 25);
        set(h, 'Color', 'w');

        F = getframe(1);
        writeVideo(writerObj, F);

        pause(0.1)
    end
    close(writerObj);
end