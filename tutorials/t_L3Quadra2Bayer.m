%% t_L3Quadra2Bayer
% 

%% init
ieInit;
 
%% Define the patch size
patch_sz = [9 9];
%% load the data
dataPath = fullfile(L3rootpath,'local/');
dataName = 'huaweiSensorParm.mat';

cameraData = load(strcat(dataPath, dataName));

%% load the scene
scenePath = '/scratch/ZhengLyu/sampleDataSet/scene';
format = 'mat';

scenes = loadScenes(scenePath, format, [1 2 3 4 5]); % 1 4

%% Create the camera with bayer pattern
cameraBayer = cameraCreate;

cameraBayer = cameraSet(cameraBayer,'sensor', sensorCreateHWBayer);
cameraBayer = cameraSet(cameraBayer, 'sensor name', 'Bayer pattern Huawei');
cameraBayer = huaWeiSetup(cameraBayer, cameraData);

%% Exam if the parameter works properly with the huawei sensor properties
%{
sampleScene = scenes{1};
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
%}
%% Now Create thcameraBayer = cameraCreate;
cameraQuad = cameraCreate;

cameraQuad = cameraSet(cameraQuad,'sensor', sensorCreateQuad);
cameraQuad = cameraSet(cameraQuad, 'sensor name', 'Quadra pattern Huawei');
cameraQuad = huaWeiSetup(cameraQuad, cameraData);

%% Exam if the parameter works properly with the huawei sensor properties
%{
sampleScene = scenes{3};
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
%}

%% Generate the raw data for the quadra pattern and the bayer pattern

rawDataBayer = cell(1, length(scenes) - 2);
rawDataQuad  = cell(1, length(scenes) - 2);
ilv = [10 40 50];
for ii = 1 : length(scenes) - 2
    for jj = 1 : length(ilv)
        % Adjust the scene parameter
        curScene = scenes{ii};
        curScene = sceneAdjustLuminance(curScene, ilv(jj));
        curScene = sceneSet(curScene, 'fov', 5.1);
        curScene = sceneSet(curScene, 'distance', 1);

        % raw data for quadra pattern
        rawDataQuad{(ii - 1) * length(ilv) + jj}  = cameraGet(cameraCompute(cameraQuad, curScene),...
                                                            'sensor volts');
        rawDataBayer{(ii - 1) * length(ilv) + jj} = cameraGet(cameraCompute(cameraBayer, curScene),...
                                                            'sensor volts');                             
    end                                                    
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
l3t.l3c.cutPoints = {logspace(-1.1, -0.1, 10), []};
% l3dRaw = l3DataCamera(rawDataQuad, rawDataBayer,...
%                       cameraGet(cameraQuad, 'sensor cfa pattern'));
l3dRaw = l3DataCamera(rawDataQuad, rawDataBayer,...
                      cameraGet(cameraQuad, 'sensor cfa pattern'));                  

% Invoke the training algorithm
l3t.train(l3dRaw);

%% Now check the linearity of the trained class
thisClass = 96;
thisChannel = 1;
[X, y_pred, y_true] = checkLinearFit(l3t, thisClass, thisChannel, l3t.l3c.patchSize);
%% Evaluate the kernels
mse = u_kernelEvaluation(l3t);
%%
l3r = l3Render();
%% 
% l3r = l3Render();
% curScene = scenes{1};
% 
% rawBayerRender = l3r.render(rawDataQuad{1}, cameraGet(cameraQuad, 'sensor cfa pattern'), l3t);
% 
% curSensor = cameraGet(cameraBayer, 'sensor');
% curSensor = sensorSet(curSensor, 'volts', rawBayerRender);
% curSensor = sensorSet(curSensor, 'name', 'L3 rendered sensor data');
% ieAddObject(curSensor);
% sensorWindow;
% 
% curSensor = cameraGet(cameraBayer, 'sensor');
% curSensor = sensorSet(curSensor, 'volts', rawDataBayer{1});
% curSensor = sensorSet(curSensor, 'name', 'Bayer sensor data');
% ieAddObject(curSensor);
% sensorWindow;

% max(max(abs(rawBayerTest - rawDataBayer{2}(3:end - 2, 3:end - 2))))

%% Render a test image:
curScene = scenes{2};
ieAddObject(curScene);
% sceneWindow;
curScene = sceneAdjustLuminance(curScene, 20);
curScene = sceneSet(curScene, 'fov', 10);
curScene = sceneSet(curScene, 'distance', 1);
rawDataBayerTest  = cameraGet(cameraCompute(cameraQuad, curScene),...
                                                        'sensor volts');
                                                    
rawBayerRenderTest = l3r.render(rawDataBayerTest, cameraGet(cameraQuad,...
                                            'sensor cfa pattern'), l3t); 
% This is the sensor computed from bayer pattern.
bayerSensor = cameraGet(cameraCompute(cameraBayer, curScene), 'sensor');


% Give the value to a new sensor
l3Sensor = bayerSensor;
l3Sensor = sensorSet(l3Sensor, 'name', 'l rendered sensor');
l3Sensor = sensorSet(l3Sensor, 'volts', rawBayerRenderTest);
l3Sensor = sensorSet(l3Sensor, 'digital value', analog2digital(l3Sensor, 'linear'));
ieAddObject(l3Sensor);
% sensorWindow;

% ieAddObject(bayerSensor);
% sensorWindow;
bayerVolts = sensorGet(bayerSensor, 'volts');

% Conduct the img processor
ipFirst = ipCreate;
ipFirst = ipSet(ipFirst, 'name', 'bayer');
ipFirst = ipCompute(ipFirst, bayerSensor);
bayerImg = ipGet(ipFirst, 'data srgb');
ieAddObject(ipFirst);
ipWindow;

ipSecond = ipCreate;
ipSecond = ipSet(ipSecond, 'name', 'l');
ipSecond = ipCompute(ipSecond, l3Sensor);
l3Img = ipGet(ipSecond, 'data srgb');
% ieAddObject(ipSecond);
% ipWindow;

vcNewGraphWin;
subplot(2, 1, 1); imshow(bayerImg);
subplot(2, 1, 2); imshow(l3Img);

%% now render a new image
curScene = scenes{5};

ieAddObject(curScene);
% sceneWindow;
curScene = sceneAdjustLuminance(curScene, 10);
curScene = sceneSet(curScene, 'fov', 10);
curScene = sceneSet(curScene, 'distance', 1);
rawDataBayerTest  = cameraGet(cameraCompute(cameraQuad, curScene),...
                                                        'sensor volts');
                                                    
rawBayerRenderTest = l3r.render(rawDataBayerTest, cameraGet(cameraQuad,...
                                            'sensor cfa pattern'), l3t); 
% This is the sensor computed from bayer pattern.
bayerSensor = cameraGet(cameraCompute(cameraBayer, curScene), 'sensor');


% Give the value to a new sensor
l3Sensor = bayerSensor;
l3Sensor = sensorSet(l3Sensor, 'name', 'l rendered sensor');
l3Sensor = sensorSet(l3Sensor, 'volts', rawBayerRenderTest);
l3Sensor = sensorSet(l3Sensor, 'digital value', analog2digital(l3Sensor, 'linear'));
ieAddObject(l3Sensor);
% sensorWindow;

% ieAddObject(bayerSensor);
% sensorWindow;
bayerVolts = sensorGet(bayerSensor, 'volts');

% Conduct the img processor
ipFirst = ipCreate;
ipFirst = ipSet(ipFirst, 'name', 'bayer');
ipFirst = ipCompute(ipFirst, bayerSensor);
bayerImg = ipGet(ipFirst, 'data srgb');
ieAddObject(ipFirst);
ipWindow;

ipSecond = ipCreate;
ipSecond = ipSet(ipSecond, 'name', 'l');
ipSecond = ipCompute(ipSecond, l3Sensor);
l3Img = ipGet(ipSecond, 'data srgb');
% ieAddObject(ipSecond);
% ipWindow;

vcNewGraphWin;
subplot(2, 1, 1); imshow(bayerImg);
subplot(2, 1, 2); imshow(l3Img);