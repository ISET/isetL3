%% s_SPIEFigure5
%
% This script shows the learned linear operators for low, medium and high
% response levels for RGBW CFA for SPIE2013 paper figure 5.  These Global
% filter reflects the general principle of L3
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Make sure you have trained the three relevant cameras

% s_L3TrainCamerasforCFAs trains the CFA in selectedCFAList
% This will work as long as we don't change the published CFAs.
% A better method would be preferred.

cFile = fullfile(L3rootpath,'cameras','L3','L3camera_RGBW1.mat');
if ~exist(cFile,'file')
    fprintf('Training %s\n',cFile)
    selectedCFAList = 19;
    s_L3TrainCamerasforCFAs % train cameras for CFAs
end

cFile = fullfile(L3rootpath,'cameras','L3','L3camera_RGBW1.mat');
foo = load(cFile); camera = foo.camera;

%% Set up the learned camera parameters

L3 = cameraGet(camera, 'L3');
sz = L3Get(L3,'blocksize'); 
r = sz(1); 
c = sz(2);

%% The filter for the lowest response level
filters = L3Get(L3,'globalfilter',[1, 1], 1, 1); % low response, no saturation

vcNewGraphWin([],'tall');
subplot(3,1,1)
hfig = imagesc(reshape(filters(1, :)/max(filters(1, :)), r, c));
axis image
colormap(gray)
title('Lowest response level')

h = impixelregion(hfig); % display the filter with coefficients on top
set(h,'name','Lowest level coefficients')
set(h,'Units','normalized'); wPos = get(h,'Position');
set(h,'Position',[.25 .75 wPos(3) wPos(4)]);

%% The filter for the middle response level
filters = L3Get(L3,'globalfilter',[1, 1], 14, 1); % medium response, no saturation
subplot(3,1,2)
hfig = imagesc(reshape(filters(1, :)/max(filters(1, :)), r, c));
axis image
colormap(gray)
title('Middle response level')

h = impixelregion(hfig); % display the filter with coefficients on top
set(h,'name','Middle level coefficients')
set(h,'Units','normalized'); wPos = get(h,'Position');
set(h,'Position',[.25 .5 wPos(3) wPos(4)]);

%% The filter for the highest response level
filters = L3Get(L3,'globalfilter',[1, 1], 18, 2); % high response, W saturation

subplot(3,1,3)
hfig = imagesc(reshape(filters(1, :)/max(filters(1, :)), r, c));
axis image
colormap(gray)
title('Highest response level')

h = impixelregion(hfig); % display the filter with coefficients on top
set(h,'name','Highest level coefficients')
set(h,'Units','normalized'); wPos = get(h,'Position');
set(h,'Position',[.25 .25 wPos(3) wPos(4)]);

%% End
