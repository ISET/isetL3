%folder = pwd;
%cd ~/Stanford/iset
%isetPath(pwd)
%cd ~/Stanford/L3
%L3Path(pwd)
%cd(folder);

clear all, clc, close all
s_initISET

lights = {'D65','Tungsten','Fluorescent'};
cfas = {'RGBW1','Bayer'};

results = repmat(struct('light',[],'cfa',[],'opt',[],'XYZ',[],'tgtXYZ',[],'estXYZ',[],'dE',[]),[length(lights),length(cfas)]);

load SRGBfeasible10.mat
SRGBfeasible = SRGBfeasible(2:end,:);
RefSRGBfeasible = RefSRGBfeasible(2:end,:);

I = randperm(length(SRGBfeasible));
I = I([1:end,1:100-mod(numel(I),100)]);
SRGBfeasible = SRGBfeasible(I,:);
RefSRGBfeasible = RefSRGBfeasible(I,:);
Ncharts = length(I)/100;

for ns = 1:1
%   scene = sceneCreate('reflectance chart prefilled',RefSRGBfeasible((ns-1)*100+1:ns*100,:)');
  scene = sceneCreate('nature100');
  %   vcAddObject(scene);
  %   sceneWindow
  
  [luminance,meanLuminance] = sceneCalculateLuminance(scene);
  targetLuminance = 100*meanLuminance/max(luminance(:));
  
  for nc = 1:length(cfas)
    for nl = 1:length(lights)
      
      
      close all
      sz = sceneGet(scene,'size');
      
      load(['../QTtraindata/data/L3camera_',cfas{nc},'_','D65','.mat'])
      cameraD65 = camera;
      load(['../QTtraindata/data/L3camera_',cfas{nc},'_',lights{nl},'.mat'])
      
      cameraAlt = L3ModifyCameraFG(camera,cameraD65,1);
      
      [srgbResult, srgbIdeal, raw, cameraAlt, xyzIdeal, lrgbResult] = ...
        cameraComputesrgbNoCrop(cameraAlt, scene, targetLuminance, sz, [], ...
        1,0,lights{nl});
      
      if strcmp(lights{nl},'D65')
        srgbIdealD65 = srgbIdeal;
        xyzIdealD65 = xyzIdeal;
      end
      
      subplot(2,1,1);imagesc(srgbIdeal); axis off; axis equal; axis tight;
      subplot(2,1,2);imagesc(srgbResult); axis off; axis equal; axis tight;
      
      %% Collect up the chart ip data and the original XYZ
      
      % Use this to select by hand, say the chart is embedded in another image
      % cp = chartCornerpoints(ip);   % Corner points are (x,y) format
      
      % If the chart occupies the entire image, then cp can be the whole image
      %
      sz = [size(srgbIdeal,1),size(srgbIdeal,2)];  % This could be a little routine.
      cp(1,1) = 3+24;     cp(1,2) = sz(1)-2-24;
      cp(2,1) = sz(2)-1-24; cp(2,2) = sz(1)-2-24;
      cp(3,1) = sz(2)-1-24; cp(3,2) = 2+24;
      cp(4,1) = 3+24;     cp(4,2) = 2+24;
      
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
      
      %       xyzResult = srgb2xyz(srgbResult);
      
      % These are down the first column, starting at the upper left.
      delta = round(min(pSize)/2);   % Central portion of the patch
      % mRGB  = chartPatchData(ip,mLocs,delta);
      tgtXYZ = zeros(size(mLocs,2),3);
      estXYZ = zeros(size(mLocs,2),3);
      for ii=1:size(mLocs,2)
        tgtXYZ(ii,:) = squeeze(mean(mean(xyzIdealD65(mLocs(1,ii)+(-delta:delta),mLocs(2,ii)+(-delta:delta),:),1),2));
        estXYZ(ii,:) = squeeze(mean(mean(xyzResult(mLocs(1,ii)+(-delta:delta),mLocs(2,ii)+(-delta:delta),:),1),2));
      end
      
      if ns ~= 1
        tgtXYZ = tgtXYZ(1:100,:);
        estXYZ = estXYZ(1:100,:);
        XYZ = XYZ(1:100,:);
      end
      
      %       rectHandles = chartDrawRects(ip,mLocs,delta,'on'); pause(1);
      %       chartDrawRects(ip,mLocs,delta,'off');
      
      %% Color error analyses
      
      % XYZ = mRGB*L
      % L = mRGB\XYZ;
      % estXYZ = mRGB*L;
      
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
      %       fprintf('%s %s\n',lights{nl},cfas{nc});
      
      results(nl,nc).light = lights{nl};
      results(nl,nc).cfa = cfas{nc};
      results(nl,nc).XYZ = [results(nl,nc).XYZ;XYZ];
      results(nl,nc).tgtXYZ = [results(nl,nc).tgtXYZ;tgtXYZ];
      results(nl,nc).estXYZ = [results(nl,nc).estXYZ;estXYZ];
      
      %% End
    end
  end
end

results3 = results;
save results3 results3
