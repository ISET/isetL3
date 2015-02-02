%% t_L3TrainOverview
%
% Demonstrate the L3 training process in overview
%
% Separate scripts t_L3Train<TAB> examine specific choices within the
% algorithm.
%
% Copyright VISTASOFT Team, 2015
%

%%
ieInit

%% Create and initialize L3 structure
L3 = L3Create;
L3 = L3Initialize(L3);  % use default parameters

blockSize = 5;               % Size of the solution patch used by L3
L3 = L3Set(L3,'block size', blockSize);


%%  The analysis here is an expansion of L3Train.m

% The scenes used for training are set by default in L3
% By default, there are 7 scenes.
nScenes = L3Get(L3,'n scene');
fprintf('Number of training scenes: %i\n',nScenes)

% Here is an example training scene
scene = L3Get(L3,'scene',1);
vcAddObject(scene); sceneWindow;

% To make this code run fast, we reduce the training scenes here to just
% two
scenes = L3Get(L3,'scenes');
scenes = scenes(1:2);
L3 = L3Set(L3,'scenes',scenes);

% In general, we should have a simple way to alter the scene selection
% here and re-attach the new scenes or modified scenes (e.g., by an
% illuminant change as per FG).

%%  Next we create examples of the sensor and ideal responses
%
% This code explores an overview of what happens in 
%
%     L3 = L3Train(L3);
%
L3 = L3Set(L3,'sensor exptime',0.02); 
[desiredIm, inputIm] = L3SensorImageNoNoise(L3);
fprintf('Exposure time set %.1f ms\n',L3Get(L3,'sensor exptime','ms'))

% The camera that we are designing for design is stored in L3.sensor.design
% The default camera has 4 sensors (RGBW)
sensor = L3Get(L3,'design sensor');
plotSensor(sensor,'color filters');

% There are two cell arrays, one for each of the input scenes
fprintf('Number of scenes:  %i\n',size(inputIm,1))

% The input images are the sensor voltages from the scene.  In this case
% there are four color filters and thus four images.  
% Why is the white image saturated?
vcNewGraphWin([],'tall');
for ii=1:4
    subplot(2,2,ii), imagesc(inputIm{1}(:,:,ii)); colormap(gray); axis image
end

% vcNewGraphWin; tmp = inputIm{1}(:,:,4); hist(tmp(:),50)
% These are the XYZ images.  The scale drives me nuts (BW).
vcNewGraphWin([],'tall');
for ii=1:3
    subplot(3,1,ii), imagesc(desiredIm{1}(:,:,ii)); colormap(gray); axis image
end

%%
