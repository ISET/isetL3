folder = pwd;
cd ~/scien/iset
isetPath(pwd)
cd ~/scien/L3
L3Path(pwd)
cd(folder);

clear all, clc, close all
s_initISET

scene = sceneCreate('nature100');

lights = {'D65','Tungsten','Fluorescent'};
cfas = {'RGBW1','Bayer'};
opts = [2 3];% 5];

resultsDE = repmat(struct('light',[],'cfa',[],'opt',[],'XYZ',[],'tgtXYZ',[],'estXYZ',[],'dE',[]),[length(lights),length(cfas),length(opts)]);

for nc = 1:length(cfas)
  for nl = 1:length(lights)
    for nopt = 1:length(opts)
      opt = opts(nopt);
      
      close all
      sz = sceneGet(scene,'size');
      
      load(['../QTtraindata/data/L3camera_',cfas{nc},'_','D65','.mat'])
      cameraD65 = camera;
      load(['../QTtraindata/data/L3camera_',cfas{nc},'_',lights{nl},'.mat'])
      load results
      camera.vci.L3.globaltrMFG = results(nl,nc).tgtXYZ'/results(nl,nc).estXYZ';
      
      
      cameraAlt = L3ModifyCameraFG(camera,cameraD65,opt);
      
      [srgbResult, srgbIdeal, raw, cameraAlt, xyzIdeal, lrgbResult] = ...
        cameraComputesrgbNoCrop(cameraAlt, scene, 70, sz, [], ...
        1,0,lights{nl});
      
      if strcmp(lights{nl},'D65')
        srgbIdealD65 = srgbIdeal;
        xyzIdealD65 = xyzIdeal;
      end
      
      imagesc(srgbIdeal); axis off; axis equal; axis tight;
      imagesc(srgbResult); axis off; axis equal; axis tight;
      
      %% Collect up the chart ip data and the original XYZ
      
      % Use this to select by hand, say the chart is embedded in another image
      % cp = chartCornerpoints(ip);   % Corner points are (x,y) format
      
      % If the chart occupies the entire image, then cp can be the whole image
      %
      sz = [size(srgbIdeal,1),size(srgbIdeal,2)];  % This could be a little routine.
      cp(1,1) = 2;     cp(1,2) = sz(1)-1;
      cp(2,1) = sz(2); cp(2,2) = sz(1)-1;
      cp(3,1) = sz(2); cp(3,2) = 1;
      cp(4,1) = 2;     cp(4,2) = 1;
      
      % Number of rows/cols in the patch array
      XYZ = scene.chartP.XYZ;
      XYZ = RGB2XWFormat(XYZ);
      r = scene.chartP.rowcol(1);  % This show be a sceneGet.
      c = scene.chartP.rowcol(2);
      
      [mLocs,pSize] = chartRectanglesFG(cp,r,c);
      
      % % Seems OK
      % for ii=1:size(mLocs,2)
      %     hold on
      %     plot(mLocs(2,ii),mLocs(1,ii),'o'); hold on;
      % end
      
      matrix = colorTransformMatrix('lrgb2xyz');
      xyzResult = imageLinearTransform(lrgbResult, matrix);
      
      % These are down the first column, starting at the upper left.
      delta = round(min(pSize)/4);   % Central portion of the patch
      % mRGB  = chartPatchData(ip,mLocs,delta);
      tgtXYZ = zeros(size(mLocs,2),3);
      estXYZ = zeros(size(mLocs,2),3);
      for ii=1:size(mLocs,2)
        tgtXYZ(ii,:) = squeeze(mean(mean(xyzIdealD65(mLocs(1,ii)+(-delta:delta),mLocs(2,ii)+(-delta:delta),:),1),2));
        estXYZ(ii,:) = squeeze(mean(mean(xyzResult(mLocs(1,ii)+(-delta:delta),mLocs(2,ii)+(-delta:delta),:),1),2));
      end
      
%             rectHandles = chartDrawRects(ip,mLocs,delta,'on'); pause(1);
%             chartDrawRects(ip,mLocs,delta,'off');
      
      %% Color error analyses
      
%       XYZ = mRGB*L;
%       L = mRGB\XYZ;
%       estXYZ = mRGB*L;
%       for i = 1:3
%           tgtXYZ(:,i) = tgtXYZ(:,i) / tgtXYZ(101,i);
%           estXYZ(:,i) = estXYZ(:,i) / estXYZ(101,i);
%       end
      
      vcNewGraphWin([],'tall');
      subplot(2,1,1)
      plot(tgtXYZ(:),estXYZ(:),'o')
      xlabel('True XYZ'); ylabel('Estimated XYZ');
      grid on
      
      % LAB comparisons
      tmp = XW2RGBFormat(tgtXYZ,r,c);
      whiteXYZ = tgtXYZ(101,:);
      cielab = xyz2lab(tmp,whiteXYZ);
      cielab = RGB2XWFormat(cielab);
      
      tmp = XW2RGBFormat(estXYZ,r,c);
      whiteXYZ = estXYZ(101,:);
      estCielab = xyz2lab(tmp,whiteXYZ);
      estCielab = RGB2XWFormat(estCielab);
      
      subplot(2,1,2)
      plot(cielab(:,1), estCielab(:,1),'ko', ...
        cielab(:,2), estCielab(:,2),'rs',...
        cielab(:,3),estCielab(:,3),'bx');
      grid on;
      axis equal
      
      xlabel('True LAB'); ylabel('Estimated LAB');
      legend({'L*','a*','b*'},'Location','SouthEast')
      
      
      %% Show the two images
      vcNewGraphWin([],'tall');
      subplot(2,1,1), image(xyz2srgb(XW2RGBFormat(tgtXYZ/max(tgtXYZ(:)),r,c)));
      subplot(2,1,2), image(xyz2srgb(XW2RGBFormat(estXYZ/max(tgtXYZ(:)),r,c)));
      
      %% Error histogram
      vcNewGraphWin;
      dE = deltaEab(tgtXYZ,estXYZ,tgtXYZ(101,:));
      hist(dE,30);
      xlabel('\Delta E')
      ylabel('Count');
      v = sprintf('%.1f',mean(dE(:)));
      title(['Mean \Delta E ',v])
      
      fprintf('%s %s %d %.1f\n',lights{nl},cfas{nc},opt,mean(dE));
      
      resultsDE(nl,nc,nopt).light = lights{nl};
      resultsDE(nl,nc,nopt).cfa = cfas{nc};
      resultsDE(nl,nc,nopt).opt = opt;
      resultsDE(nl,nc,nopt).XYZ = XYZ;
      resultsDE(nl,nc,nopt).tgtXYZ = tgtXYZ;
      resultsDE(nl,nc,nopt).estXYZ = estXYZ;
      resultsDE(nl,nc,nopt).dE = dE;
      
     return
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
      pause(0.01)
    end
  end
end

save resultsDE results