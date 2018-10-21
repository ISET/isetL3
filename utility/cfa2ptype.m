function pType = cfa2ptype(cfaSize,sensorSize,varargin)
% Compute the pixel type from the cfa
%
%  pType = cfa2ptype(cfaSize,sensorSize)
%
% The pixel type indicates the position of the pixel within the cfa
% repeating pattern. The cfa indicates which pixel type (usually meaning
% color filter) it is. The pixel type ignores the color filter and only
% indicates the position within the cfa pattern.
%
% Inputs
%  cfaSize:     Row,Col dimensions of the cfa repeating pattern
%  sensorSize:  Row,Col dimensions of the sensor
%  varargin:    Size of scale factor for row and col
%
% Output
%  pType:  The position in the cfa pattern for every pixel in sensorSize
%
% HJ/BW Vistalab Team, Copyright 2015
% ZL updated, 2018


if isempty(varargin)
    pType = 1:prod(cfaSize);
    pType = reshape(pType,cfaSize);
else
    pType = zeros(cfaSize);
    
    scaleFactorRow = varargin{1}(1);
    scaleFactorCol = varargin{1}(2);
    cfaSizeDP(1) = cfaSize(1)/scaleFactorRow;
    cfaSizeDP(2) = cfaSize(2)/scaleFactorCol;
    
    pTypeVec = 1:prod(cfaSizeDP);
    pTypeDP = reshape(pTypeVec,cfaSizeDP); % Downsampled version
    for ii = 1 : length(pTypeVec)
        [row, col] = find(pTypeDP == pTypeVec(ii));
        pType((row - 1) * scaleFactorRow + 1 : row * scaleFactorRow,...
                (col - 1) * scaleFactorCol + 1 : col * scaleFactorCol) =...
                    pTypeVec(ii) * ones(scaleFactorRow, scaleFactorCol);
    end
end

% We should check if this is a multiple.
pType = repmat(pType, sensorSize(1) / cfaSize(1), ...
                      sensorSize(2) / cfaSize(2));

end
