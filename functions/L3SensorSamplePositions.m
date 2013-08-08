function [xPos,yPos] = L3SensorSamplePositions(L3)
% Return sample positions for a particular cfa filter
%
%  [xPos,yPos] = L3SensorSamplePositions(L3)
%
% (c) Stanford VISTA Team

cfaPattern = sensorGet(L3Get(L3,'design sensor'),'cfaPattern');
targetCFAPosition = L3Get(L3,'patch type');

sz = sensorGet(L3Get(L3,'design sensor'),'size');


% Following makes sure the sensor ends after a complete CFA block.  If not
% there are errors later in this function.  This also makes sure the sensor
% is smaller than the rgbData so that rgbData can be cropped to the
% appropriate size.
sz(1) = size(cfaPattern,1) * floor(sz(1)/size(cfaPattern,1));
sz(2) = size(cfaPattern,2) * floor(sz(2)/size(cfaPattern,2));

borderWidth = L3Get(L3,'border width');

% Pick each corresponding cfa position
xPos = targetCFAPosition(2):size(cfaPattern,2):(sz(2)-borderWidth);
yPos = targetCFAPosition(1):size(cfaPattern,1):(sz(1)-borderWidth);

%Remove any first row/column of pixels that are too close to edge to allow
%a patch to fit.
xPos(xPos<=borderWidth) = [];
yPos(yPos<=borderWidth) = [];

return
