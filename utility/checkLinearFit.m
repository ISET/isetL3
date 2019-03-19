function [X, y_pred, y_true, fig] = checkLinearFit(l3t, thisLevel,...
    thisCenterPixel , thisSatCondition,thisChannel,...
    inCfa, upscaleFactor, varargin)
% Examine the accuracy of the kernel in its class
%
% Shows the kernel weights
% and show what kind of the patches we are checking.
%
% Syntax:
%   [X, y_pred, y_true, fig] = checkLinearFit(l3t, thisLevel,...
%                    thisCenterPixel , thisChannel, inCfa, varargin)
%
% Brief description:
%   
% Inputs:
%  l3t:   The training object that contains the relevant information
%  thisLevel:         The mean signal level of the patch
%  thisCenterPixel:   Which of the input CFA pixel types
%  thisSatCondition:  Which of the pixels are saturated in the patch
%  thisChannel:       Output channel.  By default, we expect the
%                     output and input channels to be the same.  But
%                     the outCFA might differ (see varargin, below).
%  inCfa
%  upScaleFactor
%
%  Optional varargin:
%     outCfa:     Defines the output CFA pattern.  Only used if the
%                 output CFA differs from the input.
%     trainClass: The kernel number (synonym for training class)  
%
% Outputs:
%   X:        The patch data for this class
%   y_pred    The prediction of the output
%   y_true    The ground truth (desired) output
%   fig:      The figure handle of the plot
% 
% Zheng Lyu, Brian Wandell, Stanford SCIEN Team, 2019
%
% See also:
%

%% Parse input parameters

if ~isempty(varargin),   outCfa     = varargin{1}; end
if length(varargin) >=2, trainClass = varargin{2}; end

% Converting the input CFA pattern numbers so that every position has
% a unique number.
[rInCfa, cInCfa] = size(inCfa);  % Used later
inPixelPat = reshape(1:numel(inCfa), size(inCfa));

if exist('outCfa', 'var')
    nOutPType = numel(outCfa);
    [rOutCfa, cOutCfa] = size(outCfa);
    outPixelPat = reshape([1:nOutPType], size(outCfa));
end

%% 
patchSz = l3t.l3c.patchSize; 
rPatch = patchSz(1); cPatch = patchSz(2);

if ~exist('trainClass', 'var')
    % trainClass is also called the kernel number in other places
    nPixelTypes = l3t.l3c.nPixelTypes;
    allSignalMean = length(l3t.l3c.cutPoints{1}) + 1;
    % We want a function that computes
    %   kernelNumber = l3t.nTrainClass(thisCenterPixel,thisLevel,thisSatCondition);
    %   [thisCenterPixel, thisLevel, thisSatCondition] =
    %           l3t.propertiesTrainClass(kernelNumber);
    %
    %  The calculation to get the 3-values from the kernel number is
    %  like this
    %     thisCenterPixel = mod(kernelNumber,nPixelTypes)
    %     remaining = kernelNumber - thisCenterPixel
    %     thisLevel = mod(remaining/nPixelTypes,allSignalMean) + 1;
    %     remaining = remaining - (thisLevel -1)*nPixelTypes;
    %     thisSatCondition = remaining/(pixelTypes*allSignalMean) + 1; 
    trainClass = (thisSatCondition-1)*nPixelTypes*allSignalMean + ...
        (thisLevel - 1)*nPixelTypes + ...
        thisCenterPixel;
end

%%
[X, y_true]  = l3t.l3c.getClassData(trainClass);
X = padarray(X, [0 1], 1, 'pre');
y_pred = X * l3t.kernels{trainClass};

fig = vcNewGraphWin([],'tall');

% Plot Accuracy
subplot(2,1,1)
plot(y_true(:,thisChannel), y_pred(:,thisChannel), 'o');
xlabel('Target value (ground truth)', 'FontSize', 15, 'FontWeight', 'bold');
ylabel('Predicted value', 'FontSize', 15,'FontWeight', 'bold');
axis square;
identityLine;
title(sprintf('Accuracy: class %d, channel %d',thisLevel,thisChannel));

% The kernel weights
subplot(2,1,2);
imagesc(...
    reshape(l3t.kernels{trainClass}(2:end,thisChannel),...
    patchSz));
xlabel('hi')
colormap(gray); axis off %colorbar;
title(sprintf('Kernel weights: class %d, channel %d',thisLevel,thisChannel));


%% Working on plot the pattern with the specified center and patch size

% Create the pixel type matrix
inPatchPattern = fitPatchPattern(patchSz, thisCenterPixel, inCfa);
inCFAPattern = zeros(size(inPatchPattern));
for rr = 1:rPatch
    for cc = 1:cPatch
        inCFAPattern(rr, cc) = inCfa(inPixelPat == inPatchPattern(rr, cc));
    end
end
%% Working on the same thing for output pattern if exist
if exist('outCfa', 'var')
    
    usOutCfa = repmat(outPixelPat, rInCfa/rOutCfa, cInCfa/cOutCfa);
    outCenterPixel = usOutCfa(inPixelPat == thisCenterPixel);
    outPatchPattern = fitPatchPattern(patchSz, outCenterPixel, outCfa);
    outCFAPattern = zeros(size(inPatchPattern));
    for rr = 1:rPatch
        for cc = 1:cPatch
            outCFAPattern(rr, cc) = outCfa(outPixelPat == outPatchPattern(rr, cc));
        end
    end
end

%% Plot the pattern
% Plot the quad pattern patch
sensor = sensorCreate; sensor = sensorSet(sensor, 'cfa Pattern', inCFAPattern);
sensorShowCFA(sensor);

% Plot the bayer pattern patch
if exist('outCfa', 'var')
    sensor = sensorSet(sensor, 'cfa Pattern',outCFAPattern);
    sensorShowCFA(sensor);
end

%% upscaling position & color channel plot
if upscaleFactor > 1
    A = reshape([1:power(upscaleFactor,2)], [upscaleFactor, upscaleFactor]);
    fprintf('Reference of the position order of upscaled block: \n');
    fprintf([repmat(' %d ', 1, upscaleFactor) '\n'], A')
    
    thisPosition = mod(thisChannel, power(upscaleFactor,2)); 
    if thisPosition==0, thisPosition = thisPosition + power(upscaleFactor,2); end
    fprintf('The position being checked is: %d.\n', thisPosition);
    
    thisColorChannel = ceil(thisChannel / power(upscaleFactor,2));
    colorList = sensorColorOrder;
    fprintf('The color channel being looked at is: %c.\n',...
                                    colorList{thisColorChannel});
end

end