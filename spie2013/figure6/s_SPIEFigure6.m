%% s_SPIEFigure6
%
% This script trains L3 with bias and variance tradeoff for differnt
% luminance and chrominance weights for RGBW CFA for SPIE2013 paper 
% figure 6.  
%
% (c) Stanford VISTA Team

%% Start ISET
s_initISET

%% Initialize parameters

forceTrain = false; % If you insist on training the 4 cameras, set true

chromaWeight = [1,16];  % Weights for regularization
lumaWeight   = [1,16];

% Set up camera file names for these weights
cameraFile = cell(length(lumaWeight),length(chromaWeight));
for jj=1:length(chromaWeight)
    for ii = 1:length(lumaWeight)
        cameraFile{ii,jj} = ['L3Camera_lw' num2str(lumaWeight(ii)) '_cw' num2str(chromaWeight(jj)),'.mat'];
    end
end
        
%% Check whether Training for L3 is required.

for jj=1:length(chromaWeight)
    for ii=1:length(lumaWeight)
        
        % Skip the training if the camera is already stored.
        if ~exist(cameraFile{ii,jj},'file') || forceTrain
            
            fprintf('*** Training camera %s\n',cameraFile{ii,jj});
            
            % Create and initialize L3 structure
            L3 = L3Initialize();  % use default parameters
            
            % Use same weights for global, flat and texture
            weights = [chromaWeight(jj), lumaWeight(ii), chromaWeight(jj)];
            L3 = L3Set(L3, 'global weight bias variance', weights);
            L3 = L3Set(L3, 'flat weight bias variance', weights);
            L3 = L3Set(L3, 'texture weight bias variance', weights);
            
            % Perform training
            L3 = L3Train(L3);
            
            camera = L3CameraCreate(L3);
            saveFile = ['L3Camera_lw' num2str(lumaWeight(ii)) '_cw' num2str(chromaWeight(jj))];
            save(saveFile, 'camera'); % save camera
        else
            fprintf('*** Found camera %s\n',cameraFile{ii,jj});
        end
    end
end


%% Render images

% Load scene
scene = sceneFromFile(fullfile(L3rootpath,'spie2013','data','AsianWoman_1.mat'), 'multispectral');
sz = sceneGet(scene, 'size');
meanLum = 1;

% Load camera and render images
for jj=1:length(chromaWeight)
    for ii=1:length(lumaWeight)
        
        load(cameraFile{ii,jj}, 'camera');
        
        % Compute, which produces both the ideal and noisy version.        
        srgbResult = cameraComputesrgb(camera, scene, meanLum, sz,[],[],1);
        
        % Save the files for the paper
        saveFile = ['srgbResult_lw' num2str(lumaWeight(ii)) '_cw' num2str(chromaWeight(jj)) '.png'];
        imwrite(srgbResult, saveFile);
    end
end

%% End



