%% t_L3Quadra2Bayer
% 

%% init
ieInit;

%%
patch_sz = [5 5];
%% load the data
dataPath = '/home/zhenglyu/Research/isetL3/local/';
dataName = 'huaweiSensorParm.mat';

cameraData = load(strcat(dataPath, dataName));

%% load the scene
scenePath = '/scratch/ZhengLyu/sampleDataSet/scene';
format = 'mat';

scenes = loadScenes(scenePath, format, [1 3]);

%% Create the camera with bayer pattern
cameraBayer = cameraCreate;

cameraBayer = cameraSet(cameraBayer,'sensor', sensorCreateHWBayer);
cameraBayer = cameraSet(cameraBayer, 'sensor name', 'Bayer pattern Huawei');
cameraBayer = huaWeiSetup(cameraBayer, cameraData);

%% Exam if the parameter works properly with the huawei sensor properties
sampleScene = scenes{2};
sampleScene = sceneAdjustLuminance(sampleScene, 0.05);
sampleScene = sceneSet(sampleScene, 'fov', 15);
sampleScene = sceneSet(sampleScene, 'distance', 1);
ieAddObject(sampleScene);
sceneWindow();

cameraBayer = cameraCompute(cameraBayer, sampleScene);
sensor = cameraGet(cameraBayer, 'sensor');
ieAddObject(sensor);
sensorWindow;

img = cameraGet(cameraBayer,'ip');
ieAddObject(img);
ipWindow;

%% Now Create thcameraBayer = cameraCreate;
cameraQuad = cameraCreate;

cameraQuad = cameraSet(cameraQuad,'sensor', sensorCreateQuad);
cameraQuad = cameraSet(cameraQuad, 'sensor name', 'Quadra pattern Huawei');
cameraQuad = huaWeiSetup(cameraQuad, cameraData);

%% Generate the raw data for the quadra pattern and the bayer pattern

rawDataBayer = cell(1, length(scenes));
rawDataQuad  = cell(1, length(scenes));

for ii = 1 : length(scenes)
% Adjust the scene parameter
curScene = scenes{ii};
curScene = sceneAdjustLuminance(curScene, 20);
curScene = sceneSet(curScene, 'fov', 5);
curScene = sceneSet(curScene, 'distance', 1);
    
% raw data for quadra pattern
    rawDataQuad{ii}  = cameraGet(cameraCompute(cameraQuad, curScene),...
                                                        'sensor volts');
    rawDataBayer{ii} = cameraGet(cameraCompute(cameraBayer, curScene),...
                                                        'sensor volts');                             
%     rawDataRaw{ii} = rawDataRaw{ii}(1:sz(1), 1:sz(2));                                                
end

%% Training
% create training class instance
l3t = l3TrainRidge();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.satClassOption = 'none';
l3t.l3c.cutPoints = {logspace(-2.5, -0.8, 30), []};
l3dRaw = l3DataCamera(rawDataQuad, rawDataBayer,...
                      cameraGet(cameraQuad, 'sensor cfa pattern'));

% Invoke the training algorithm
l3t.train(l3dRaw);

%% 
l3r = l3Render();

rawBayerTest = l3r.render(rawDataQuad{2}, cameraGet(cameraQuad, 'sensor cfa pattern'), l3t);

vcNewGraphWin; imshow(rawBayerTest); title('Rendered raw data');

sensorTest = sensorSet(sensorCreate, 'volts', rawBayerTest);

ieAddObject(sensorTest);
sensorWindow;

sensorComp = sensorSet(sensorCreate, 'volts', rawDataBayer{2});
ieAddObject(sensorComp);
sensorWindow;

max(max(abs(rawBayerTest - rawDataBayer{2}(3:end - 2, 3:end - 2))))

