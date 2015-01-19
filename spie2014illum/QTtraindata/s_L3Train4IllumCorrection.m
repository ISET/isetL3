%% s_L3Train4IllumCorrection
% 
% This script is to train L3 for illuminant correction: cross illuminant
% correction, global correction and local correction
%
%
% (c) Stanford Vista Team 2014

clear, clc, close all

%% Start ISET
s_initISET

%% Illuminants and CFAs
ils = {'Tungsten', 'Fluorescent', 'D65'};
cfas = {'RGBW1'};%{'Bayer', 'RGBW1', 'CMY1'};

%% Training
for illumNum = 1 : length(ils)
    for cfaNum = 1 : length(cfas)
        disp(ils{illumNum})
        disp(cfas{cfaNum})
        
        %% Initialize L3
        L3 = L3Initialize(); 

        %% Change CFA pattern
        cfaFile = fullfile(L3rootpath, 'data', 'sensors', 'CFA', 'published', [cfas{cfaNum} '.mat']);
        cfaData = load(cfaFile); % load cfa file
        
        scenes = L3Get(L3,'scene');
        wave = sceneGet(scenes{1}, 'wave'); %use the wavelength samples from the first scene
        
        sensorD = L3Get(L3,'design sensor'); % set design sensor
        sensorD = sensorSet(sensorD,'filterspectra',vcReadSpectra(cfaFile, wave));
        sensorD = sensorSet(sensorD,'filter names',cfaData.filterNames);
        sensorD = sensorSet(sensorD,'cfa pattern',cfaData.filterOrder);
        L3 = L3Set(L3,'design sensor', sensorD);

        %% Use small block size
        blockSize = 5;              
        L3 = L3Set(L3,'block size', blockSize);
        
        %% Turn on bias and bariance. These weights are optimized
        % specifically for RGB/W
        
        % weights = [4, 4, 4];  
        % L3 = L3Set(L3, 'global weight bias variance', weights);
        % weights = [4, 16, 4]; 
        % L3 = L3Set(L3, 'flat weight bias variance', weights);
        % weights = [4, 1, 4]; 
        % L3 = L3Set(L3, 'texture weight bias variance', weights);
        
        %% Change luminance list
        patchLuminanceSamples = [0.001, 0.0016, 0.0026, 0.0041, 0.0065, 0.0104, 0.0166, 0.0266, 0.0424, 0.0678, 0.1082, 0.1729, 0.2762,...
                           0.4505, 0.6753, 0.9, 1.1248, 1.3495, 1.5743, 0.99*1.8];
        L3 = L3Set(L3,'luminance list', patchLuminanceSamples);
        
        
        %% Set training and rendering illuminant to be identical
        L3 = L3Set(L3, 'Training Illuminant', [ils{illumNum}, '.mat']);
        L3 = L3Set(L3, 'Rendering Illuminant', [ils{illumNum}, '.mat']);
        
        %% To compute correction matrices. We modify the ideal filters and
        % change L3Train and L3findfilters functions. It's a dirty and
        % quick way but we have to think out a clean way later.
        
        % Get ideal filters (XYZ quanta)
        idealFilters = L3Get(L3, 'idealFilters');
        XYZ = idealFilters.transmissivities;
        
        % Read training and rendering illuminant
        illumRender = vcReadSpectra(L3Get(L3, 'rendering illuminant'), wave);
        illumD65 = vcReadSpectra('D65.mat', wave);
        
        % Scale XYZ and concatenate to ideal filters
        illumRender = illumRender / sum(illumRender);
        illumD65 = illumD65 / sum(illumD65);
        scale = illumD65 ./ illumRender;
        XYZm = XYZ .* repmat(scale, [1, 3]); % XYZm is to set render illum to train illum
        
        % Set changes
        idealFilters.transmissivities = [XYZ, XYZm];
        idealFilters.filterNames = {'rX', 'gY', 'bZ', 'rXm', 'gYm', 'bZm'};
        L3 = L3Set(L3, 'idealFilters', idealFilters);
        
        %% Train and create camera
        L3 = L3Train_illum(L3);
        camera = L3CameraCreate_illum(L3);
        
        %% Save L3 camera and L3
        save(['dataNew/L3_' cfas{cfaNum} '_' ils{illumNum} '.mat'], 'L3');
        save(['dataNew/L3camera_' cfas{cfaNum} '_' ils{illumNum} '.mat'], 'camera');
        
    end % end cfaNum
end % end illumNum



 