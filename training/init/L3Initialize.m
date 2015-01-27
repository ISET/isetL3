function L3 = L3Initialize(L3, trainingscenes, oi, designsensor, idealfilters)

% Initialize L3 structure with specified parameters or default.
%
%   L3 = L3Initialize(L3, trainingscenes, oi, designsensor, idealfilters)
%
% Add default scenes, optics, design sensor and ideal filters to the L3
% structure.
%
% INPUT 
%   L3: (Optional) L3 structure to initialize
%   trainingscenes: (Optional) training scenes to initialize
%   oi: (Optional) optics to initialize
%   designsensor: (Optional) design sensor to initialize
%   idealfilters: (Optional) ideal filters to initialize
%
% OUTPUT
%   L3: The modified L3 with default parameters
%
% Example: 
%   L3 = L3Create; L3 = L3Initialize( L3 );
%   L3 = L3Initialize;
% 
% (c) Stanford VISTA Team 2014


%% Initialize in case the user did not define
if ieNotDefined('L3') || isempty(L3)
    L3 = L3Create;
end

%% Training Scenes
if ieNotDefined('trainingscenes') || isempty(trainingscenes)
    L3 = L3InitTrainingScenes(L3);
else
    L3 = L3Set(L3,'scene',trainingscenes); % use specified training scenes
end

%% Optical Image
if ieNotDefined('oi') || isempty(oi)
    L3 = L3InitOi(L3);
else
    L3 = L3Set(L3,'oi',oi); % use specified oi
end

%% Design sensor
if ieNotDefined('designsensor') || isempty(designsensor)
    L3 = L3InitDesignSensor(L3);
else
    % Check the sensor size is consistent with the training scene FOV
    scenes = L3Get(L3,'scene');
    oi = L3Get(L3,'oi');
    hfov = sceneGet(scenes{1},'hfov');
    [rows, cols] = L3SensorSize(designsensor, hfov, scenes{1}, oi);
    designsensor = sensorSet(designsensor,'size',[rows cols]);
    L3 = L3Set(L3,'design sensor', designsensor);
    sceneCol = sceneGet(scenes{1}, 'cols');
    if sceneCol < cols
        warning('More columns in sensor than in scene. Consider reducing scene FOV.');
    end
end


%% Ideal filters
if ieNotDefined('idealfilters') || isempty(idealfilters)
    L3 = L3InitIdealFilters(L3);
else
    L3 = L3Set(L3, 'ideal filters', idealFilters);
end

%% L3 Training Parameters
L3 = L3InitParams(L3);

end