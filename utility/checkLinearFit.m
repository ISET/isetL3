function checkLinearFit(l3t, thisClass, thisChannel, patchSz)
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
%%
% Exam the linearity of the kernels 
    
    [X, y_true]  = l3t.l3c.getClassData(thisClass);
    X = padarray(X, [0 1], 1, 'pre');
    y_pred = X * l3t.kernels{thisClass};
    vcNewGraphWin; plot(y_true(:,thisChannel), y_pred(:,thisChannel), 'o');
    xlabel('Target value (ground truth)', 'FontSize', 15, 'FontWeight', 'bold');
    ylabel('Predicted value', 'FontSize', 15,'FontWeight', 'bold');
%     title(['Target value vs Predicted value for: class ', num2str(thisClass),...
%                         ' channel ' num2str(thisChannel)], 'FontWeight', 'bold');
    axis square;
    identityLine;
%     vcNewGraphWin; imagesc(reshape(l3t.kernels{thisClass}(end - prod(patchSz) + 1:end,thisChannel),...
%             patchSz));  colormap(gray);axis off %colorbar;
    vcNewGraphWin; imagesc(reshape(l3t.kernels{thisClass}(1:end - 1,thisChannel),...
            patchSz));  colormap(gray);axis off %colorbar;

end