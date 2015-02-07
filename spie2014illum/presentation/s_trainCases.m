s_initISET

load L3camera_RGBW1_Tungsten1
cameraTun = camera;
cameraTun = L3ModifyCameraFG(cameraTun,cameraTun,1);
load L3camera_RGBW1_D651
cameraD65 = camera;
cameraD65 = L3ModifyCameraFG(cameraD65,cameraD65,1);

load('people_small_1_scene.mat')
sz = sceneGet(scene,'size');

[~, ~, rawTun, cameraTun, ~, lrgbTun] = ...
cameraComputesrgbNoCrop(cameraTun, scene, 60, sz, [], ...
1,0,'Tungsten');
imagesc(rawTun/max(rawTun(:))), axis equal, axis off
colormap('gray')
export_fig('sensor1Tun.png','-png','-transparent')

[~, ~, rawD65, cameraD65, ~, lrgbD65] = ...
cameraComputesrgbNoCrop(cameraD65, scene, 60, sz, [], ...
1,0,'D65');
imagesc(rawD65/max(rawD65(:))), axis equal, axis off
colormap('gray')
export_fig('sensor1D65.png','-png','-transparent')

imagesc(lrgb2srgb(ieClip(lrgbTun(3:end-2,3:end-2,:)/max(lrgbTun(:)))))
axis off, axis equal
export_fig('pic1Tun.png','-png','-transparent')

imagesc(lrgb2srgb(ieClip(lrgbD65(3:end-2,3:end-2,:)/max(lrgbD65(:)))))
axis off, axis equal
export_fig('pic1D65.png','-png','-transparent')

%%

load('people_small_2_scene.mat')
sz = sceneGet(scene,'size');

[~, ~, rawTun, cameraTun, ~, lrgbTun] = ...
cameraComputesrgbNoCrop(cameraTun, scene, 60, sz, [], ...
1,0,'Tungsten');
imagesc(rawTun/max(rawTun(:))), axis equal, axis off
colormap('gray')
export_fig('sensor2Tun.png','-png','-transparent')

[~, ~, rawD65, cameraD65, ~, lrgbD65] = ...
cameraComputesrgbNoCrop(cameraD65, scene, 60, sz, [], ...
1,0,'D65');
imagesc(rawD65/max(rawD65(:))), axis equal, axis off
colormap('gray')
export_fig('sensor2D65.png','-png','-transparent')

imagesc(lrgb2srgb(ieClip(lrgbTun(3:end-2,3:end-2,:)/max(lrgbTun(:)))))
axis off, axis equal
export_fig('pic2Tun.png','-png','-transparent')

imagesc(lrgb2srgb(ieClip(lrgbD65(3:end-2,3:end-2,:)/max(lrgbD65(:)))))
axis off, axis equal
export_fig('pic2D65.png','-png','-transparent')