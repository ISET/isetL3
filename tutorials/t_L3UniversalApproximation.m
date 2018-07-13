% This tutorial is served as an example to confirm whether Universal
% Approximation is able to be used in our problem.
% 
% ZL/BW, VISTA TEAM, 2018
%%
ieInit;
%% l3d class data
l3d = l3DataISET();

l3d.illuminantLev = [50 10 80];
l3d.inIlluminantSPD = {'D65'};
l3d.outIlluminantSPD = {'D65'};

%% Classify the data
l3c = l3ClassifyFast();

% set parameters
l3c.cutPoints = {logspace(-1.7, -0.12, 30), []};
l3c.patchSize = [5 5];

l3c.classify(l3d);

%{
fName = fullfile(L3rootpath,'local','classified');
save(fName,'l3c')
%}
%% Check the linearity for single class

classNumber = 10;
classPatch = (l3c.p_data{classNumber})';    % raw data for a class
classTgt = (l3c.p_out{classNumber})';       % target data for the class
nSample = size(classPatch, 1);              % Total number of samples
nTrain = floor(nSample * 0.9);              % Number of the samples used for 
                                            % linear regression
nVal = nSample - nTrain;                    % Samples used for validation.                                            
%{
    rdmIdx = randi([1, nSample], 1, 25);
    example = ClassPatch(rdmIdx, :);
    tgt = ClassTgtNorm(rdmIdx,:);

    vcNewGraphWin([], 'wide');
    for ii = 1 : length(rdmIdx)
        subplot(5, 5, ii);
        imgCur = reshape(example(ii,:), [5, 5]);
        imagesc(imgCur); colormap(gray); colorbar;
    end

    vcNewGraphWin([], 'wide');
    for ii = 1 : length(rdmIdx)
        subplot(5, 5, ii);
        imgCur = tgt(ii,:);
        imagesc(imgCur); colorbar;
    end
%}

% Check the linearity with target data w/o normailization
checkLinearity(classPatch, classTgt, nSample, nTrain, nVal, classNumber);

% Check the linearity with target data w/ normalization
maxTgt = max(classTgt, [], 1);              % max target value for each channel
classTgtNorm = classTgt ./ maxTgt;          % Normalized target value

checkLinearity(classPatch, classTgtNorm, nSample, nTrain, nVal, classNumber);


%% Check the linearity for whole classes

% theseClasses = (1:l3c.nLabels);
first = 1; last = l3c.nLabels;
theseClasses = ((last-20):(last-5));
% Specify the pixel type that you want to merge as an additional
% argument to concatenateClassData.  People should not really want to
% merge red with green, for example.
[classWholeData, classWholeTgt] = l3c.concatenateClassData(theseClasses);
nSample = size(classWholeData, 1);              
nTrain = floor(nSample * 0.9);              
nVal = nSample - nTrain;                    
checkLinearity(classWholeData, classWholeTgt, nSample, nTrain, nVal, classNumber);

% Check the linearity with target data w/ normalization
maxTgt = max(classTgt, [], 1);              % max target value for each channel
classTgtNorm = classTgt ./ maxTgt;          % Normalized target value

checkLinearity(classPatch, classTgtNorm, nSample, nTrain, nVal, classNumber);
%% Take the single class as for UAT validation
% Training data
uatDataTrain = l3c.p_data{classNumber};
uatGrndTrueTrain = l3c.p_out{classNumber};


% Validation data (same for the UAT validation)
uatDataVal = uatDataTrain;
uatGrndVal = uatGrndTrueTrain;

%% Saving training data
SAVE_FOLDER = fullfile(L3rootpath,'local');
SAVE_NAME = 'l3UniversalApproxTrain_Class101';
trainImgSz = size(l3d.pType);
patchSz = l3c.patchSize;

fprintf('Saving the training data ...');
save(strcat(SAVE_FOLDER, SAVE_NAME), 'uatDataTrain',...
                 'uatGrndTrueTrain', 'trainImgSz','patchSz',...
                  '-v7.3');
fprintf('Done. \n')

%% Saving again for the tesing data
SAVE_FOLDER = '/Users/zhenglyu/Graduate/research/isetL3/local/';
SAVE_NAME = 'l3UniversalApproxVAl_Class101';
valImgSz = size(l3d.pType);

fprintf('Saving the validation data ...');
save(strcat(SAVE_FOLDER, SAVE_NAME), 'uatDataVal',...
                 'uatGrndVal', 'valImgSz','patchSz',...
                  '-v7.3');
fprintf('Done. \n');
