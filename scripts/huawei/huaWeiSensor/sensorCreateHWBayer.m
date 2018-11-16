function sensor = sensorCreateHWBayer
% Create a sensor Bayer filter with HW requirement


%% Start with a basic sensor
sensor = sensorCreate;

%% Adjust its properties to the quad format
quadPattern = ...
    [3 2; 2 1];

sensor = sensorSet(sensor,'pattern',quadPattern);

%% Set up the other parameters - To be done

% sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'));
% sensor = sensorSet(sensor,'pixel size constant fill factor',1.4e-6);
% sensor = sensorCompute(sensor,oi);


end
