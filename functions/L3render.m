function [resultL3,resultL3LumIdx, resultL3SatIdx, resultL3ClusterIdx] = ...
                    L3render(L3,sensor,L3Type)
%Apply L3 processing pipeline to a sensor voltage image
%
%  [resultL3, resultL3LumIdx, resultL3SatIdx] = L3render(L3,sensor,L3Type)
%
% The result is in the space that was trained for the L3 algorithm.  The
% sensor should be matched the type of sensor that was used to train the L3
% structure, but it can contain any data.
%
% So far, the result has usually been an XYZ image (that is the training
% space).  The sensor style has been RGBW in our preliminary work, but this
% will be expanded.
%
%INPUTS:
%   L3 structure
%   sensor - image sensor with data 
%   L3Type - local or global
%
%OUTPUTS:  (images have black borders where patch doesn't fit)
%   resultL3:         estimated image from L^3 algorithm
%   resultL3LumIdx:   luminance level used for each patch
%   resultL3SatIdx:   saturation case used for each patch
%   resultL3ClusterIdx:  0 if flat, index of texture cluster if texture
%   borderWidth:      number of pixels wide for the black border
%
% Example:
%    sensor   = L3Get(L3,'design sensor'); 
%    resultL3 = L3render(L3,sensor,'local');
%    resultL3 = L3render(L3,sensor,'global');
%
% Copyright Steven Lansel, 2010


%% Variables
if ieNotDefined('L3'),     error('L3 structure required'); end
if ieNotDefined('sensor'), error('sensor structure required'); end
if ieNotDefined('L3Type'), error('L3Type required'); end

inputIm = sensorGet(sensor,'volts');

%% Delete any offset
sensorM = L3Get(L3,'monochrome sensor');
ao = sensorGet(sensorM,'analogOffset');
ag = sensorGet(sensorM,'analogGain');

inputIm = inputIm - ao/ag;
% above is because    volts = (volts + ao)/ag (see sensorCompute)

%% Render the voltage from the sensor structure 
% vcNewGraphWin; imagesc(volts/max(volts(:)))
cfaSize = sensorGet(sensor,'cfa size');
sz      = sensorGet(sensor,'size');

nColors        = L3Get(L3,'n ideal filters');
resultL3       = zeros(sz(1),sz(2),nColors);
resultL3LumIdx = zeros(sz(1),sz(2));
resultL3SatIdx = zeros(sz(1),sz(2));
resultL3ClusterIdx = zeros(sz(1),sz(2));

% Adjust the L3 sensor size to match the size of the input image
sensorD  = L3Get(L3,'design sensor');
sensorD  = sensorSet(sensorD,'size',sz);
L3 = L3Set(L3,'design sensor',sensorD);

% Build the image one cfa pattern position at a time
for rr = 1:cfaSize(1)
    for cc = 1:cfaSize(2)
        
        % Create  target patches for this cfa position
        L3 = L3Set(L3,'patch type',[rr,cc]);
        inputPatches = L3sensor2Patches(L3,inputIm);
        
        [xhatL3,lumIdx, satIdx, clustermembers] = L3applyPipeline2Patches(L3,inputPatches,L3Type);
        
        [xPos,yPos] = L3SensorSamplePositions(L3);

        % Put the data from this cfa position into the final image
        resultL3(yPos,xPos,1:nColors) = ...
            permute(reshape(xhatL3,nColors,length(yPos),length(xPos)),[2,3,1]);
        
        resultL3LumIdx(yPos,xPos) = reshape(lumIdx,length(yPos),length(xPos));        
        resultL3SatIdx(yPos,xPos) = reshape(satIdx,length(yPos),length(xPos));
        resultL3ClusterIdx(yPos,xPos) = reshape(clustermembers,length(yPos),length(xPos));        
    end
end

return

