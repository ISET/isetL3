function checkLinearity(classPatch, classTgt)
% Check the linear relationship between the raw sensor and ground truth data
%
%    checkLinearity(classPatch, classTgt)
%
% Description
%  Create several plots evaluating the linearity between the sensor
%  data and the ground truth for a particular class.  The linearity is
%  evaluated using either (a) Least-squares solution (LSS), or MATLAB
%  LinearModel Class. 
%
% Inputs
%   classPatch  - Raw data for a classp.parse(rawData, patchSz, format, varargin{:});
%   classTgt    - Target data for the class
% 
% Outputs
%   None
%
% Programming Note
% When we can do something without an extra toolbox, that is better.
% Not everybody has all the toolboxes.
%
% ZL/BW, 2018
%
% See also
%

% Examples:
%{

%}

%% init input parser
p = inputParser;

p.addRequired('classPatch', @ismatrix);
p.addRequired('classTgt', @ismatrix);

p.parse(classPatch, classTgt);

classPatch  = p.Results.classPatch;
classTgt    = p.Results.classTgt;


%% Loop through the classPatch


% Set the index for training and validation
nSample = size(classPatch, 1);              % Total number of samples
nTrain = floor(nSample * 0.9);                  % Number of the samples used for 
                                                % linear regression
nVal = nSample - nTrain;                        % Samples used for validation.

indexTrain = randperm(nSample, nTrain);
indexVal = setdiff([1:nSample], indexTrain);
%% Linear regression by uisng Least-squares solution (LSS)
[kernels, ~, lssmse] = lscov(classPatch(indexTrain, :), classTgt(indexTrain, :));
lssResidual = classPatch * kernels - classTgt;

% Analysis
lssRMSE = sqrt(lssmse);

% Check the LSS residual
absLssResidual = abs(lssResidual);
relLssResidual = absLssResidual ./ classTgt * 100;

%% Plot the results,showing the residual
Channels = ['X', 'Y', 'Z'];

vcNewGraphWin;
whichChannel = 1;
input = classPatch;
predicted = input*kernels(:,whichChannel);  % First channel prediction
measured  = classTgt(:,whichChannel);
plot(measured(:),predicted(:),'.');
grid on; xlabel('Measured'); ylabel('Predicted');
identityLine;

vcNewGraphWin;
imagesc(reshape(kernels(:,whichChannel),5,5))
colormap(gray); axis image; colorbar;

%{
% suptitle(['Error for least-squares solution for class: ', num2str(classNumber)])
for jj = 1 : 3
    subplot(1, 3, jj)
    title(['Channel: ', Channels(jj)]);
    xlabel('Sample')
    yyaxis left
    plot([1:nSample], absLssResidual(:, jj));
    ylabel('Absolute error');
    hold on;
    plot([1:nSample], ones(1, nSample) * lssRMSE(jj), '-k'); % Plot root of the variance
    yyaxis right
    plot([1:nSample], relLssResidual(:,jj));
    hold on;
    plot(ones(1,100) * (nTrain + 1), linspace(0,max(relLssResidual(:, jj))...
                    , 100),'-k'); % Plot the boundary of the training and the val data
    ylabel('Relative error / %');

    nTrainLessRMSE = sum(lssResidual(indexTrain,jj) < lssRMSE(jj));
    nValLessRMSE = sum(lssResidual(indexVal,jj) < lssRMSE(jj));
    ratioTrainLess = nTrainLessRMSE / nTrain;
    ratioValLess = nValLessRMSE / nVal;
    fprintf('Train samples with error smaller than RMSE for Channel %s: %i / %i, (%.2f)\n', Channels(jj), nTrainLessRMSE, nTrain, ratioTrainLess * 100)
    fprintf('Val samples with error smaller than RMSE for Channel %s: %i / %i, (%.2f) \n\n', Channels(jj), nValLessRMSE, nVal, ratioValLess * 100)
end
%}


%% Linear regression by using LinearModel class in MATLAB
linearModelCh1 = fitlm(classPatch(indexTrain,:), classTgt(indexTrain,1), 'linear');
wb1 = linearModelCh1.Coefficients.Estimate;
w1 = wb1(2:end, 1);
b1 = ones(size(classPatch, 1), 1) * wb1(1, 1);
lmRMSECh1 = linearModelCh1.RMSE;

linearModelCh2 = fitlm(classPatch(indexTrain,:), classTgt(indexTrain,2), 'linear');
wb2 = linearModelCh2.Coefficients.Estimate;
w2 = wb2(2:end, 1);
b2 = ones(size(classPatch, 1), 1) * wb2(1, 1);
lmRMSECh2 = linearModelCh2.RMSE;

linearModelCh3 = fitlm(classPatch(indexTrain, :), classTgt(indexTrain,3), 'linear');
wb3 = linearModelCh3.Coefficients.Estimate;
w3 = wb3(2:end, 1);
b3 = ones(size(classPatch, 1), 1) * wb3(1, 1);
lmRMSECh3 = linearModelCh3.RMSE;

w = [w1, w2, w3];
b = [b1, b2, b3];
lmRMSE = [lmRMSECh1, lmRMSECh2, lmRMSECh3];

classRegressLM = classPatch * w + b;
lmResidual = classTgt - classRegressLM;

% Analysis
absLMResidual = abs(lmResidual);
relLMResidual = absLMResidual ./ classTgt * 100;

vcNewGraphWin;
whichChannel = 1;
input = classPatch;
predicted = input*w(:,whichChannel) + b(:,whichChannel);  % First channel prediction
measured  = classTgt(:,whichChannel);
plot(measured(:),predicted(:),'.');
grid on; xlabel('Measured'); ylabel('Predicted');
identityLine;


fprintf('Analysing the result by using LinearModel Class: \n\n');
figure;
% suptitle(['Error for LinearModel class: ', num2str(classNumber)])
for jj = 1 : 3
    subplot(1, 3, jj)
    title(['Channel: ', Channels(jj)]);
    xlabel('Sample')
    yyaxis left
    plot([1:nSample], absLMResidual(:, jj));
    ylabel('Absolute error');
    hold on;
    plot([1:nSample], ones(1, nSample) * lmRMSE(jj), '-k'); % Plot root of the variance
    yyaxis right
    plot([1:nSample], relLMResidual(:,jj));

    hold on;
    plot(ones(1,100) * (nTrain + 1), linspace(0,max(relLMResidual(:, jj))...
                    , 100),'-k'); % Plot the boundary of the training and the val data
    ylabel('Relative error / %');


    nTrainLessRMSE = sum(lmResidual(indexTrain,jj) < lmRMSE(jj));
    nValLessRMSE = sum(lmResidual(indexVal,jj) < lmRMSE(jj));
    ratioTrainLess = nTrainLessRMSE / nTrain;
    ratioValLess = nValLessRMSE / nVal;
    fprintf('Train samples with error smaller than RMSE for Channel %s: %i / %i, (%.2f)\n', Channels(jj), nTrainLessRMSE, nTrain, ratioTrainLess * 100)
    fprintf('Val samples with error smaller than RMSE for Channel %s: %i / %i, (%.2f) \n\n', Channels(jj), nValLessRMSE, nVal, ratioValLess * 100)
end

end
