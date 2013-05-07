function [tMatrix,pMatrix] = L3trainingPatches(L3,desiredIm,inputIm)
% Create the target and patch matrices for a pixel type in the cfaPattern
%
% [tMatrix,pMatrix] = L3trainingPatches(L3, desiredIm,inputIm, targetCFAPosition)
% 
% Creates vectors of patches that are for training (tMatrix) and a matrix
% of input image patches (pMatrix).
%
% If the desiredIm is not sent in, then tMatrix is returned empty.
%
% Inputs:
%  desiredIm:   The full target values in a calibrated space, as a 3D matrix
%  inputIm:     The full sensor data, no mosaic, as 3D matrix
%  cfaPattern:  Small matrix of cfa arrangement
%  blockSize:   How large a block to use for the calculation
%  targetColor: The (row,col) of the pixel in the cfa to work on
%
% Outputs:
%  tMatrix: The (r,c,3) matrix of vectors, from desiredIm, of the target solution
%  pMatrix: The [r,c,patchSize^2] matrix of the measured samples 
%
% Checks that the patch size is odd.
% Figures out the positions to sample for this targetCFAposition.
% Extracts the target values from desiredIm into tMatrix
% Extracts the sensor data from inputIm into the pMatrix
%
% (c) Stanford Vista Team

%%

% Sample positions, xPos,yPos.  Make this a function that can be called from other
% places.  We use it in L3render, for example.  We want xPos,yPos to be
% returned.
[xPos,yPos] = L3SensorSamplePositions(L3);

% [r,c,nBands] = size(inputIm);

% Target matrix, typically (r,c,3) for XYZ values.  That's easy.
if ~isempty(desiredIm), tMatrix = desiredIm(yPos,xPos,:);
else tMatrix = []; 
end
% Reshape the returned data into vectors and matrices
[r,c,w] = size(tMatrix);
tMatrix = reshape(tMatrix,r*c,w)';
% imagescRGB(tMatrix)

%% Convert the multiple plane inputIm data into a sensor plane.

cfaPattern = sensorGet(L3Get(L3,'design sensor'),'cfa pattern');
blockWidth = L3Get(L3,'block width');
if ndims(inputIm) == 3
    sensorPlane = sensorRGB2Plane(inputIm, cfaPattern);
else
    sensorPlane = inputIm;
end
% vcNewGraphWin; imagesc(sensorPlane); colormap(gray)

% Convert the sensor data into the patch data matrix
pMatrix = L3sensorPlane2Patch(sensorPlane,blockWidth,xPos,yPos);

% Arranged to be patchSize^2 x nSamples
[r,c,w] = size(pMatrix);
pMatrix = reshape(pMatrix,r*c,w)';

return




