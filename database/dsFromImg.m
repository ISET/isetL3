function savePath = dsFromImg(dsPath, savePath, imgFormat)
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
    scene = sceneFromFile(imgName, 'rgb', 110, 'LCD-Apple');
    scene = sceneSet(scene, 'fov', 20);
    
    % Save the iamge
    cd(savePath);
    %
    sceneExisted =dir(targetFormat);
    numScene = length(sceneExisted); saveIdx = int2str(numScene + 1);
    saveName = strcat(saveIdx, '.mat');
    sceneToFile(saveName, scene, 10);
    
end

end