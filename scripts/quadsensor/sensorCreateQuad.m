function sensor = sensorCreateQuad
% Create a quad sensor Bayer filter
%
% Syntax
%    sensor = sensorCreateQuad(varargin)
%
% Brief Description:
%
%   https://www.gsmarena.com/explaining_huawei_p20_pros_triple_camera-news-30497.php
%
%   We are experimenting with this type of sensor.  In the near
%   feature we will have optical images created that account for the
%   microlens properties in front of the sensor also.
%
% See also:
%   L3 related functions should all work with this.
%

%% Start with a basic sensor
sensor = sensorCreate;

%% Adjust its properties to the quad format
quadPattern = ...
    [3 3 2 2; ...
    3 3 2 2; ...
    2 2 1 1; ...
    2 2 1 1];

sensor = sensorSet(sensor,'pattern',quadPattern);

%% Set up the other parameters - To be done

% sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'));
sensor = sensorSet(sensor,'pixel size constant fill factor',1.4e-6);
% sensor = sensorCompute(sensor,oi);

end
