function [tMatrix,pMatrix] = L3trainingPatches(L3,desiredIm,inputIm)
% Create the target and patch matrices for a pixel type in the cfaPattern
%
% RENAME THIS ROUTINE.  IT IS USED FOR TESTING AS WELL AS FOR TRAINING.
%
% [tMatrix,pMatrix] = L3trainingPatches(L3, desiredIm,inputIm)
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
%  desiredIm:   The full target values in a calibrated space, as a 3D matrix
%  inputIm:     The full sensor data, no mosaic, as 3D matrix
%
% Outputs:
%  tMatrix: The (r*c,3) matrix of vectors, from desiredIm, of the target solution
%  pMatrix: The [r*c,patchSize^2] matrix of the measured samples 
%
% Checks that the patch size is odd.
% Extracts the target values from desiredIm into tMatrix
% Extracts the sensor data from inputIm into the pMatrix
%
% (c) Stanford Vista Team

%% Create the first matrix, tMatrix

% Sample positions, xPos,yPos.  Make this a function that can be called
% from other places.  We use it in L3render, for example.  We want
% xPos,yPos to be returned.  This is based on the sensor and is the same
% for all the scenes.
[xPos,yPos] = L3SensorSamplePositions(L3);
sz = length(xPos)*length(yPos);

if isempty(desiredIm), nScenes = 1;
else nScenes = L3Get(L3,'n scenes');
end

% Target matrix, typically (r,c,3) for XYZ values.  That's easy.
tMatrix = [];
if ~isempty(desiredIm)
    nColor = size(desiredIm{1},3);
    for ii=1:nScenes
        tmp = desiredIm{ii};  % vcNewGraphWin; imagescRGB(tmp);
        tmpTMatrix = tmp(yPos,xPos,:);
        tmpTMatrix = reshape(tmpTMatrix,sz,nColor)';
        % vcNewGraphWin;
        % foo = reshape(tmpTMatrix,length(yPos),length(xPos),nColor);
        % imagescRGB(foo);
        tMatrix = cat(2,tMatrix,tmpTMatrix);
    end
end
% Reshape the returned data into vectors and matrices
% imagescRGB(tMatrix)

%% Convert the multiple plane inputIm data into a sensor plane, pMatrix.
cfaPattern = sensorGet(L3Get(L3,'design sensor'),'cfa pattern');
blockWidth = L3Get(L3,'block width');
nBlock = blockWidth*blockWidth;

pMatrix = [];
for ii=1:nScenes
    tmp = inputIm{ii};   % row, col, nColors
    if ndims(tmp) == 3, sensorPlane = sensorRGB2Plane(tmp, cfaPattern);
    else                sensorPlane = tmp;
    end   % Sensor plane is row,col, 1
    
    % vcNewGraphWin; imagesc(sensorPlane); colormap(gray)
    
    % Convert the sensor data into the patch data matrix
    tmppMatrix = L3sensorPlane2Patch(sensorPlane,blockWidth,xPos,yPos);
    
    % Arranged to be patchSize^2 x nSamples
    tmppMatrix = reshape(tmppMatrix,sz,nBlock)';
    
    pMatrix = cat(2,pMatrix,tmppMatrix); 
end

return

