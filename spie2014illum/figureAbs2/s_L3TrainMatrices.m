
cameras = {'D65','Tungsten','Fluorescent','Tungsten20','D6520','Fluorescent20'};
lights = {'D65','Tungsten','Fluorescent'};
cfas = {'Bayer','RGBW1'};

for ncam = 1:length(cameras)
    for ncfa = 1:length(cfas)
        
        load(['L3camera_',cfas{ncfa},'_',cameras{ncam}]);
        load(['L3_',cfas{ncfa},'_',cameras{ncam}]);
        
        camera = L3ModifyCamera(camera,camera,1);
        
        scenes = L3.scene;
        nscenes = length(scenes);
        
        desiredIm = cell(nscenes,1);
        inputIm = cell(nscenes,1);
        
        for nl = 1:length(lights)
            for ii = 1:nscenes
                scene = L3Get(L3,'scene',ii);
                sz = sceneGet(scene,'size');
                oi     = cameraGet(camera,'oi');
                sensor = cameraGet(camera,'sensor');
                sDist  = sceneGet(scene,'distance');
                scenefov = sensorGet(sensor,'fov',sDist,oi);
                scene = sceneSet(scene,'fov',scenefov);
                
                scene = sceneAdjustIlluminant(scene,'D65.mat');
                
                [~,xyzIdeal] = cameraCompute(camera,scene,'idealxyz');
                
                scene = sceneAdjustIlluminant(scene,[lights{nl},'.mat']);
                
                [~,lrgbResult] = cameraCompute(camera,scene,[],false);
                xyzResult = lrgb2xyz(lrgbResult);
                
                
                
            end
        end
    end
end
