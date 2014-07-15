clear, clc, close all

%% Start ISET
s_initISET

%% Create and initialize L3 structure
L3 = L3Create;
wave = [400:10:680]';
[sensor, optics] = fbCreate(wave');
L3 = L3Initialize(L3, [], optics, sensor, []); 

%% Change luminance list
sensorD = L3Get(L3, 'design sensor');
volswing = sensorGet(sensorD, 'voltage swing');
lumlist = linspace(0.01, 0.99*volswing, 10);
L3 = L3Set(L3, 'luminance list', lumlist);

%% Perform training
L3 = L3Train(L3);

%% Setup L3 camera
camera = L3CameraCreate(L3);

%% Save data
save('L3_fb', 'L3');
save('L3camera_fb', 'camera');
