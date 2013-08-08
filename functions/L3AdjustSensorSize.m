function L3 = L3AdjustSensorSize(L3,desiredhorizontalFOV,scene,oi)

%  Adjust sensor size to get desired horizontal field of view
%
% L3 = L3AdjustSensorSize(L3,desiredhorizontalFOV,scene,oi)
%
% Horizontal field of view should be measured in degrees.


sensorM = L3Get(L3,'monochrome sensor');
sensorD = L3Get(L3,'design sensor');

[rows, cols] = L3SensorSize(sensorM,desiredhorizontalFOV,scene,oi);
sensorM = sensorSet(sensorM,'size',[rows cols]);
sensorD = sensorSet(sensorD,'size',[rows cols]);

L3 = L3Set(L3,'monochrome sensor',sensorM);
L3 = L3Set(L3,'design sensor',sensorD);