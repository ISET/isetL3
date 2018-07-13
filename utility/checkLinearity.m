function checkLinearity(classPatch, classTgt, nSample, nTrain, nVal, classNumber)
% This function is used to check the linearity relationship between the raw
% data from a class and the target data. In this function we used two
% method to check, one is the Least-squares solution (LSS), the other one
% is using MATLAB LinearModel Class.

% Inputs
%   classPatch          - Raw data for a classp.parse(rawData, patchSz, format, varargin{:});
%   classTgt            - Target data for the class
%   nSample             - Total number of samples
%   nTrain              - Number of the samples used for linear regression
%   nVal                - Samples used for validation. 
%   classNumber         - The number of the class that we are looking at
% 
% Outputs
%   None

%% init input parser
p = inputParser;

p.addRequired('classPatch', @ismatrix);
p.addRequired('classTgt', @ismatrix);
p.addRequired('nSample', @isnumeric);
p.addRequired('nTrain', @isnumeric);
p.addRequired('nVal', @isnumeric);
p.addRequired('classNumber', @isnumeric);

p.parse(classPatch, classTgt, nSample, nTrain, nVal, classNumber);

classPatch  = p.Results.classPatch;
classTgt    = p.Results.classTgt;
nSample     = p.Results.nSample;
nTrain      = p.Results.nTrain;
nVal        = p.Results.nVal;
classNumber = p.Results.classNumber;
%% Linear regression by uisng Least-squares solution (LSS)
[kernels, ~, lssmse] = lscov(classPatch(1:nTrain, :), classTgt(1:nTrain, :));
lssResidual = classPatch * kernels - classTgt;

% Analysis
lssRMSE = sqrt(lssmse);

% Check the LSS residual
absLssResidual = abs(lssResidual);
relLssResidual = absLssResidual ./ classTgt * 100;

%% Linear regression by using LinearModel class in MATLAB
linearModelCh1 = fitlm(classPatch(1:nTrain,:), classTgt(1:nTrain,1), 'linear');
wb1 = linearModelCh1.Coefficients.Estimate;
w1 = wb1(2:end, 1);
b1 = ones(size(classPatch, 1), 1) * wb1(1, 1);
lmRMSECh1 = linearModelCh1.RMSE;

linearModelCh2 = fitlm(classPatch(1:nTrain,:), classTgt(1:nTrain,2), 'linear');
wb2 = linearModelCh2.Coefficients.Estimate;
w2 = wb2(2:end, 1);
b2 = ones(size(classPatch, 1), 1) * wb2(1, 1);
lmRMSECh2 = linearModelCh2.RMSE;

linearModelCh3 = fitlm(classPatch(1:nTrain, :), classTgt(1:nTrain,3), 'linear');
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

%% Exam the result by showing the residual
Channels = ['X', 'Y', 'Z'];

%
fprintf('Analysing the result by using LSS: \n\n');
figure;
suptitle(['Error for least-squares solution for class: ', num2str(classNumber)])
for ii = 1 : 3
    subplot(1, 3, ii)
    title(['Channel: ', Channels(ii)]);
    xlabel('Sample')
    yyaxis left
    plot([1:nSample], absLssResidual(:, ii));
    ylabel('Absolute error');
    hold on;
    plot([1:nSample], ones(1, nSample) * lssRMSE(ii), '-k'); % Plot root of the variance
    yyaxis right
    plot([1:nSample], relLssResidual(:,ii));
    hold on;
    plot(ones(1,100) * (nTrain + 1), linspace(0,max(relLssResidual(:, ii))...
                    , 100),'-k'); % Plot the boundary of the training and the val data
    ylabel('Relative error / %');
    
    nTrainLessRMSE = sum(lssResidual(1:nTrain,ii) < lssRMSE(1));
    nValLessRMSE = sum(lssResidual(nTrain+1:end,1) < lssRMSE(1));
    ratioTrainLess = nTrainLessRMSE / nTrain;
    ratioValLess = nValLessRMSE / nVal;
    fprintf('Train samples with error smaller than RMSE for Channel %s: %i / %i, (%.2f)\n', Channels(ii), nTrainLessRMSE, nTrain, ratioTrainLess * 100)
    fprintf('Val samples with error smaller than RMSE for Channel %s: %i / %i, (%.2f) \n\n', Channels(ii), nValLessRMSE, nVal, ratioValLess * 100)
end


fprintf('Analysing the result by using LinearModel Class: \n\n');
figure;
suptitle(['Error for LinearModel class: ', num2str(classNumber)])
for ii = 1 : 3
    subplot(1, 3, ii)
    title(['Channel: ', Channels(ii)]);
    xlabel('Sample')
    yyaxis left
    plot([1:nSample], absLMResidual(:, ii));
    ylabel('Absolute error');
    hold on;
    plot([1:nSample], ones(1, nSample) * lmRMSE(ii), '-k'); % Plot root of the variance
    yyaxis right
    plot([1:nSample], relLMResidual(:,ii));
    
    hold on;
    plot(ones(1,100) * (nTrain + 1), linspace(0,max(relLMResidual(:, ii))...
                    , 100),'-k'); % Plot the boundary of the training and the val data
    ylabel('Relative error / %');
    
    
    nTrainLessRMSE = sum(lmResidual(1:nTrain,ii) < lmRMSE(1));
    nValLessRMSE = sum(lmResidual(nTrain+1:end,1) < lmRMSE(1));
    ratioTrainLess = nTrainLessRMSE / nTrain;
    ratioValLess = nValLessRMSE / nVal;
    fprintf('Train samples with error smaller than RMSE for Channel %s: %i / %i, (%.2f)\n', Channels(ii), nTrainLessRMSE, nTrain, ratioTrainLess * 100)
    fprintf('Val samples with error smaller than RMSE for Channel %s: %i / %i, (%.2f) \n\n', Channels(ii), nValLessRMSE, nVal, ratioValLess * 100)
end


end