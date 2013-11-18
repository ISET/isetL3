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
%  pMatrix: The [r*c,patchSize^2] matrix of the measured samples 
%  tMatrix: The (r*c,3) matrix of vectors, from desiredIm, of the target solution
%
% Checks that the patch size is odd.
% Extracts the sensor data from inputIm into the pMatrix
% Extracts the target values from desiredIm into tMatrix
%
% (c) Stanford Vista Team


dSensor = L3Get(L3,'design sensor');
cfaPattern = sensorGet(dSensor,'cfa pattern');
patchtype = L3Get(L3,'patch type');

pMatrix = cell(size(cfaPattern));
tMatrix = cell(size(cfaPattern));
for rowshift = 1:size(cfaPattern,1)
    for colshift = 1:size(cfaPattern,2)
        cfashift = [rowshift-1, colshift-1];
        newcfaPattern = circshift(cfaPattern,cfashift);
        dSensor = sensorSet(dSensor,'cfa pattern',newcfaPattern);
        L3 = L3Set(L3,'design sensor',dSensor);
        
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

%% Covnert from cell array to big matrix
pMatrix = cell2mat(reshape(pMatrix,1,prod(size(cfaPattern))));
tMatrix = cell2mat(reshape(tMatrix,1,prod(size(cfaPattern))));


% No need to set the original cfa back into L3 because L3 is not returned
