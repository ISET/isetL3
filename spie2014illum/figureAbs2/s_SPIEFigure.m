folder = pwd;
cd ~/Stanford/iset
isetPath(pwd)
cd ~/Stanford/L3
L3Path(pwd)
cd(folder);

clear all, clc, close all
s_initISET

lights = {'D65'};
cfas = {'RGBW1'};

for nl = 1:length(lights)
  for nc = 1:length(cfas)
    
    scene = sceneFromFile('Vegetables.mat','multispectral');
    sz = sceneGet(scene,'size');
    
    load(['../QTtraindata/data/L3camera_',cfas{nc},'_','D65','.mat'])
    cameraD65 = camera;
    load(['../QTtraindata/data/L3camera_',cfas{nc},'_',lights{nl},'.mat'])
    
    cameraAlt = L3ModifyCameraFG(camera,cameraD65,1);
    
    [srgbResult, srgbIdeal, raw, cameraAlt, xyzIdeal, lrgbResult] = ...
      cameraComputesrgbNoCrop(cameraAlt, scene, 60, sz, [], ...
      1,0,lights{nl});
    
    imagesc(srgbIdeal); axis off; axis equal; axis tight;
    export_fig(['srgbI_',cfas{nc},'_',lights{nl},'_opt',num2str(1),'.png'],'-png','-transparent');
    imagesc(srgbResult); axis off; axis equal; axis tight;
    export_fig(['srgbR_',cfas{nc},'_',lights{nl},'_opt',num2str(1),'.png'],'-png','-transparent');
    
    cameraAlt = L3ModifyCameraFG(camera,cameraD65,2);
    
    [srgbResult, srgbIdeal, raw, cameraAlt, xyzIdeal, lrgbResult] = ...
      cameraComputesrgbNoCrop(cameraAlt, scene, 60, sz, [], ...
      1,0,lights{nl});
    
    imagesc(srgbIdeal); axis off; axis equal; axis tight;
    export_fig(['srgbI_',cfas{nc},'_',lights{nl},'_opt',num2str(2),'.png'],'-png','-transparent');
    imagesc(srgbResult); axis off; axis equal; axis tight;
    export_fig(['srgbR_',cfas{nc},'_',lights{nl},'_opt',num2str(2),'.png'],'-png','-transparent');
    
    cameraAlt = L3ModifyCameraFG(camera,cameraD65,3);
    
    [srgbResult, srgbIdeal, raw, cameraAlt, xyzIdeal, lrgbResult] = ...
      cameraComputesrgbNoCrop(cameraAlt, scene, 60, sz, [], ...
      1,0,lights{nl});
    
    imagesc(srgbIdeal); axis off; axis equal; axis tight;
    export_fig(['srgbI_',cfas{nc},'_',lights{nl},'_opt',num2str(3),'.png'],'-png','-transparent');
    imagesc(srgbResult); axis off; axis equal; axis tight;
    export_fig(['srgbR_',cfas{nc},'_',lights{nl},'_opt',num2str(3),'.png'],'-png','-transparent');
    
    cameraAlt = L3ModifyCameraFG(camera,cameraD65,4);
    
    [srgbResult, srgbIdeal, raw, cameraAlt, xyzIdeal, lrgbResult] = ...
      cameraComputesrgbNoCrop(cameraAlt, scene, 60, sz, [], ...
      1,0,lights{nl});
    
    imagesc(srgbIdeal); axis off; axis equal; axis tight;
    export_fig(['srgbI_',cfas{nc},'_',lights{nl},'_opt',num2str(4),'.png'],'-png','-transparent');
    imagesc(srgbResult); axis off; axis equal; axis tight;
    export_fig(['srgbR_',cfas{nc},'_',lights{nl},'_opt',num2str(4),'.png'],'-png','-transparent');
    
    
  end
end