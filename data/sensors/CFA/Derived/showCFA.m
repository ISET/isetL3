function showCFA(filterNames,filterOrder)
sensor = sensorCreate;
sensor = sensorSet(sensor, 'filter names', filterNames);
sensor = sensorSet(sensor, 'filter order', filterOrder);
sensor = sensorSet(sensor, 'size', [12,12]);
plotSensor(sensor,'cfa full');
