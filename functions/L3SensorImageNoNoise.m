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


%% Get parameters from L3
nScenes   = L3Get(L3,'n scenes');
sensorM   = L3Get(L3,'sensor monochrome');
oi        = L3Get(L3,'oi');
sensorM   = sensorSet(sensorM,'NoiseFlag',0);  % Turn off noise
desiredIm = cell(nScenes,1);
inputIm   = cell(nScenes,1);

for ii=1:nScenes
    thisScene = L3Get(L3,'scene',ii);
    oi = oiCompute(oi,thisScene);
    
    %% For design filter transmissivities,
    cFilters = L3Get(L3,'design filter transmissivities');
    inputIm{ii} = monoCompute(sensorM,oi,cFilters);
    
    cFilters = L3Get(L3,'ideal filter transmissivities');
    desiredIm{ii} = monoCompute(sensorM,oi,cFilters);
    
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

