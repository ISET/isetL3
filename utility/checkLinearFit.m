function [X, y_pred, y_true, fig] = checkLinearFit(l3t, thisClass,...
                         thisCenterPixel , thisSatCondition,thisChannel,...
                                            inCfa, upscaleFactor, varargin)
% Examine the accuracy of the kernel in its class, show the kernel weights
% and show what kind of the patches we are checking.
%
% Syntax:
%   [X, y_pred, y_true, fig] = checkLinearFit(l3t, thisClass,...
%                    thisCenterPixel , thisChannel, inCfa, varargin)
%
% Brief description:
%   
% Inputs:
%
% Outputs:
%
% Zheng Lyu, Brian Wandell, Stanford SCIEN Team, 2019
%
% See also:
%

%%
if ~isempty(varargin), outCfa = varargin{1}; end
if length(varargin) >=2, trainClass = varargin{2}; end
[rInCfa, cInCfa] = size(inCfa);
nInPType = numel(inCfa); 
inPixelPat = reshape([1:nInPType], size(inCfa));
if exist('outCfa', 'var')
    nOutPType = numel(outCfa);
    [rOutCfa, cOutCfa] = size(outCfa);
    outPixelPat = reshape([1:nOutPType], size(outCfa));
end

%%
patchSz = l3t.l3c.patchSize; rPatch = patchSz(1); cPatch = patchSz(2);

if ~exist('trainClass', 'var')

    nPixelTypes = l3t.l3c.nPixelTypes; 
    allSignalMean = length(l3t.l3c.cutPoints{1}) + 1;
    trainClass = (thisSatCondition-1)*nPixelTypes*allSignalMean+...
                    (thisClass - 1)*nPixelTypes+...
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
title(sprintf('Accuracy: class %d, channel %d',thisClass,thisChannel));

% The kernel weights
subplot(2,1,2);
imagesc(...
    reshape(l3t.kernels{trainClass}(2:end,thisChannel),...
    patchSz));
xlabel('hi')
colormap(gray); axis off %colorbar;
title(sprintf('Kernel weights: class %d, channel %d',thisClass,thisChannel));


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
if upscaleFactor > 1,
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