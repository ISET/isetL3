function sensor = sensorCreateQuad
% Create a quad sensor Bayer filter
%
% https://www.gsmarena.com/explaining_huawei_p20_pros_triple_camera-news-30497.php
%
% Wandell

%%

sensor = sensorCreate;

quadPattern = ...
    [1 1 2 2; ...
    1 1 2 2; ...
    2 2 3 3; ...
    2 2 3 3];

sensor = sensorSet(sensor,'pattern',quadPattern);
sensor = sensorSet(sensor,'pixel size constant fill factor',1.4e-6);

% sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'));

% sensor = sensorCompute(sensor,oi);

end

