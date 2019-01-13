function [X, y_pred, y_true, fig] = checkLinearFit(l3t, thisClass, thisChannel, patchSz)
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

[X, y_true]  = l3t.l3c.getClassData(thisClass);
X = padarray(X, [0 1], 1, 'pre');
y_pred = X * l3t.kernels{thisClass};

fig = vcNewGraphWin([],'tall');

% Plot Accuracy
subplot(2,1,1)
plot(y_true(:,thisChannel), y_pred(:,thisChannel), 'o');
xlabel('Target value (ground truth)', 'FontSize', 15, 'FontWeight', 'bold');
ylabel('Predicted value', 'FontSize', 15,'FontWeight', 'bold');
axis square;
identityLine;
title(sprintf('Accuracy: class %d, channel %d',thisClass,thisChannel));

% Why is this here?  Is it an error that these variables are not used
% below?  Should these be thisClass and thisChannel? Or since they are sent
% in, is that all we need? For now, I commented it out.(BW) 
% [class, channel] = l3t.l3c.getClassChannelPType(thisClass);

% The kernel weights
subplot(2,1,2);
imagesc(...
    reshape(l3t.kernels{thisClass}(2:end,thisChannel),...
    patchSz));
colormap(gray); axis off %colorbar;
title(sprintf('Kernel weights: class %d, channel %d',thisClass,thisChannel));

end