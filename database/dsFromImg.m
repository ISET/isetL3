function savePath = dsFromImg(dsPath, savePath, imgFormat, ilSpectra)
%% dsFromImg(dsPath, savePath, imgFormat)
% Create scene from images

%% load images
cd(dsPath);
format = strcat('*.', imgFormat);
filesToLoad = dir(format);

targetFormat = strcat('*.mat');
% number of the scene
%%
for ii = 1 : length(filesToLoad)
    
    % Image file name
    imgName = filesToLoad(ii).name;
    
    % Transfer image to scene
    
    cd(dsPath);
    wList = [400:10:700];
    scene = sceneFromFile(imgName, 'rgb', 110, 'LCD-Apple', wList);
    scene = sceneSet(scene, 'fov', 10);
    scene = sceneSet(scene, 'distance', 1);
    illmnt = ieReadSpectra(ilSpectra, wList);
    scene = sceneAdjustIlluminant(scene, illmnt);
    
    % Save the iamge
    cd(savePath);
    %
    sceneExisted =dir(targetFormat);
    numScene = length(sceneExisted); saveIdx = int2str(numScene + 1);
    saveName = strcat(saveIdx, '.mat');
    sceneToFile(saveName, scene);
    
end

end