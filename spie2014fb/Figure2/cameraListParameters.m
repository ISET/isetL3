function hdl = cameraListParameters(camera)
% Create a table listing sensor parameters and optics parametrs
%
% Sensor parameters: 
%
% pixel width and height, fill factor, dark voltage, read noise, dark
% signal nonuniformity, photoreceptor nonuniformity, conversion gain,
% voltage swing, well capacity analog gain, analog gain, analog
%
% Optics parameters:
%
% f number and focal length
%
% hdl = cameraListParameters(camera)
%
%
% Example:
%  camera = cameraCreate;
%  hdl = sensorListParameters(sensor);
%
%
% (c) Stanford VISTA Team

if ieNotDefined('camera') || isempty(camera), error('Camera needed'); end
     
hdl = vcNewGraphWin;
sensor = cameraGet(camera, 'sensor');
pixel = sensorGet(sensor, 'pixel');
optics = cameraGet(camera, 'optics');
t = uitable;
data = {'Pixel Width/ Height (m)', num2str(pixelGet(pixel, 'width'));
            'Fill Factor', num2str(pixelGet(pixel, 'fill factor'));
            'Dark Voltage (V/sec)', num2str(pixelGet(pixel, 'dark voltage'));
            'Read Noise (V)', num2str(pixelGet(pixel, 'read noise'));
            'Dark Signal Nonuniformity (V)', num2str(sensorGet(sensor, 'dsnu level'));
            'Photoreceptor Nonuniformity (%)', num2str(sensorGet(sensor, 'prnu level'));
            'Conversion Gain (V/e)', num2str(pixelGet(pixel, 'conversion gain'));
            'Voltage Swing (V)', num2str(pixelGet(pixel, 'voltage swing'));
            'Well Capacity (e)', num2str(pixelGet(pixel, 'well capacity'));
            'Analog Gain', num2str(sensorGet(sensor, 'analog gain'));
            'Analog Offset (V)', num2str(sensorGet(sensor, 'analog offset'))
            'F Number', num2str(opticsGet(optics, 'f number'))
            'Focal Length (m)', num2str(opticsGet(optics, 'focal length'))};
            
set(t, 'Data', data);
set(t, 'RowName', '');
set(t, 'ColumnName', '');
set(t, 'ColumnWidth',{200})
set(t, 'Position', [0 0 400 250])
end
 


























