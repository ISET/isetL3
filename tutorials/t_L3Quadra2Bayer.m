%% t_L3Quadra2Bayer
% 

%% init
ieInit;
 
%%
patch_sz = [7 7];
%% load the data
dataPath = fullfile(L3rootpath,'local/');
dataName = 'huaweiSensorParm.mat';

cameraData = load(strcat(dataPath, dataName));

%% load the scene
scenePath = '/scratch/ZhengLyu/sampleDataSet/scene';
format = 'mat';

scenes = loadScenes(scenePath, format, [3 5 6]);

%% Create the camera with bayer pattern
cameraBayer = cameraCreate;

cameraBayer = cameraSet(cameraBayer,'sensor', sensorCreateHWBayer);
cameraBayer = cameraSet(cameraBayer, 'sensor name', 'Bayer pattern Huawei');
cameraBayer = huaWeiSetup(cameraBayer, cameraData);

%% Exam if the parameter works properly with the huawei sensor properties
sampleScene = scenes{2};
sampleScene = sceneAdjustLuminance(sampleScene, 20);
sampleScene = sceneSet(sampleScene, 'fov', 5);
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

vciTmp = cameraGet(cameraBayer, 'vci');
ip = ipCompute(vciTmp, sensor);
ieAddObject(ip);
ipWindow;

%% Now Create thcameraBayer = cameraCreate;
cameraQuad = cameraCreate;

cameraQuad = cameraSet(cameraQuad,'sensor', sensorCreateQuad);
cameraQuad = cameraSet(cameraQuad, 'sensor name', 'Quadra pattern Huawei');
cameraQuad = huaWeiSetup(cameraQuad, cameraData);

%% Exam if the parameter works properly with the huawei sensor properties
sampleScene = scenes{2};
sampleScene = sceneAdjustLuminance(sampleScene, 20);
sampleScene = sceneSet(sampleScene, 'fov', 5);
sampleScene = sceneSet(sampleScene, 'distance', 1);
ieAddObject(sampleScene);
sceneWindow();

cameraQuad = cameraCompute(cameraQuad, sampleScene);
sensor = cameraGet(cameraQuad, 'sensor');
ieAddObject(sensor);
sensorWindow;

img = cameraGet(cameraQuad,'ip');
ieAddObject(img);
ipWindow;


%% Generate the raw data for the quadra pattern and the bayer pattern

rawDataBayer = cell(1, length(scenes));
rawDataQuad  = cell(1, length(scenes));
ilv = [10 20 15 25 5 40 50 80];
for ii = 1 : length(ilv)
% Adjust the scene parameter
curScene = scenes{2};
curScene = sceneAdjustLuminance(curScene, ilv(ii));
curScene = sceneSet(curScene, 'fov', 5.1);
curScene = sceneSet(curScene, 'distance', 1);
    
% raw data for quadra pattern
    rawDataQuad{ii}  = cameraGet(cameraCompute(cameraQuad, curScene),...
                                                        'sensor volts');
    rawDataBayer{ii} = cameraGet(cameraCompute(cameraBayer, curScene),...
                                                        'sensor volts');                             
                                                    
end

%{
% Check the sensor data
thisScene = 1;
curSensor = sensorCreate;
curSensor = sensorSet(curSensor, 'name', 'quad sensor data')
curSensor = sensorSet(curSensor, 'volts', rawDataQuad{thisScene});
ieAddObject(curSensor);
sensorWindow;

curSensor = sensorCreate;
curSensor = sensorSet(curSensor, 'name', 'Bayer sensor data')
curSensor = sensorSet(curSensor, 'volts', rawDataBayer{thisScene});
ieAddObject(curSensor);
sensorWindow;
%}

%% Training
% create training class instance
l3t = l3TrainRidge();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.satClassOption = 'none';
l3t.l3c.cutPoints = {logspace(-1.1, -1.0, 25), []};
% l3dRaw = l3DataCamera(rawDataQuad, rawDataBayer,...
%                       cameraGet(cameraQuad, 'sensor cfa pattern'));
l3dRaw = l3DataCamera(rawDataQuad, rawDataBayer,...
                      cameraGet(cameraQuad, 'sensor cfa pattern'));                  

% Invoke the training algorithm
l3t.train(l3dRaw);

%% Now check the linearity of the trained class
thisClass = 90;
thisChannel = 1;

checkLinearFit(l3t, thisClass, thisChannel, patch_sz);
%% 
l3r = l3Render();

rawBayerRender = l3r.render(rawDataQuad{2}, cameraGet(cameraQuad, 'sensor cfa pattern'), l3t);

curSensor = sensorCreate;
curSensor = sensorSet(curSensor, 'volts', rawBayerRender);
curSensor = sensorSet(curSensor, 'name', 'L3 rendered sensor data');
ieAddObject(curSensor);
sensorWindow;

curSensor = sensorCreate;
curSensor = sensorSet(curSensor, 'volts', rawDataBayer{1});
curSensor = sensorSet(curSensor, 'name', 'Bayer sensor data');
ieAddObject(curSensor);
sensorWindow;

% max(max(abs(rawBayerTest - rawDataBayer{2}(3:end - 2, 3:end - 2))))

%% Render a new image:
curScene = scenes{1};
curScene = sceneAdjustLuminance(curScene, 80);
curScene = sceneSet(curScene, 'fov', 5.1);
curScene = sceneSet(curScene, 'distance', 1);
rawDataBayerTest  = cameraGet(cameraCompute(cameraBayer, curScene),...
                                                        'sensor volts');
rawBayerRenderTest = l3r.render(rawDataBayerTest, cameraGet(cameraQuad,...
                                            'sensor cfa pattern'), l3t); 
curSensor = sensorCreate;
curSensor = sensorSet(curSensor, 'volts', rawBayerRenderTest);
curSensor = sensorSet(curSensor, 'name', 'L3 rendered sensor test data');
ieAddObject(curSensor);
sensorWindow;

curSensor = sensorCreate;
curSensor = sensorSet(curSensor, 'volts', rawDataBayerTest);
curSensor = sensorSet(curSensor, 'name', 'Bayer sensor test data');
ieAddObject(curSensor);
sensorWindow;                                        


%% Produce the camera ip
cameraBayerTest = cameraCreate;

cameraBayerTest = cameraSet(cameraBayerTest,'sensor', sensorCreateHWBayer);
cameraBayerTest = cameraSet(cameraBayerTest, 'sensor name', 'New Bayer pattern Huawei');
cameraBayerTest = huaWeiSetup(cameraBayerTest, cameraData);

curSensor = sensorCreate;
curSensor = sensorSet(curSensor, 'volts', rawBayerRenderTest);
curSensor = sensorSet(curSensor, 'name', 'L3 rendered sensor test data');
cameraBayerTest = cameraSet(cameraBayerTest, 'sensor', curSensor);
cameraBayerTest = cameraCompute(cameraBayerTest, 'sensor');
% Conduct the img processor
% vci = cameraGet(cameraBayer, 'vci');
% ieAddObject(vci);
% ipWindow;


