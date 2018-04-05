function pType = cfa2ptype(cfaSize,sensorSize)
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
%
% Output
%  pType:  The position in the cfa pattern for every pixel in sensorSize
%
% HJ/BW Vistalab Team, Copyright 2015

pType = 1:prod(cfaSize);
pType = reshape(pType,cfaSize);

% We should check if this is a multiple.
pType = repmat(pType, sensorSize(1) / cfaSize(1), ...
                      sensorSize(2) / cfaSize(2));

end
