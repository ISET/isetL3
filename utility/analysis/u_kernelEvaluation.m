function mse = u_kernelEvaluation(l3t)
% Evaluate the linearity of the learned kernels(filters). Calculate the mean
% squared error for each class and plot the predicted pixel value and
% groundtruth pixel value.
%% Get the kernels, input data and the ground truth pixel values.
kernels = l3t.kernels;
% kernels = cell(1, 4);
% kernels{1} = l3t.kernels{5}; kernels{2} = l3t.kernels{6};
% kernels{3} = l3t.kernels{7}; kernels{4} = l3t.kernels{8};
l3c = l3t.l3c;
patchSz = l3c.patchSize;
nClass = numel(kernels);

%% Calculate the row and the column of the plot
row = floor(sqrt(nClass));
col = floor(nClass / row);
rowPlot = [1:1:row];
colPlot = [1:1:col];
nPlot = numel(rowPlot) * numel(colPlot);

classPlot = zeros(1, numel(rowPlot) * numel(colPlot));
for rr = 1 : numel(rowPlot)
    for cc = 1 : numel(colPlot)
        classPlot((rr - 1) * numel(colPlot) + cc) = (rowPlot(rr) - 1) * col + colPlot(cc);
    end
end


%%
mse = zeros(nClass, size(kernels{2},2));

%% Plot the linearity check and the kernel

for rr = 1 : numel(rowPlot)
    for cc = 1 : numel(colPlot)
        
        thisClass = (rowPlot(rr) - 1) * col + colPlot(cc);
        thisPlot = (rr - 1) * numel(colPlot) + cc;
        [X, y_true]  = l3c.getClassData(thisClass);
        X = padarray(X, [0 1], 1, 'pre');
        y_pred = double(X * kernels{thisClass});
        
        for thisChannel = 1 : size(kernels{2}, 2)
            y_trueThisChannel = y_true(:,thisChannel);
            y_predThisChannel = y_pred(:,thisChannel);
            
            mse(thisClass, thisChannel) = immse(y_predThisChannel/max(y_trueThisChannel), y_trueThisChannel/max(y_trueThisChannel));
            
            vcNewGraphWin(figure(thisChannel));
            
            subplot(numel(rowPlot), numel(colPlot), thisPlot);
            plot(y_trueThisChannel, y_predThisChannel, 'o');
            title(['Channel: ', num2str(thisChannel), ' Class: ', num2str(thisClass)]);
            %xlabel('Target value', 'FontSize', 5, 'FontWeight', 'bold');
            %ylabel('Predicted value', 'FontSize', 5,'FontWeight', 'bold');
            ylim([0, inf]);
            xlim([0, inf]);
            axis square;
            identityLine;
            
            vcNewGraphWin(figure(thisChannel + size(kernels{2}, 2)));
            subplot(numel(rowPlot), numel(colPlot), thisPlot);
            imagesc(reshape(kernels{thisClass}(2:end,thisChannel),...
            patchSz));  colormap(gray);axis off   
            title(['Channel: ', num2str(thisChannel), ' Class: ', num2str(thisClass)]);
        end
        
%         if ((rr - 1) * numel(colPlot) + cc == nPlot || (rowPlot(rr) - 1) * col + colPlot(cc) > nClass) % Return when finished the plot
        if(rr == numel(rowPlot) && cc == numel(colPlot))
            vcNewGraphWin(figure(2 * size(kernels{2}, 2) + 1));
            for ii = 1 : size(kernels{2}, 2)
                subplot(1, size(kernels{2}, 2), ii);
                plot(classPlot, mse(mse(:, ii) ~= 0, ii), '-o');
                title('Mean Squared Error')
            end
            
            
            % plot the max mse and min mse sample
            
            
            for thisChannel = 1 : size(kernels{2}, 2)
                vcNewGraphWin(figure(2 * size(kernels{2}, 2) + 2));
                thisClassMax = find(mse(:, thisChannel) == max(mse(:, thisChannel)));
                subplot(2, size(kernels{2}, 2), thisChannel);
                [y_trueThisChannel, y_predThisChannel] = u_getPredTruePair(l3t, thisClassMax, thisChannel);
                plot(y_trueThisChannel, y_predThisChannel,'o');
                title(['Channel:', num2str(thisChannel), ' MSE=',...
                                    num2str(max(mse(:, thisChannel)))]);
                axis square;
                identityLine;
                                
                subplot(2, size(kernels{2}, 2), thisChannel + size(kernels{2}, 2));
                imagesc(reshape(kernels{thisClassMax}(2:end,thisChannel),...
                    patchSz));  colormap(gray);axis off
                title(['Class: ', num2str(thisClassMax)]);
                
                vcNewGraphWin(figure(2 * size(kernels{2}, 2) + 3));
                thisClassMin = find(mse(:, thisChannel) == min(mse((mse(:, thisChannel) ~= 0), thisChannel)));
                subplot(2, size(kernels{2}, 2), thisChannel);
                [y_trueThisChannel, y_predThisChannel] = u_getPredTruePair(l3t, thisClassMin, thisChannel);
                plot(y_trueThisChannel, y_predThisChannel,'o');
                title(['Channel:', num2str(thisChannel), ' MSE=',...
                       num2str(min(mse((mse(:, thisChannel) ~= 0), thisChannel)))]);
                axis square;
                identityLine;
                
                subplot(2, size(kernels{2}, 2), thisChannel + size(kernels{2}, 2));
                imagesc(reshape(kernels{thisClassMin}(2:end,thisChannel),...
                    patchSz));  colormap(gray);axis off
                title(['Class: ', num2str(thisClassMin)]);
            end
            
            return;
        end
    end
end

end