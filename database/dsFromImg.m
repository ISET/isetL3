function savePath = dsFromImg(dsPath, savePath, imgFormat, ilSpectra)
%% dsFromImg(dsPath, savePath, imgFormat)
% Create scene from images

%% load images
format = strcat('*.', imgFormat);
filesToLoad = dir(fullfile(dsPath, format));

targetFormat = strcat('*.mat');
% number of the scene
%%
for ii = 1 : length(filesToLoad)
    
    % Image file name
    imgName = filesToLoad(ii).name;
    
    % Transfer image to scene
 
    wList = [400:10:700];
    fullImgName = fullfile(dsPath, imgName);
    scene = sceneFromFile(fullImgName, 'rgb', 110, 'LCD-Apple', wList);
    scene = sceneSet(scene, 'fov', 80);
%     scene = sceneSet(scene, 'distance', 0.3);
    illmnt = ieReadSpectra(ilSpectra, wList);
    scene = sceneAdjustIlluminant(scene, illmnt);
    
    % Save the iamge
    
    %
    sceneExisted =dir(fullfile(savePath, targetFormat));
    numScene = length(sceneExisted); saveIdx = int2str(numScene + 1);
    saveName = strcat(saveIdx, '.mat');
    sceneToFile(fullfile(savePath, saveName), scene);
    
end

end