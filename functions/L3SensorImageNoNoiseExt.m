function [desiredIm, inputIm] = L3SensorImageNoNoise(L3)
% Compute sensor volts for a monochrome sensor
%
%   [desiredIm, inputIm] = L3SensorImageNoNoise(L3)
%
% Compute the monochromne sensor pixel voltages for a series of filters in
% the monochrome sensor.
%
% Inputs:
%   L3:    L3 structure
%
% Outputs:
%   [desiredIm, inputIm]:  cell arrays, one for each scene, of the voltages
%   at each pixel for each of the filters from the filterList.  desiredIm
%   is for the perfectly calibrated, e.g. XYZ values.  inputIm is from the
%   design sensor.
%
%  No noise is added.
%
% (c) Stanford VISTA Team

trainingillum = L3Get(L3, 'training illuminant');
renderingillum = L3Get(L3, 'rendering illuminant');
nIlls = length(trainingillum);

%% Get parameters from L3
nScenes   = L3Get(L3,'n scenes');
sensorM   = L3Get(L3,'sensor monochrome');
oi        = L3Get(L3,'oi');
desiredIm = cell(nScenes*nIlls,1);
inputIm   = cell(nScenes*nIlls,1);


for jj = 1:nIlls
    for ii=1:nScenes
        thisScene = L3Get(L3,'scene',ii);
        wave = sceneGet(thisScene, 'wave'); %use the wavelength samples from the first scene
        
        sceneAdjustIlluminant(thisScene,'D65.mat');
        sceneAdjustLuminance(thisScene,100);
        
        %% Compute input images
        if trainingillum{jj}(1) ~= 'B'
            thisScene = sceneAdjustIlluminantEq(thisScene,trainingillum{jj});
        else
            illum = trainingillum{jj}(1:end-4);
            wave2 = [3*wave(1)/2-wave(2)/2;wave;3*wave(end)/2-wave(end-1)/2];
            illum = illuminantCreate('blackbody',wave2,str2double(illum(2:end)),100);
            illum = Quanta2Energy(wave2,double(illum.data.photons))';
            illum = illum(2:end-1);
            thisScene = sceneAdjustIlluminantEq(thisScene,illum);
        end
        
        oi = oiCompute(oi,thisScene);
        
        sensorM = sensorSet(sensorM, 'NoiseFlag',0);  % Turn off noise, keep analog-gain/offset, clipping, quantization
        cFilters = L3Get(L3,'design filter transmissivities');
        inputIm{ii + (jj-1)*nScenes} = monoCompute(sensorM,oi,cFilters);
        
        %% Compute ideal images
        % recompute oi if illuminant has changed
        if ~strcmpi(trainingillum{jj},renderingillum{jj})        
            if renderingillum{jj}(1) ~= 'B'
                thisScene = sceneAdjustIlluminantEq(thisScene,trainingillum{jj});
            else
                illum = trainingillum{jj}(1:end-4);
                illum = illuminantCreate('blackbody',thisScene.spectrum.wave,str2double(illum(2:end)));
                illum = Quanta2Energy(illum.spectrum.wave,double(illum.data.photons));
                thisScene = sceneAdjustIlluminantEq(thisScene,illum);
            end
            oi = oiCompute(oi,thisScene);
        end
        
        sensorM = sensorSet(sensorM,'NoiseFlag',-1);  % Turn off noise, analog-gain/offset, clipping, quantization
        cFilters = L3Get(L3,'ideal filter transmissivities');
        desiredIm{ii + (jj-1)*nScenes} = monoCompute(sensorM,oi,cFilters);
    end
end

end


% Image with individual monochrome sensor
function im = monoCompute(sensorM,oi,cFilters)

sz = sensorGet(sensorM,'size');

numChannels=size(cFilters,2);
im = zeros(sz(1),sz(2),numChannels);
for kk=1:numChannels
    
    s = sensorSet(sensorM,'filterspectra',cFilters(:,kk));
    s = sensorSet(s,'Name',sprintf('Channel-%.0f',kk));
    s = sensorCompute(s,oi,0);
    % vcAddAndSelectObject(s); sensorImageWindow
    
    im(:,:,kk) = sensorGet(s,'volts');
end

end

