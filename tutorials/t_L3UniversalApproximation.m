% This tutorial is served as an example to confirm whether Universal
% Approximation is able to be used in our problem.
% 
% ZL/BW, VISTA TEAM, 2018
%% l3d class data
l3d = l3DataISET();

l3d.illuminantLev = [50 10 80];
l3d.inIlluminantSPD = {'D65'};
l3d.outIlluminantSPD = {'D65'};

%% Classify the data
l3c = l3ClassifyFast();

% set parameters
l3c.cutPoints = {logspace(-1.7, -0.12, 40), []};
l3c.patchSize = [5 5];

l3c.classify(l3d);

%% Take the single class as for UAT validation
% Training data
uatDataTrain = l3c.p_data{1};
uatGrndTrueTrain = l3c.p_out{1};


% Validation data (same for the UAT validation)
uatDataVal = uatTraining;
uatGrndVal = uatGrndTrueTrain;

%% Saving training data
SAVE_FOLDER = '/Users/zhenglyu/Graduate/research/isetL3/local/';
SAVE_NAME = 'l3UniversalApproxTrain';
trainImgSz = size(l3d.pType);
patchSz = l3c.patchSize;

fprintf('Saving the training data ...');
save(strcat(SAVE_FOLDER, SAVE_NAME), 'uatDataTrain',...
                 'uatGrndTrueTrain', 'trainImgSz','patchSz',...
                  '-v7.3');
fprintf('Done. \n')

%% Saving again for the tesing data
SAVE_FOLDER = '/Users/zhenglyu/Graduate/research/isetL3/local/';
SAVE_NAME = 'l3UniversalApproxVAl';
valImgSz = size(l3d.pType);

fprintf('Saving the validation data ...');
save(strcat(SAVE_FOLDER, SAVE_NAME), 'uatDataVal',...
                 'uatGrndVal', 'valImgSz','patchSz',...
                  '-v7.3');
fprintf('Done. \n');
