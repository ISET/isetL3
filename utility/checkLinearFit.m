function [X, y_pred, y_true, fig] = checkLinearFit(l3t, thisClass, thisCenterPixel , thisChannel, inCfa, varargin)
% Examine the accuracy of the kernel in its class, and show the kernel weights
%
% Syntax:
%
% Brief description:
%
% Inputs:
%
% Outputs:
%
% Zheng Lyu, SCIEN Team, 2019
%
% See also:
%

% Examples:
%{
    % Exam the linearity of the kernels
    thisClass = 400; 
    
    [X, y_true]  = l3t.l3c.getClassData(thisClass);
    X = padarray(X, [0 1], 1, 'pre');
    y_pred = X * l3t.kernels{thisClass};
    thisChannel = 1;
    vcNewGraphWin; plot(y_true(:,thisChannel), y_pred(:,thisChannel), 'o');
    xlabel('Target value (ground truth)', 'FontSize', 15, 'FontWeight', 'bold');
    ylabel('Predicted value', 'FontSize', 15,'FontWeight', 'bold');
%     title(['Target value vs Predicted value for: class ', num2str(thisClass),...
%                         ' channel ' num2str(thisChannel)], 'FontWeight', 'bold');
    axis square;
    identityLine;
    vcNewGraphWin; imagesc(reshape(l3t.kernels{thisClass}(2:26,thisChannel),...
            [5, 5]));  colormap(gray);axis off %colorbar;
%}

%% Parse arguments

%%
if ~isempty(varargin) outCfa = varargin{1}; end
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
trainClass = (thisClass-1) * l3t.l3c.nPixelTypes + thisCenterPixel;

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
title(sprintf('Accuracy: class %d, channel %d',trainClass,thisChannel));

% The kernel weights
subplot(2,1,2);
imagesc(...
    reshape(l3t.kernels{thisClass}(2:end,thisChannel),...
    patchSz));
colormap(gray); axis off %colorbar;
title(sprintf('Kernel weights: class %d, channel %d',thisClass,thisChannel));

%% working on plot the pattern with the specified center and patch size

% Create the pixel type matrix
inPatchPattern = fitPatchPattern(patchSz, thisCenterPixel, inCfa);
inCFAPattern = zeros(size(inPatchPattern));
for rr = 1:rPatch
    for cc = 1:cPatch
        inCFAPattern(rr, cc) = inCfa(inPixelPat == inPatchPattern(rr, cc));
    end
end
%% working on the same thing for output pattern if exist
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

% Pllt the bayer pattern patch
sensor = sensorSet(sensor, 'cfa Pattern',outCFAPattern);
sensorShowCFA(sensor);
end