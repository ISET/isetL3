% This tutorial is served as an example to confirm whether Universal
% Approximation is able to be used in our problem.
% 
% ZL/BW, VISTA TEAM, 2018
%%
ieInit;
%% l3d class data

% Creates a sample data set from four people
l3d = l3DataISET();

% We duplicate the images at multiple illumination levels and
% potentially using different relative spectral power distributions.
l3d.illuminantLev = [10 50 80];     % These are the luminance levels
l3d.inIlluminantSPD = {'D65'};      % These are the SPDs of the input and output
l3d.outIlluminantSPD = {'D65'};

%% Classify the data

% Make the classifier object
l3c = l3ClassifyFast();

% Set classifier parameters
l3c.cutPoints = {logspace(-1.7, -0.12, 30), []};
l3c.patchSize = [5 5];
l3c.dictChannel = ["g1", "r", "b", "g2", "w"];

% Compute the sensor data and put the patches into the classes. The
% p_data slot are the patch data from the camera The p_out slot are
% the ground truth data from the scene. 
%
% Each cell in p_data or p_out is a particular pixel type, and
% luminance level. So for an RGGB sensor there are hPixelTypes (4)
% types of pixels (because we count the greens separately).  In this
% case we have four different class centers (3 cut points makes 4
% classes).  So there are a total of 16 different cells.
%
% The L3 process finds a set of linear transforms between the
% corresponding p_data and p_out cells.  It would be nice to have
% another slot p_label{} that contained parameters that describe the
% cells.  For example
%   p_label{1}.pixelType = 'G2'
%   p_label{1}.lowerCut = ...
%   p_label{1}.upperCut = ...
l3c.classify(l3d);

%{
fName = fullfile(L3rootpath,'local','classified');
save(fName,'l3c')
%}

%% Another class to confirm the claim
%{
l3cChannel = l3ClassifyChannel();
l3cChannel.cutPoints = {logspace(-1.7, -0.12, 3), []};
l3cChannel.patchSize = [5 5];

l3cChannel.classify(l3d);
%}
%% Check the linearity for single class

classNumber = 80;
classPatch = (l3c.p_data{classNumber})';  % raw data for a class
classTgt   = (l3c.p_out{classNumber})';   % target data for the class

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
% checkLinearity(classPatch, classTgt);

% The numbers (by default) are annoyingly small.  So to make life
% easier scale them both to a max of 1.  Just helps diagnosing things.
tmp = ieScale(classTgt,1);
classTgtPatchNorm = tmp;

tmp = ieScale(classPatch,1);
classPatchNorm = tmp;

% tmp = max(classPatch{1});
% classPatchNorm{1} = classPatch{1} / tmp;
% 
% tmp = max(classTgt{1}, [], 1); 
% classTgtPatchNorm{1} = classTgt{1} ./ tmp;

checkLinearity(classPatchNorm, classTgtPatchNorm);

%{
maxTgt = max(classTgt{1}, [], 1);              % max target value for each channel
classTgtNorm{1} = classTgt{1} ./ maxTgt;          % Normalized target value
%}


%% Check the linearity for whole classes

% theseClasses = (1:l3c.nLabels);
first = 1; last = l3c.nLabels;
theseClasses = ((last-20):(last-5));
% Specify the pixel type that you want to merge as an additional
% argument to concatenateClassData.  People should not really want to
% merge red with green, for example.
[classWholeData, classWholeTgt] = l3c.concatenateClassData(theseClasses);
                   
checkLinearity(classWholeData, classWholeTgt);

% Check the linearity with target data w/ normalization
maxTgt = max(classWholeTgt, [], 1);              % max target value for each channel
classTgtNorm = classWholeTgt ./ maxTgt;          % Normalized target value

checkLinearity(classWholeData, classTgtNorm);

%% Check the linearity for one of the RGB channel
% Set the channel to be classified
thisChannel = "G1";
[classChannelData, classChannelTgt] = l3c.concatenateClassData(thisChannel);

% checkLinearity(classChannelData, classChannelTgt);

% Check the linearity with target data w/ normalization

tmp = ieScale(classChannelTgt,1);
classTgtNorm = tmp;

tmp = ieScale(classChannelData, 1);
classChannelNorm = tmp;

checkLinearity(classChannelNorm, classTgtNorm);
%% Take the single class as for UAT validation
% Training data
uatDataTrain = classPatchNorm;
uatGrndTrueTrain = classTgtPatchNorm;


% Validation data (same for the UAT validation)
uatDataVal = classPatchNorm;
uatGrndVal = classTgtPatchNorm;


%% Saving training data
SAVE_FOLDER = fullfile(L3rootpath,'local');
SAVE_NAME = '/l3UniversalApproxTrain_Channel80';
trainImgSz = size(l3d.pType);
patchSz = l3c.patchSize;

fprintf('Saving the training data ...');
save(strcat(SAVE_FOLDER, SAVE_NAME), 'uatDataTrain',...
                 'uatGrndTrueTrain', 'trainImgSz','patchSz',...
                  '-v7.3');
fprintf('Done. \n')

%% Saving again for the tesing data
SAVE_FOLDER = '/Users/zhenglyu/Graduate/research/isetL3/local/';
SAVE_NAME = 'l3UniversalApproxVAl_Channel80';
valImgSz = size(l3d.pType);

fprintf('Saving the validation data ...');
save(strcat(SAVE_FOLDER, SAVE_NAME), 'uatDataVal',...
                 'uatGrndVal', 'valImgSz','patchSz',...
                  '-v7.3');
fprintf('Done. \n');
