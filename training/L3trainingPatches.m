function [pMatrix,tMatrix] = L3trainingPatches(L3,inputIm,desiredIm)
% Create the target and patch matrices for a pixel type in the cfaPattern
%
% [pMatrix,tMatrix] = L3trainingPatches(L3, inputIm, desiredIm)
% 
% Creates vectors of patches that are for training (tMatrix) and a matrix
% of input image patches (pMatrix).  These are for a particular patch type.
%
% If the desiredIm is not sent in, then tMatrix is returned empty.
%
% desiredIm and inputIm are cell arrays of matrices.  Each is built from a
% different scene.  See s_L3Scenes2SensorData.m
%
% Inputs:
%  L3:          L3 structure
%  inputIm:     The full sensor data, no mosaic, as 3D matrix
%  desiredIm:   The full target values in a calibrated space, as a 3D matrix
%
% Outputs:
%  pMatrix: The (r*c,patchSize^2) matrix of the measured samples 
%  tMatrix: The (r*c,3) matrix of vectors, from desiredIm, of the target solution
%
% Extracts the sensor data from inputIm into the pMatrix
% Extracts the target values from desiredIm into tMatrix
%
% (c) Stanford Vista Team


dSensor = L3Get(L3,'design sensor');
cfaPattern = sensorGet(dSensor,'cfa pattern');
patchtype = L3Get(L3,'patch type');

%% Collect all training patches for given patch type from all scenes
% For each shift of the CFA, noise-free RAW sensor measurements are made.
% Only a subset of the pixels are of the correct color (patch type) so
% those patches are collected.
%
% In order to get every possible patch, we cycle through all circular
% shifts of the CFA so that each pixel position in the sensor ends up
% generating one patch of the desired type.
%
% Previously, this was run for only one shift of the CFA.  For a n x n CFA
% and m x m sensor, this resulted in the m^2/n^2 training patches for
% each patch type.  This is a problem because the number of trainig patches
% for each patch type varies for different sized CFAs.  With the new
% approach, every patch type generates m^2 training patches.

% Store results for each circular shift of the CFA into the following
% cell arrays.
pMatrix = cell(size(cfaPattern));
tMatrix = cell(size(cfaPattern));
for rowshift = 1:size(cfaPattern,1)
    for colshift = 1:size(cfaPattern,2)
        % Circular shift for CFA
        cfashift = [rowshift-1, colshift-1];
        newcfaPattern = circshift(cfaPattern,cfashift);
        dSensor = sensorSet(dSensor,'cfa pattern and size',newcfaPattern);
        L3 = L3Set(L3,'design sensor',dSensor);
        
        % Update patch type so we use the same type of pixel in the new CFA
        newpatchtype = patchtype+cfashift;
        if newpatchtype(1)>size(cfaPattern,1)
            newpatchtype(1) = newpatchtype(1) - size(cfaPattern,1);
        end
        if newpatchtype(2)>size(cfaPattern,2)
            newpatchtype(2) = newpatchtype(2) - size(cfaPattern,2);
        end        
        L3 = L3Set(L3,'patch type',newpatchtype);
        
        [pMatrix{rowshift,colshift},tMatrix{rowshift,colshift}] = ...
            L3sensor2Patches(L3,inputIm,desiredIm);
    end
end

%% Convert from cell array to big matrix
pMatrix = cell2mat(reshape(pMatrix,1,numel(cfaPattern)));
tMatrix = cell2mat(reshape(tMatrix,1,numel(cfaPattern)));


% No need to reset the original cfa or patch type in L3 because L3 is
% not returned

%% Subsample if there are more training patches than the max
numpatches = size(pMatrix,2);
maxpatches = L3Get(L3,'max training patches');
if ~isempty(maxpatches) & numpatches>maxpatches
    keep = randsample(numpatches, maxpatches);
    pMatrix = pMatrix(:,keep);
    tMatrix = tMatrix(:,keep);
end