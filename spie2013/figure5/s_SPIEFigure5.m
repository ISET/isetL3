%% s_SPIEFigure5
%
% This script shows the learned linear operators for low, medium and high 
% response levels for RGBW CFA for SPIE2013 paper figure 5.  
% 
%
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Show linear operators
load(fullfile(L3rootpath,'cameras','L3','L3camera_RGBW1.mat')); % load the trained L3 camera
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



