% s_initISET

% load L3camera_RGBW1_Tungsten1
% cameraTun = camera;
% cameraTun = L3ModifyCameraFG(cameraTun,cameraTun,1);
% load L3camera_RGBW1_D651
% cameraD65 = camera;
% cameraD65 = L3ModifyCameraFG(cameraD65,cameraD65,1);
% 
%  scene = sceneFromFile('AsianWoman.mat','multispectral')
%  sz = sceneGet(scene,'size');
% 
% [~, ~, rawTun, cameraTun, ~, lrgbTun] = ...
% cameraComputesrgbNoCrop(cameraTun, scene, 60, sz, [], ...
% 1,0,'Tungsten');
% imagesc(rawTun/max(rawTun(:)))
% [~, ~, rawD65, cameraD65, ~, lrgbD65] = ...
% cameraComputesrgbNoCrop(cameraD65, scene, 60, sz, [], ...
% 1,0,'D65');
% imagesc(rawD65/max(rawD65(:)))

plot(reshape(rawD65(1:2:end,1:2:end),1,[]),...
reshape(rawTun(1:2:end,1:2:end),1,[]),...
'+','Color',[.8,0,0],'LineWidth',2), axis equal, grid on, xlim([-0.0000000001 1.79999]), ylim([-0.0000000001 1.79999])
hold all
plot([-0.0000000001 1.79999],[-0.0000000001 1.79999],'k--','LineWidth',2)
hold off
set(gca,'FontSize',14,'FontWeight','b')
export_fig('R.png','-png','-transparent')

plot(reshape(rawD65(1:2:end,2:2:end),1,[]),...
reshape(rawTun(1:2:end,2:2:end),1,[]),...
'+','Color',[0,.8,0],'LineWidth',2), axis equal, grid on, xlim([-0.0000000001 1.79999]), ylim([-0.0000000001 1.79999])
hold all
plot([-0.0000000001 1.79999],[-0.0000000001 1.79999],'k--','LineWidth',2)
hold off
set(gca,'FontSize',14,'FontWeight','b')
export_fig('G.png','-png','-transparent')

plot(reshape(rawD65(2:2:end,1:2:end),1,[]),...
reshape(rawTun(2:2:end,1:2:end),1,[]),...
'+','Color',[.8,.8,.8],'LineWidth',2), axis equal, grid on, xlim([-0.0000000001 1.8]), ylim([-0.0000000001 1.8])
hold all
plot([-0.0000000001 1.8],[-0.0000000001 1.8],'k--','LineWidth',2)
hold off
set(gca,'FontSize',14,'FontWeight','b')
export_fig('W.png','-png','-transparent')

plot(reshape(rawD65(2:2:end,2:2:end),1,[]),...
reshape(rawTun(2:2:end,2:2:end),1,[]),...
'+','Color',[0,0,.8],'LineWidth',2), axis equal, grid on, xlim([-0.0000000001 1.79999]), ylim([-0.0000000001 1.79999])
hold all
plot([-0.0000000001 1.79999],[-0.0000000001 1.79999],'k--','LineWidth',2)
hold off
set(gca,'FontSize',14,'FontWeight','b')
export_fig('B.png','-png','-transparent')

imagesc(lrgb2srgb(ieClip(lrgbD65/max(lrgbD65(:)))))
axis off, axis equal
export_fig('D65.png','-png','-transparent')

imagesc(lrgb2srgb(ieClip(lrgbTun/max(lrgbTun(:)))))
axis off, axis equal
export_fig('Tun.png','-png','-transparent')