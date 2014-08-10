%% s_SPIE2014FB_Figure2
%
% This script calibrates the five band camera and shows the CFA layout and
% spectral curves. 
%
% (c) Stanford VISTA Team 2014

clear, clc, close all

%% Initialize iset
s_initISET

%% Load camera
load('L3camera_fb_D652D65.mat');
sensor = cameraGet(camera, 'sensor');

%%  Plot CFA layout and spectral curves
% Plot five band CFA block
[~, h1] = plotSensor(sensor, 'cfa block');
saveas(h1, 'cfablock.png'); % save figure

% Plot five band spectral filters 
[~, h2] = plotSensor(sensor, 'color filters');
hline = findobj(h2, 'type', 'line');
set(hline, 'LineWidth',3);
set(hline(2), 'Color', [1 0.6 0]);
haxes = findobj(h2, 'type', 'axes');
set(haxes, 'FontSize', 20)
htext = findall(h2, 'type', 'text');
set(htext, 'FontSize', 20);
saveas(h2, 'colorfilters.png'); % save figure

%% List sensor parameters
h3 = cameraListParameters(camera);
saveas(h3, 'cameraparameters.png'); % save figure
