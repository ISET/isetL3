%% Learn from sensor to sensor
% Quad Bayer filter
%
% https://www.gsmarena.com/explaining_huawei_p20_pros_triple_camera-news-30497.php
%
% Public description of the format of the Huawei sensor
%
% Wandell


%%
rd = RdtClient('isetbio');
rd.crp('/resources/scenes/multiband/yasuma');
a = rd.listArtifacts('print',true);
%%
data = rd.readArtifact(a(1));
scene = data.scene;
ieAddObject(scene); sceneWindow;

%%
oi = oiCreate;
oi = oiCompute(oi,scene);
ieAddObject(oi); oiWindow;

sensor = sensorCreate;

quadPattern = ...
    [3 3 2 2; ...
    3 3 2 2; ...
    2 2 1 1; ...
    2 2 1 1];

sensor = sensorSet(sensor,'pattern',quadPattern);
sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'));
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor); sensorWindow;

camera = cameraCreate;
camera = cameraSet(camera,'oi',oi);
camera = cameraSet(camera,'sensor',sensor);
camera = cameraCompute(camera,scene);
cameraWindow(camera,'sensor');

%%
data = rd.readArtifact(a(1));
scene = data.scene;
camera = cameraCompute(camera,scene);
cameraWindow(camera,'sensor');


