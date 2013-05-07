%% t_camera
%
% Illustrate how to create or load a camera and then evaluate it with some
% metrics.
%
% 
%
% Make sure that ISET and L3 are both on your path
%

%% Here is an example camera
tmp = load(fullfile(L3rootpath,'Cameras','basic_1strun','basiccamera_Bayer.mat'));
bayerCamera = tmp.camera;
clear tmp

%% Run the vSNR metric on this camera

vsnrMetric = metricsCamera(bayerCamera,'vsnr');
