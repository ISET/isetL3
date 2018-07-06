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
[cattedDataTrain, cattedGrndtruthTrain] = l3c.concatenateClassData(idx);

%%
rdmIdx = randperm(size(cattedDataTrain, 1));

cattedDataTrain = cattedDataTrain(rdmIdx,:);
cattedGrndtruthTrain = cattedGrndtruthTrain(rdmIdx,:);


%% Validation data (same as the test data).
cattedDataVal = cattedDataTrain;
cattedGrndtruthVal = cattedGrndtruthTrain;

%% Save training dataset.
SAVE_FOLDER = '/Users/zhenglyu/Graduate/research/isetL3/dataset/';
SAVE_NAME = 'l3NeuralNetworkTraining';
trainImgSz = size(l3d.pType);
patchSz = l3c.patchSize;

fprintf('Saving the training data ...');
save(strcat(SAVE_FOLDER, SAVE_NAME), 'cattedDataTrain',...
                 'cattedGrndtruthTrain', 'trainImgSz','patchSz',...
                  '-v7.3');
fprintf('Done. \n')
%% Save validation dataset.

SAVE_FOLDER = '/Users/zhenglyu/Graduate/research/isetL3/dataset/';
SAVE_NAME = 'l3NeuralNetworkVal';
valImgSz = size(l3d.pType);

fprintf('Saving the validation data ...');
save(strcat(SAVE_FOLDER, SAVE_NAME), 'cattedDataVal',...
                 'cattedGrndtruthVal', 'valImgSz','patchSz',...
                  '-v7.3');
fprintf('Done. \n');