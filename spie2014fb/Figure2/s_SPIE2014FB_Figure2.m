%% s_SPIE2014FB_Figure2
%
% This script calibrates the five band camera and shows the CFA layout and
% spectral responsitivities. 
%
% (c) Stanford VISTA Team 2014

clear, clc, close all

%% Initialize iset
s_initISET

%% Create five-band sensor and optics
L3 = L3Initialize();
scenes = L3Get(L3,'scene');
wave = sceneGet(scenes{1}, 'wave'); 
expIdx = 4; 
[sensor, optics] = fbCreate(wave', expIdx);

%%  Plot CFA layout and spectral curves
% Plot five band CFA block
[~, h1] = plotSensor(sensor, 'cfa block');
saveas(h1, fullfile(L3rootpath, 'spie2014fb', 'Figure2', 'spatiallayout.png')); % save figure

% Plot five band spectral filters 
[~, h2] = plotSensor(sensor, 'color filters');
hline = findobj(h2, 'type', 'line');
set(hline, 'LineWidth',3);
set(hline(2), 'Color', [1 0.6 0]);
haxes = findobj(h2, 'type', 'axes');
set(haxes, 'FontSize', 20)
htext = findall(h2, 'type', 'text');
set(htext, 'FontSize', 20);
saveas(h2, fullfile(L3rootpath, 'spie2014fb', 'Figure2', 'spectralresponsitivity.png')); % save figure

%% List sensor parameters
t1 = iePTable(sensor);
t2 = iePTable(optics);
