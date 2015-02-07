folder = pwd;
cd ~/scien/iset
isetPath(pwd)
cd ~/scien/L3
L3Path(pwd)
cd(folder);

% clear all, clc, close all
% s_initISET

scene = sceneCreate('nature100');

cameras = {{'D65'},{'B10000'},{'Tungsten'}};
lights = {{'D65'},{'Tungsten'},{'B10000'}};
% {'D65'},{'Tungsten'},{'Fluorescent'}, {'Tungsten','D65'},{'Tungsten','D65','Fluorescent'}, {'Fluorescent','D65'},{'Fluorescent','D65','Tungsten'}
cfas = {'RGBW1'};%,'Bayer'};
opts = [6];

% lights = {'D65','Tungsten'};
% cfas = {'Bayer'};

results = repmat(struct('light',[],'cfa',[],'opt',[],'XYZ',[],'tgtXYZ',[],'estXYZ',[],'dE',[]),[length(lights),length(cfas),length(opts)]);

for nl = 1:length(cameras)
    for nc = 1:length(cfas)
        for nopt = 1:length(opts)
            
            opt = opts(nopt);
            sz = sceneGet(scene,'size');
            
            %             if length(lights{nl}{1}) > 1
            lname = [cameras{nl}{1},num2str(length(cameras{nl}))];
            %             else
            %                 lname = lights{nl}{1}{1};
            %             end
            for nll = 1:length(lights)
                
                llname = [lights{nll}{1},num2str(length(lights{nll}))];
                
                load(['../QTtraindata/data/L3camera_',cfas{nc},'_',llname,'.mat'])
                cameraD65 = camera;
                load(['../QTtraindata/data/L3camera_',cfas{nc},'_',lname,'.mat'])
                
                cameraAlt = L3ModifyCameraFG(camera,cameraD65,opt);
                
                [srgbResult, srgbIdeal, raw, cameraAlt, xyzIdeal, lrgbResult] = ...
                    cameraComputesrgbNoCrop(cameraAlt, scene, 60, sz, [], ...
                    1,0,cameras{nl}{1});
                
                if strcmp(cameras{nl}{1},'D65') && strcmp(lights{nll}{1},'D65')
                    srgbIdealD65 = srgbIdeal;
                    xyzIdealD65 = xyzIdeal;
                end
                
                %             imagesc(srgbIdeal); axis off; axis equal; axis tight;
                imagesc(srgbResult); axis off; axis equal; axis tight;
                
                %% Collect up the chart ip data and the original XYZ
                % Use this to select by hand, say the chart is embedded in another image
                % cp = chartCornerpoints(ip); % Corner points are (x,y) format
                % If the chart occupies the entire image, then cp can be the whole image
                %
                sz = [size(srgbIdeal,1),size(srgbIdeal,2)]; % This could be a little routine.
                cp(1,1) = 3; cp(1,2) = sz(1)-2;
                cp(2,1) = sz(2)-1; cp(2,2) = sz(1)-2;
                cp(3,1) = sz(2)-1; cp(3,2) = 2;
                cp(4,1) = 3; cp(4,2) = 2;
                % Number of rows/cols in the patch array
                XYZ = scene.chartP.XYZ;
                XYZ = RGB2XWFormat(XYZ);
                r = scene.chartP.rowcol(1); % This show be a sceneGet.
                c = scene.chartP.rowcol(2);
                [mLocs,pSize] = chartRectanglesFG(cp,r,c);
                % % Seems OK
                % for ii=1:size(mLocs,2)
                % hold on
                % plot(mLocs(2,ii),mLocs(1,ii),'o'); hold on;
                % end
                xyzResult = lrgb2xyz(lrgbResult);
                % These are down the first column, starting at the upper left.
                delta = round(min(pSize)/4); % Central portion of the patch
                % mRGB = chartPatchData(ip,mLocs,delta);
                tgtXYZ = zeros(size(mLocs,2),3);
                estXYZ = zeros(size(mLocs,2),3);
                for ii=1:size(mLocs,2)
                    tgtXYZ(ii,:) = squeeze(mean(mean(xyzIdealD65(mLocs(1,ii)+(-delta:delta),mLocs(2,ii)+(-delta:delta),:),1),2));
                    estXYZ(ii,:) = squeeze(mean(mean(xyzResult(mLocs(1,ii)+(-delta:delta),mLocs(2,ii)+(-delta:delta),:),1),2));
                end
                % rectHandles = chartDrawRects(ip,mLocs,delta,'on'); pause(1);
                % chartDrawRects(ip,mLocs,delta,'off');
                %% Color error analyses
                % XYZ = mRGB*L
                % L = mRGB\XYZ;
                % estXYZ = mRGB*L;
                
                whiteXYZ = tgtXYZ(101,:);
%                 whiteXYZEst = estXYZ(101,:);
%                 estXYZ = estXYZ * mean(whiteXYZ) / mean(whiteXYZEst);
                
                figure(1);
                plot(tgtXYZ(:),estXYZ(:),'o')
                xlabel('True XYZ','FontSize',16,'FontWeight','b'); ylabel('Estimated XYZ','FontSize',16,'FontWeight','b');
                grid on
                set(gca,'FontSize',16,'FontWeight','b')
                export_fig(['XYZ_',lname,'_',cfas{nc},'_',num2str(opt),'.png'],'-png','-transparent')
                export_fig(['XYZ_',lname,'_',cfas{nc},'_',num2str(opt),'.eps'],'-eps','-transparent')
                
                % LAB comparisons
                % vcNewGraphWin;
                tmp = XW2RGBFormat(tgtXYZ,r,c);
                cielab = xyz2lab(tmp,whiteXYZ);
                cielab = RGB2XWFormat(cielab);
                tmp = XW2RGBFormat(estXYZ,r,c);
                estCielab = xyz2lab(tmp,whiteXYZ);
                estCielab = RGB2XWFormat(estCielab);
                plot(cielab(:,1), estCielab(:,1),'ko', ...
                    cielab(:,2), estCielab(:,2),'rs',...
                    cielab(:,3),estCielab(:,3),'bx',...
                    'LineWidth',2,'MarkerSize',9);
                grid on;
                axis equal
                xlabel('True LAB','FontSize',16,'FontWeight','b'); ylabel('Estimated LAB','FontSize',16,'FontWeight','b');
                legend({'L*','a*','b*'},'Location','SouthEast','FontSize',16,'FontWeight','b')
                set(gca,'FontSize',16,'FontWeight','b')
                export_fig(['LAB_',lname,'_',cfas{nc},'_',num2str(opt),'.png'],'-png','-transparent')
                export_fig(['LAB_',lname,'_',cfas{nc},'_',num2str(opt),'.eps'],'-eps','-transparent')
                
                %             %% Show the two images
                %             vcNewGraphWin([],'tall');
                %             subplot(2,1,1), image(xyz2srgb(XW2RGBFormat(tgtXYZ/max(tgtXYZ(:)),r,c)));
                %             axis off; axis equal; axis tight;
                %             subplot(2,1,2), image(xyz2srgb(XW2RGBFormat(estXYZ/max(tgtXYZ(:)),r,c)));
                %             axis off; axis equal; axis tight;
                %% Error histogram
                % vcNewGraphWin;
                dE = deltaEab(tgtXYZ,estXYZ,tgtXYZ(101,:));
                hist(dE,0:20);
                xlabel('\Delta E','FontSize',16,'FontWeight','b')
                ylabel('Count','FontSize',16,'FontWeight','b');
                v = sprintf('%.1f',mean(dE(:)));
                title(['Mean \Delta E ',v],'FontSize',16,'FontWeight','b')
                xlim([-0.5 20.5])
                set(gca,'FontSize',16,'FontWeight','b')
                
                export_fig(['Hist20_',lname,'_',cfas{nc},'_',num2str(opt),'.png'],'-png','-transparent')
                export_fig(['Hist20_',lname,'_',cfas{nc},'_',num2str(opt),'.eps'],'-eps','-transparent')
                
                xlim([-0.5 15.5])
                export_fig(['Hist15_',lname,'_',cfas{nc},'_',num2str(opt),'.png'],'-png','-transparent')
                export_fig(['Hist15_',lname,'_',cfas{nc},'_',num2str(opt),'.eps'],'-eps','-transparent')
                
                
                fprintf('%s %s %s %d %.1f %.1f %.1f\n',lname,lights{nll}{1},cfas{nc},opt,mean(dE),std(dE),prctile(dE,90));
                
%                 results(nl,nc,nopt).light = lights{nl}{1};
%                 results(nl,nc,nopt).cfa = cfas{nc};
%                 results(nl,nc,nopt).opt = opt;
%                 results(nl,nc,nopt).XYZ = XYZ;
%                 results(nl,nc,nopt).tgtXYZ = tgtXYZ;
%                 results(nl,nc,nopt).estXYZ = estXYZ;
%                 results(nl,nc,nopt).dE = dE;
%                 results(nl,nc,nopt).meandE = mean(dE);
%                 results(nl,nc,nopt).stddE = std(dE);
%                 results(nl,nc,nopt).percdE = prctile(dE,90);
                
                %       [tgtXYZ(101,:)./estXYZ(101,:)]
                %       pause
                %       pause
                %
                %       tgtXYZ = XYZ * mean(estXYZ(101,:)) / mean(XYZ(101,:));
                %
                %       % XYZ = mRGB*L
                %       L = estXYZ\tgtXYZ;
                %       estXYZ = estXYZ*L;
                %
                %       vcNewGraphWin([],'tall');
                %       subplot(2,1,1)
                %       plot(tgtXYZ(:),estXYZ(:),'o')
                %       xlabel('True XYZ'); ylabel('Estimated XYZ');
                %       grid on
                %
                %       % LAB comparisons
                %       tmp = XW2RGBFormat(tgtXYZ,r,c);
                %       whiteXYZ = tgtXYZ(101,:);
                %       cielab = xyz2lab(tmp,whiteXYZ);
                %       cielab = RGB2XWFormat(cielab);
                %
                %       tmp = XW2RGBFormat(estXYZ,r,c);
                %       whiteXYZ = estXYZ(101,:);
                %       estCielab = xyz2lab(tmp,whiteXYZ);
                %       estCielab = RGB2XWFormat(estCielab);
                %
                %       subplot(2,1,2)
                %       plot(cielab(:,1), estCielab(:,1),'ko', ...
                %         cielab(:,2), estCielab(:,2),'rs',...
                %         cielab(:,3),estCielab(:,3),'bx');
                %       grid on;
                %       axis equal
                %
                %       xlabel('True LAB'); ylabel('Estimated LAB');
                %       legend({'L*','a*','b*'},'Location','SouthEast')
                %
                %
                %       %% Show the two images
                %       vcNewGraphWin([],'tall');
                %       subplot(2,1,1), image(xyz2srgb(XW2RGBFormat(tgtXYZ,r,c)));
                %       subplot(2,1,2), image(xyz2srgb(XW2RGBFormat(estXYZ,r,c)));
                %
                %       %% Error histogram
                %       vcNewGraphWin;
                %       dE = deltaEab(tgtXYZ,estXYZ,tgtXYZ(101,:));
                %       hist(dE,30);
                %       xlabel('\Delta E')
                %       ylabel('Count');
                %       v = sprintf('%.1f',mean(dE(:)));
                %       title(['Mean \Delta E ',v])
                %
                %       pause
                %% End
            end
        end
    end
end

save results results
