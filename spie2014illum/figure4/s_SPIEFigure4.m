clear all, clc, close all
s_initISET

scene = sceneFromFile('CaucasianFemale.mat','multispectral');
sz = sceneGet(scene,'size');

load L3camera_RGBW_Tungsten
illum = 'Tungsten';

L = [1 80];

for i = 1:4
  
  for nl = 1:length(L)
    L3camera = modifyCamera(camera,i);
    l = L(nl);
      [srgbResult, srgbIdeal, raw, cameraTmp] = cameraComputesrgb_illum(L3camera,scene,l,sz,[],[],2,illum);
      figure; image(srgbResult); axis off, axis equal, export_fig(sprintf('result_op%d_l%d.mat',i,l),'-png','-transparent');
      figure; image(srgbIdeal); axis off, axis equal, export_fig(sprintf('ideal_op%d_l%d.mat',i,l),'-png','-transparent'); close all
    if i == 1
      [srgbResult, srgbIdeal, raw, cameraTmp] = cameraComputesrgb_illum(L3camera,scene,l,sz,[],[],2,'D65');
      figure; image(srgbResult); axis off, axis equal, export_fig(sprintf('resultD65_op%d_l%d.mat',i,l),'-png','-transparent');
      figure; image(srgbIdeal); axis off, axis equal, export_fig(sprintf('idealD65_op%d_l%d.mat',i,l),'-png','-transparent'); close all   
    end
      
  end
end

