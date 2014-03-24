function satPercent = rendervideoframes(camera, scene, luminances, savefolder)
% This function renders images at a seris of luminance for a given camera,
% and computes of the percent or saturated pixels for each CFA color
% channel.
%
%
%
%
% (c) Stanford VISTA Team

%% Each CFA color channel has a list of saturation percentages
L3 = cameraGet(camera, 'l3');
sensorD  = L3Get(L3,'design sensor');
cfaSize = sensorGet(sensorD,'cfa size');
satPercent = zeros(length(luminances), cfaSize(1)*cfaSize(2)); 

%% Get saturation level
pixel = sensorGet(sensorD,'pixel');
voltageSwing = pixelGet(pixel,'voltage swing');

%% Set the size of rendered images
sz = sceneGet(scene, 'size'); 

%% Render images and compute saturation percentages
for ii = 1 : length(luminances)
    lum = luminances(ii);
    fprintf('Rendering luminance: %s\n',lum);
    
    % Use the same seed to generate noise such that the noise in all frames
    % are unchanged which makes the created video visually pleasing  
    rand('seed', 10);
    randn('seed', 10);

    % Compute and save sRGB results
    [srgbResult, srgbIdeal, raw] = cameraComputesrgb(camera, scene, lum, sz,[],[], 0);

    name = cameraGet(camera, 'name');
    saveFile = fullfile(savefolder, [name '_srgbResult_' num2str(lum) '.png']);
    imwrite(srgbResult, saveFile);

    for rr = 1 : cfaSize(1)
        for cc = 1 : cfaSize(2)
            targetPixels = raw(rr : cfaSize(1) : end, cc : cfaSize(2) : end);
            saturatedPixels = (targetPixels >= voltageSwing-.001);
            percent = sum(saturatedPixels(:)) / (size(targetPixels, 1) * size(targetPixels, 2));
            satPercent(ii, (rr - 1) * cfaSize(2) + cc ) = percent;
        end
    end
end  


        