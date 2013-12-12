function L3 = L3Initialize(L3, hfov)

% Initialize L3 structure with default parameters.
%
%   L3 = L3Initialize(L3, hfov)
%
% Add default scene, optics, ideal sensor and design sensor to the L3
% structure.
%
% INPUT 
%   L3:     (Optional) L3 structure to initialize
%   hfov:   (Optional)  Horizontal field of view for scenes, default 10
%           degrees   (This default can be overwritten here because it is
%           so difficult to change after initialization.)
%
% OUTPUT
%   L3: The modified L3 with default parameters
%
% Example: 
%   L3 = L3Create; L3 = L3Initialize( L3 );
%   L3 = L3Initialize;
% 
% (c) Stanford VISTA Team 2013


%% Initialize in case the user did not define
if ieNotDefined('L3') || isempty(L3), L3 = L3Create; end
if ieNotDefined('hfov'), hfov = 10; end

%% Training Scenes
L3 = L3InitTrainingScenes(L3, hfov);

%% Optical Image
L3 = L3InitOi(L3);

%% Monochrome sensor 
L3 = L3InitMonochromeSensor(L3);

%% Ideal filters
L3 = L3InitIdealFilters(L3);

%% Design sensor
L3 = L3InitDesignSensor(L3);

%% L3 Training Parameters
L3 = L3InitParams(L3);

end