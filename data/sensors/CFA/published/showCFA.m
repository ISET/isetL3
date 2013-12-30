function showCFA(filterNames,filterOrder)
%
% This function should be deprecated (BW)
%
%  See the script s_cfaShow for a more efficient way to look through the
%  list of published CFAs.
%
% Stanford VISTASOFT Team, 2013

sensor = sensorCreate;
sensor = sensorSet(sensor, 'filter names', filterNames);
sensor = sensorSet(sensor, 'filter order', filterOrder);

plotSensor(sensor,'cfa block');

%End