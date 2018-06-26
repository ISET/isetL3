% This tutorial is used to try out the idea of using neural network as 
% substitution of L3. The goal for now is to generate the data which is 
% vectorized that can be DIRECTLY used for training. The training is tempora-
% rily done on python, so the goal for here is to save the data as .mat file.
% 
% ZL/BW, VISTA TEAM, 2015

%% Init
ieInit

%% l3Data class

% initate the class that store the data that used for training. The default 
% is to use scene data that are stored on the RemoteDataToolbox in /L3/faces.

l3d = l3DataISET();

%% Create block data and groundtruth
l3t = l3TrainCNN();

% set parameters
l3t.l3c.cutPoints = {logspace(-1.7, -0.12, 40), []};
l3t.l3c.patchSize = [5 5];

% Invoke the data creating process
l3t.buildclass(l3d);

idx = [1:l3t.l3c.nLabels];

[mergedData, mergedGroundtruth] = l3t.merge(idx);