close all
s_initISET

load L3camera_Bayer_D65
camera = modifyCamera(camera,1);
targetLuminance = 80;

figure(1)

% Natural scene
scene = sceneFromFile('AsianWoman_1.mat', 'multispectral');
sz = sceneGet(scene, 'size'); % output size, here set to scene size

[srgbResult, srgbIdeal, raw, camera] =...
  cameraComputesrgbNoCrop(camera,scene,targetLuminance,sz,[],1,0);

figure(1)
subplot(1,4,1)
imagesc(srgbIdeal); title('(a)'); axis image, axis off
% export_fig -png -transparent AsianWoman.png
% close all

% Macbeth chart
scene = sceneCreate();
sz = sceneGet(scene, 'size'); % output size, here set to scene size

[srgbResult, srgbIdeal, raw, camera] =...
  cameraComputesrgbNoCrop(camera,scene,targetLuminance,sz,[],1,0);

figure(1)
subplot(1,4,2)
imagesc(srgbIdeal); title('(b)'); axis image, axis off
% export_fig -png -transparent MacBeth.png
% close all

% Extended chart
scene = sceneCreate('reflectance chart');
sz = sceneGet(scene, 'size'); % output size, here set to scene size

[srgbResult, srgbIdeal, raw, camera] =...
  cameraComputesrgbNoCrop(camera,scene,targetLuminance,sz,[],1,0);

figure(1)
subplot(1,4,3)
imagesc(srgbIdeal); title('(c)'); axis image, axis off
% export_fig -png -transparent RefChart.png
% close all

% Local chart
scene = sceneCreate('reflectance chart custom',bsxfun(@plus,sphereSampling(5,100),[50 20 -20]));
sz = sceneGet(scene, 'size'); % output size, here set to scene size

[srgbResult, srgbIdeal, raw, camera] =...
  cameraComputesrgbNoCrop(camera,scene,targetLuminance,sz,[],1,0);

figure(1)
subplot(1,4,4)
imagesc(srgbIdeal); title('(d)'); axis image, axis off
% export_fig -png -transparent RefChartCus.png
% close all

set(gcf,'Position',[150,600,900,200])
export_fig -png -transparent Data.png
