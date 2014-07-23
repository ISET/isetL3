clear, clc, close all

%% Start ISET
s_initISET

%% Create and initialize L3 structure
L3 = L3Create;
wave = [400:10:680]';
[sensor, optics] = fbCreate(wave');

oi = oiCreate;
oi = oiSet(oi,'optics',optics);
oi = oiSet(oi,'name','fb optics');

L3 = L3Initialize(L3, [], oi, sensor, []); 

%% Perform training
L3 = L3Train(L3);

%% Setup L3 camera
camera = L3CameraCreate(L3);

%% Save data
save('L3_fb', 'L3');
save('L3camera_fb', 'camera');
