function [pMatrix,tMatrix] = L3Patches2Patches(L3,inputIm,desiredIm)

% Create the target and patch matrices for a pixel type in the cfaPattern
%
% [pMatrix,tMatrix] = L3sensor2Patches(L3, inputIm, desiredIm)
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
%  inputIm:     The full sensor data, no mosaic, as 3D matrix -or- cell
%               with sensor data from multiple scenes
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

%%
if ~iscell(inputIm)
    inputIm = {inputIm};
end
nScenes = length(inputIm);

%% Create the first matrix, tMatrix

% Sample positions, xPos,yPos.  Make this a function that can be called
% from other places.  We use it in L3render, for example.  We want
% xPos,yPos to be returned.  This is based on the sensor and is the same
% for all the scenes.
blockSize = L3Get(L3,'block size');
sz = blockSize(1)*blockSize(2);

% Target matrix, typically (r,c,3) for XYZ values.  That's easy.
tMatrix = [];
if nargin>=3 & ~isempty(desiredIm)
    nColor = size(desiredIm{1},3);
    for ii=1:nScenes
        tmpTMatrix = desiredIm{ii};
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
    if ndims(inputIm{ii}) == 3, sensorPlane = sensorRGB2Plane(inputIm{ii}, cfaPattern);
    else                sensorPlane = inputIm{ii};
    end   % Sensor plane is row,col, 1
    
    % vcNewGraphWin; imagesc(sensorPlane); colormap(gray)
    
    % Convert the sensor data into the patch data matrix
    tmppMatrix = L3sensorPlane2Patch(sensorPlane,blockWidth,blockSize(1),blockSize(2));
    
    % Arranged to be patchSize^2 x nSamples
    tmppMatrix = reshape(tmppMatrix,sz,nBlock)';
    
    pMatrix = cat(2,pMatrix,tmppMatrix); 
end

return

