%% s_SPIEFigure6
%
% This script trains L3 with bias and variance tradeoff for differnt
% luminance and chrominance weights for SPIE2013 paper figure 6.  
% 
%
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Train L3 and create L3 camera
% Skip this step if there is one pre-computed camera
for chromaWeight = [1, 16]
    for lumaWeight = [1, 16]
        % Create and initialize L3 structure
        L3 = L3Initialize();  % use default parameters

        A = L3findRGBWcolortransform(L3); % find conversion matrix
        L3 = L3Set(L3, 'weight color transform', A);
        
        % Use same weights for global, flat and texture 
        weights = [chromaWeight, lumaWeight, chromaWeight]; 
        L3 = L3Set(L3, 'global weight bias variance', weights);
        L3 = L3Set(L3, 'flat weight bias variance', weights);
        L3 = L3Set(L3, 'texture weight bias variance', weights);
        
        % Perform training
        L3 = L3Train(L3);
        
        camera = L3CameraCreate(L3);
        saveFile = ['L3Camera_LW' num2str(lumaWeight) '_CW' num2str(chromaWeight)];
        save(saveFile, 'camera'); % save camera
    end
end

%% Render images
% Load scene
dataroot = '/biac4/wandell/data/qytian/L3Project';
loadScene = fullfile(dataroot, 'scene', 'AsianWoman_1.mat');
scene = sceneFromFile(loadScene, 'multispectral');
sz = sceneGet(scene, 'size');
meanLum = 1;

% Load camera and render images
for chromaWeight = [1, 16]
    for lumaWeight = [1, 16]
        loadFile = ['L3Camera_LW' num2str(lumaWeight) '_CW' num2str(chromaWeight)];
        load(loadFile, 'camera');
        srgbResult = cameraComputesrgb(camera, scene, meanLum, sz);
        saveFile = ['srgbResult_LW' num2str(lumaWeight) '_CW' num2str(chromaWeight) '.png'];
        imwrite(srgbResult, saveFile);
    end
end





