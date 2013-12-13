%% s_SPIEFigure6
%
% This script trains L3 with bias and variance tradeoff for differnt
% luminance and chrominance weights for RGBW CFA for SPIE2013 paper 
% figure 6.  
% 
%
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Train L3 and create L3 camera
% Skip this step if the camera is pre-trained and stored.

for chromaWeight = [1, 16]
    for lumaWeight = [1, 16]
        % Create and initialize L3 structure
        L3 = L3Initialize();  % use default parameters
        
        % Use same weights for global, flat and texture 
        weights = [chromaWeight, lumaWeight, chromaWeight]; 
        L3 = L3Set(L3, 'global weight bias variance', weights);
        L3 = L3Set(L3, 'flat weight bias variance', weights);
        L3 = L3Set(L3, 'texture weight bias variance', weights);
        
        % Perform training
        L3 = L3Train(L3);
        
        camera = L3CameraCreate(L3);
        saveFile = ['L3Camera_lw' num2str(lumaWeight) '_cw' num2str(chromaWeight)];
        save(saveFile, 'camera'); % save camera
    end
end

%% Render images
% Load scene
scene = sceneFromFile('/biac4/wandell/data/qytian/L3Project/scene/AsianWoman_1.mat', 'multispectral');
sz = sceneGet(scene, 'size');
meanLum = 1;

% Load camera and render images
for chromaWeight = [1, 16]
    for lumaWeight = [1, 16]
        loadFile = ['L3Camera_lw' num2str(lumaWeight) '_cw' num2str(chromaWeight)];
        load(loadFile, 'camera');
        srgbResult = cameraComputesrgb(camera, scene, meanLum, sz);
        saveFile = ['srgbResult_lw' num2str(lumaWeight) '_cw' num2str(chromaWeight) '.png'];
        imwrite(srgbResult, saveFile);
    end
end





