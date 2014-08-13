folder = pwd;
cd ~/Stanford/iset
isetPath(pwd)
cd ~/Stanford/L3
L3Path(pwd)
cd(folder);

clear all, clc, close all
s_initISET

lights = {'D65','Tungsten','Fluorescent'};
cfas = {'Bayer'};

for nl = 1:length(lights)
  for nc = 1:length(cfas)
    
    load(['../QTtraindata/data/L3camera_',cfas{nc},'_D65.mat'])
    cameraD65 = L3ModifyCamera(camera,1);
    cameraD65.sensor.noiseFlag = 0;    
    
    load(['../QTtraindata/data/L3camera_',cfas{nc},'_',lights{nl},'.mat'])
    cameraAlt = L3ModifyCamera(camera,1);
    cameraD65.sensor.noiseFlag = 0;    
    
    clear camera
    
    scene = sceneFromFile('Vegetables.mat','multispectral');
    sz = sceneGet(scene,'size');
    sz = round(sz/4);
    
    [srgbResult, srgbIdeal, raw, cameraAlt, xyzIdeal, lrgbResult, srgbResult2, cameraD65, lrgbResult2] = ...
    cameraComputesrgbNoCrop2Cams(cameraAlt, scene, 80, sz, [], ...
    1,0,lights{nl},cameraD65);
  
    data = cameraD65.sensor.data.volts / max(cameraD65.sensor.data.volts(:)); data = data.^.25;
    [X,Y] = meshgrid(1:size(data,1),1:size(data,2)); X = X(:); Y = Y(:);
    pic = zeros(3,numel(data));
    pic(1,mod(X,2)==1 & mod(Y,2)==1) = pic(1,mod(X,2)==1 & mod(Y,2)==1) + data(mod(X,2)==1 & mod(Y,2)==1)';
    pic(2,mod(X,2)==0 & mod(Y,2)==1) = pic(2,mod(X,2)==0 & mod(Y,2)==1) + data(mod(X,2)==0 & mod(Y,2)==1)';
    pic(3,mod(X,2)==0 & mod(Y,2)==0) = pic(3,mod(X,2)==0 & mod(Y,2)==0) + data(mod(X,2)==0 & mod(Y,2)==0)';
    pic(2,mod(X,2)==1 & mod(Y,2)==0) = pic(2,mod(X,2)==1 & mod(Y,2)==0) + data(mod(X,2)==1 & mod(Y,2)==0)';
%     pic(1,mod(X,2)==1 & mod(Y,2)==0) = pic(1,mod(X,2)==1 & mod(Y,2)==0) + data(mod(X,2)==1 & mod(Y,2)==0)';
%     pic(2,mod(X,2)==1 & mod(Y,2)==0) = pic(2,mod(X,2)==1 & mod(Y,2)==0) + data(mod(X,2)==1 & mod(Y,2)==0)';
%     pic(3,mod(X,2)==1 & mod(Y,2)==0) = pic(3,mod(X,2)==1 & mod(Y,2)==0) + data(mod(X,2)==1 & mod(Y,2)==0)';
    pic = permute(reshape(pic,3,size(data,1),size(data,2)),[2 3 1]);
    imagesc(pic); axis off; axis equal; axis tight; export_fig(['sensor_','D65','.png'],'-png','-transparent');
    
    data = cameraAlt.sensor.data.volts / max(cameraAlt.sensor.data.volts(:)); data = data.^.25;
    [X,Y] = meshgrid(1:size(data,1),1:size(data,2)); X = X(:); Y = Y(:);
    pic = zeros(3,numel(data));
    pic(1,mod(X,2)==1 & mod(Y,2)==1) = pic(1,mod(X,2)==1 & mod(Y,2)==1) + data(mod(X,2)==1 & mod(Y,2)==1)';
    pic(2,mod(X,2)==0 & mod(Y,2)==1) = pic(2,mod(X,2)==0 & mod(Y,2)==1) + data(mod(X,2)==0 & mod(Y,2)==1)';
    pic(3,mod(X,2)==0 & mod(Y,2)==0) = pic(3,mod(X,2)==0 & mod(Y,2)==0) + data(mod(X,2)==0 & mod(Y,2)==0)';
    pic(2,mod(X,2)==1 & mod(Y,2)==0) = pic(2,mod(X,2)==1 & mod(Y,2)==0) + data(mod(X,2)==1 & mod(Y,2)==0)';
%     pic(1,mod(X,2)==1 & mod(Y,2)==0) = pic(1,mod(X,2)==1 & mod(Y,2)==0) + data(mod(X,2)==1 & mod(Y,2)==0)';
%     pic(2,mod(X,2)==1 & mod(Y,2)==0) = pic(2,mod(X,2)==1 & mod(Y,2)==0) + data(mod(X,2)==1 & mod(Y,2)==0)';
%     pic(3,mod(X,2)==1 & mod(Y,2)==0) = pic(3,mod(X,2)==1 & mod(Y,2)==0) + data(mod(X,2)==1 & mod(Y,2)==0)';
    pic = permute(reshape(pic,3,size(data,1),size(data,2)),[2 3 1]);
    imagesc(pic); axis off; axis equal; axis tight; export_fig(['sensor_',lights{nl},'.png'],'-png','-transparent');
    
    imagesc(srgbIdeal); axis off; axis equal; axis tight; export_fig(['srgb_',lights{nl},'.png'],'-png','-transparent');
    
  end
end