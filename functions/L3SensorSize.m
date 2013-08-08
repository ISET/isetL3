function [rows, cols] = L3SensorSize(sensor,hfov,scene,oi)

% Find size of sensor given desired field of view
%
% [rows, cols] = L3SensorSize(sensor,hfov,scene,oi)
%
% Use following line to set the sensor size.
%   sensor = sensorSet(sensor,'size',[rows cols]);


sensor = sensorSetSizeToFOV(sensor,hfov,scene,oi);   % deg of visual angle

% It is important that the size work properly with the cfa pattern size.
% For example, if the pattern is 2x2, we need an even number of rows and
% columns.
sensorSize = sensorGet(sensor,'size');
rows = sensorSize(1);
cols = sensorSize(2);
% Following increases the size of the sensor so its rows and columns are a
% whole multiple of 12.  Previously this was done for a whole multiple of
% 2 but that doesn't work for CFAs that are larger than 2 x 2.  12 was
% chosen so that CFAs of size 2, 3, 4, or 6 will work.
% if isodd(rows), rows = rows+1; end
% if isodd(cols), cols = cols+1; end
additionalrows = 12-mod(rows,12);
additionalcols = 12-mod(cols,12);
if additionalrows==12; additionalrows=0; end
if additionalcols==12; additionalcols=0; end
rows = rows + additionalrows;
cols = cols + additionalcols;

