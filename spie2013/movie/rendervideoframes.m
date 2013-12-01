function satPercent = rendervideoframes(camera, scene, luminances, savefolder)
    L3 = cameraGet(camera, 'l3');
    sensorD  = L3Get(L3,'design sensor');
    cfaSize = sensorGet(sensorD,'cfa size');
    satPercent = zeros(length(luminances), cfaSize(1)*cfaSize(2));
    
    pixel = sensorGet(sensorD,'pixel');
    voltageSwing = pixelGet(pixel,'voltage swing');
    
    sz = sceneGet(scene, 'size');
    
    for ii = 1 : length(luminances)
        meanLum = luminances(ii);
        
        rand('seed', 10);
        randn('seed', 10);
        
        % Compute and save sRGB results
        [srgbResult, srgbIdeal, raw] = cameraComputesrgb(camera, scene, meanLum, sz);
        
        name = cameraGet(camera, 'name');
        saveFile = fullfile(savefolder, [name '_srgbResult_' num2str(meanLum) '.png']);
        imwrite(srgbResult, saveFile, 'png');
              
        for rr = 1 : cfaSize(1)
            for cc = 1 : cfaSize(2)
                targetPixels = raw(rr : cfaSize(1) : end, cc : cfaSize(2) : end);
                saturatedPixels = (targetPixels >= voltageSwing-.001);
                percent = sum(saturatedPixels(:)) / (size(targetPixels, 1) * size(targetPixels, 2));
                satPercent(ii, (rr - 1) * cfaSize(2) + cc ) = percent;
            end
        end
    end  
end

        