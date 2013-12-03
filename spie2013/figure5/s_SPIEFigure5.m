%% s_SPIEFigure5
%
% This script trains L3 and shows the learned Wiener operators for low, 
% medium and high response levels for SPIE2013 paper figure 5.  
% 
%
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Train L3 and create L3 camera
% Skip this step if there is one pre-computed camera
L3 = L3Initialize(); % Create and initialize L3 structure

% Adjust patch size from 9 to 5 pixels for clear visualization
blockSize = 5; % Size of the solution patch used by L3
L3 = L3Set(L3,'block size', blockSize);

% Perform training
L3 = L3Train(L3);

% Setup and save L3 camera
camera = L3CameraCreate(L3);
save('L3Camera', 'camera'); % save camera

%% Show linear operators
load('L3Camera.mat'); % load L3 camera
L3 = cameraGet(camera, 'L3');
sz = L3Get(L3,'blocksize'); 
r = sz(1); 
c = sz(2);

% Global filter reflects the general principle of L3
filters = L3Get(L3,'globalfilter',[1, 1], 1, 1); % low response, no saturation
filters = L3Get(L3,'globalfilter',[1, 1], 14, 1); % medium response, no saturation
filters = L3Get(L3,'globalfilter',[1, 1], 18, 2); % high response, W saturation

hfig = imagesc(reshape(filters(1, :)/max(filters(1, :)), r, c));
axis image
colormap(gray)
impixelregion(hfig); % display the filter with coefficients on top



