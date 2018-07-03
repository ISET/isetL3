% This tutorial is used to try out the idea of using neural network as 
% substitution of L3. The goal for now is to generate the data which is 
% vectorized that can be DIRECTLY used for training. The training is tempora-
% rily done on python, so the goal for here is to save the data as .mat file.
% 
% ZL/BW, VISTA TEAM, 2018

%% Init
ieInit

%% l3Data class

% initate the class that store the data that used for training. The default 
% is to use scene data that are stored on the RemoteDataToolbox in /L3/faces.

l3d = l3DataISET();

l3d.illuminantLev = [50 10 80];
l3d.inIlluminantSPD = {'D65'};
l3d.outIlluminantSPD = {'D65'};

%% Classify data and groundtruth
l3c = l3ClassifyFast();

% set parameters
l3c.cutPoints = {logspace(-1.7, -0.12, 40), []};
l3c.patchSize = [5 5];

l3c.classify(l3d);

%% Newly added function called concatenate class data
idx = [1 : l3c.nLabels];
[mergedDataTrain, mergedGrndtruthTrain] = l3c.concatenateClassData(idx);


%% Generate data for training example after training
l3cTest = l3c.copy();

% Obtain the sensor mosaic response to a scene.  Could be any scene
scene = l3d.get('scenes', 1);

% Use isetcam to compute the camera data.
camera  = cameraCompute(l3d.camera, scene);
cfa     = cameraGet(l3d.camera, 'sensor cfa pattern');
cmosaic = cameraGet(camera, 'sensor volts');

l3dTest = l3DataCamera({cmosaic}, {}, cfa);
pType = l3dTest.pType;

% Calculate the 
l3cTest.classify(l3dTest);

[mergedDataTest, mergedGrndtruthTest] = l3cTest.concatenateClassData(idx);



