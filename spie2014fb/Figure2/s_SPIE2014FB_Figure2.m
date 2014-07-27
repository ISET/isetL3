%% s_SPIE2014FB_Figure2
%
% This script calibrates the five band camera and shows the CFA layout and
% spectral curves. 
%
% (c) Stanford VISTA Team
clear, clc, close all
%% Initialize iset
s_initISET

%% Load pre-trained camera
load('L3camera_fb.mat');

%%  Plot CFA layout and spectral curves
% Plot five band CFA block
[~, h1] = plotSensor(camera.sensor, 'cfa block');
saveas(h1, 'cfablock.png'); % save figure

% Plot five band spectral filters 
[~, h2] = plotSensor(camera.sensor,'color filters');
hline = findobj(h2, 'type', 'line');
set(hline, 'LineWidth',3);
set(hline(2), 'Color', [1 0.6 0]);
haxes = findobj(h2, 'type', 'axes');
set(haxes, 'FontSize', 20)
htext = findall(h2, 'type', 'text');
set(htext, 'FontSize', 20);
saveas(h2, 'colorfilters.png'); % save figure
