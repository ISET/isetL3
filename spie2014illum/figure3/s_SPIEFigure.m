  folder = pwd;
cd ~/scien/iset
isetPath(pwd)
cd ~/scien/L3
L3Path(pwd)
cd(folder);

clear all, clc, close all
s_initISET

lights = {{'Tungsten'},{'D65'},{'Fluorescent'}};%{{'Tungsten', 'D65'},{'Tungsten', 'D65', 'Fluorescent'},...
% lights = {{'Tungsten'},{'D65'}};
% {'Fluorescent', 'D65'},{'Fluorescent', 'D65', 'Tungsten'}};% {'D65'},{'Fluorescent'},{'Tungsten'}
cfas = {'RGBW1'};%,'Bayer'};
scenes = {'Vegetables','AsianFemaleWithFlowers'}; % AsianFemaleWithFlowers Natural100 Vegetables
% scenes = {'Natural100'}; % AsianFemaleWithFlowers Natural100 Vegetables
% figure%('Visible','off')


for ns = 1:length(scenes)
    for nl = 1:length(lights)
        for nc = 1:length(cfas)
            
            if strcmp(scenes{ns},'Natural100')
                scene = sceneCreateNatural100();
            else
                scene = sceneFromFile([scenes{ns} '.mat'],'multispectral');
            end
            sz = sceneGet(scene,'size');
%             if length(lights{nl}) > 1
                lname = [lights{nl}{1},num2str(length(lights{nl}))];
%             else
%                 lname = lights{nl}{1};
%             end
            
            load(['../QTtraindata/dataSimple/L3camera_',cfas{nc},'_','D651','.mat'])
            cameraD65 = camera;
            load(['../QTtraindata/dataSimple/L3camera_',cfas{nc},'_',lname,'.mat'])
            
            cameraD652 = L3ModifyCameraFG(cameraD65,cameraD65,1);
            
            [~, ~, ~, cameraD652, xyzIdeal, ~] = ...
                cameraComputesrgbNoCrop(cameraD652, scene, 60, sz, [], ...
                1,0,'D65');
            
            xyzIdeal = xyzIdeal / max(max(xyzIdeal(:,:,2)));
            srgbIdeal = xyz2srgb(xyzIdeal);
            imagesc(srgbIdeal(3:end-2,3:end-2,:)); axis off; axis equal; axis tight;
			%saveas(gcf,['srgbI_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(1),'.png'],'png');
            export_fig(['srgbI_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(1),'.png'],'-png','-transparent');
            export_fig(['srgbI_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(1),'.eps'],'-eps','-transparent');
%             imagesc(srgbResult(3:end-2,3:end-2,:)); axis off; axis equal; axis tight;
% 			%saveas(gcf,['srgbR_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(1),'.png'],'png');
%             export_fig(['srgbR_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(1),'.png'],'-png','-transparent');
%             export_fig(['srgbR_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(1),'.eps'],'-eps','-transparent');

            
            cameraAlt = L3ModifyCameraFG(camera,cameraD65,2);
            
            [~, ~, cameraAlt, ~, xyzIdealTun, lrgbResult] = ...
                cameraComputesrgbNoCrop(cameraAlt, scene, 60, sz, [], ...
                1,0,lights{nl}{1});
            xyzResult = lrgb2xyz(lrgbResult);
            xyzResult = xyzResult / max(max(xyzResult(:,:,2)));
            srgbResult = xyz2srgb(xyzResult);
            xyzIdealTun = xyzIdealTun / max(max(xyzIdealTun(:,:,2)));
            srgbIdealTun = xyz2srgb(xyzIdealTun);
            imagesc(srgbIdealTun(3:end-2,3:end-2,:)); axis off; axis equal; axis tight;
			%saveas(gcf,['srgbI_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(2),'.png'],'png');
            export_fig(['srgbI_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(2),'.png'],'-png','-transparent');
            export_fig(['srgbI_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(2),'.eps'],'-eps','-transparent');
            imagesc(srgbResult(3:end-2,3:end-2,:)); axis off; axis equal; axis tight;
			%saveas(gcf,['srgbR_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(2),'.png'],'png');
            export_fig(['srgbR_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(2),'.png'],'-png','-transparent');
            export_fig(['srgbR_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(2),'.eps'],'-eps','-transparent');

            
            cameraAlt = L3ModifyCameraFG(camera,cameraD65,3);
            
            [srgbResult, srgbIdeal, raw, cameraAlt, xyzIdeal, lrgbResult] = ...
                cameraComputesrgbNoCrop(cameraAlt, scene, 60, sz, [], ...
                1,0,lights{nl}{1});

            xyzResult = lrgb2xyz(lrgbResult);
            xyzResult = xyzResult / max(max(xyzResult(:,:,2)));
            srgbResult = xyz2srgb(xyzResult);
          
%             imagesc(srgbIdeal(3:end-2,3:end-2,:)); axis off; axis equal; axis tight;
			%saveas(gcf,['srgbI_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(3),'.png'],'png');
%             export_fig(['srgbI_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(3),'.png'],'-png','-transparent');
%             export_fig(['srgbI_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(3),'.eps'],'-eps','-transparent');
            imagesc(srgbResult(3:end-2,3:end-2,:)); axis off; axis equal; axis tight;
			%saveas(gcf,['srgbR_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(3),'.png'],'png');
            export_fig(['srgbR_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(3),'.png'],'-png','-transparent');
            export_fig(['srgbR_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(3),'.eps'],'-eps','-transparent');
            
%             cameraAlt = L3ModifyCameraFG(camera,cameraD65,4);
            
%             [srgbResult, srgbIdeal, raw, cameraAlt, xyzIdeal, lrgbResult] = ...
%                 cameraComputesrgbNoCrop(cameraAlt, scene, 60, sz, [], ...
%                 1,0,lights{nl}{1});
%             
%             imagesc(srgbIdeal(3:end-2,3:end-2,:)); axis off; axis equal; axis tight;
% 			%saveas(gcf,['srgbI_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(4),'.png'],'png');
%             export_fig(['srgbI_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(4),'.png'],'-png','-transparent');
%             export_fig(['srgbI_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(4),'.eps'],'-eps','-transparent');
%             imagesc(srgbResult(3:end-2,3:end-2,:)); axis off; axis equal; axis tight;
% 			%saveas(gcf,['srgbR_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(4),'.png'],'png');
%             export_fig(['srgbR_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(4),'.png'],'-png','-transparent');
%             export_fig(['srgbR_',scenes{ns},'_',cfas{nc},'_',lname,'_opt',num2str(4),'.eps'],'-eps','-transparent');

            
            
        end
    end
end