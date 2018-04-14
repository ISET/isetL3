%% Learn from sensor to sensor
% Quad Bayer filter
%
% https://www.gsmarena.com/explaining_huawei_p20_pros_triple_camera-news-30497.php
%
% An analysis of a quad sensor
%
% Wandell


%%
remoteDirectory = '/resources/scenes/multiband/yasuma';
scenes = rdtScenesLoad('nscenes',[7 9], ...
    'remote directory', remoteDirectory, ...
    'print',false);
%%
scene = scenes{2};
ieAddObject(scene); sceneWindow;

%%
oi = oiCreate;
oi = oiCompute(oi,scene);
ieAddObject(oi); oiWindow;

%%
sensor = sensorCreate;

quadPattern = ...
    [3 3 2 2; ...
    3 3 2 2; ...
    2 2 1 1; ...
    2 2 1 1];

sensor = sensorSet(sensor,'pattern',quadPattern);
sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'));
sensor = sensorSet(sensor,'pixel size constant fill factor',1.4e-6);
sensor = sensorCompute(sensor,oi);
SHORT = sensorGet(sensor,'exp time');
ieAddObject(sensor); sensorWindow;
%%
LONG = 2*SHORT;
eTimes = [SHORT LONG SHORT LONG; 
    LONG SHORT LONG SHORT;
    SHORT LONG SHORT LONG; 
    LONG SHORT LONG SHORT];

sensor = sensorSet(sensor,'exp time',eTimes);

%%
camera = cameraCreate;
camera = cameraSet(camera,'oi',oi);
camera = cameraSet(camera,'sensor',sensor);
camera = cameraCompute(camera,scene);
cameraWindow(camera,'sensor');

%%
camera = cameraCompute(camera,scene);
cameraWindow(camera,'sensor');

%%
