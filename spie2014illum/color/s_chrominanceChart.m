
%%
% close all;clear all;clc
s_initISET

%% Make a reflectance chart and show it

% The XYZ values of the chart are in the scene.chartP structure

listCameras = dir('../data/L3camera*.mat');

% listScenes = [listScenes(1) listScenes(end)];

C = length(listCameras);

load LABfeasible10 LABfeasible Reffeasible

bounds = [ 40 -30 -60; 40 80 50];
boundShare{1} = [ 40 -20 -50; 40 70 40];
boundShare{2} = [ 70 -20 -50; 70 70 40];
N = 2;
Ntr = 10;
Nsam = 110;

mkdir('results2')

for nc = 1:C
  
  disp(listCameras(nc).name)
  results = repmat(struct('XYZ',zeros(Nsam,3,Ntr),'estXYZ',zeros(Nsam,3,Ntr),...
    'cielab',zeros(Nsam,3,Ntr),'estCielab',zeros(Nsam,3,Ntr)),N,1);
  
  k = strfind(listCameras(nc).name,'_');
  illum = listCameras(nc).name(k(end)+1:end-4);
  
  for nt = 1:N
    
    L = LABfeasible(:,1); a = LABfeasible(:,2); b = LABfeasible(:,3);
    
    I = L >= boundShare{nt}(1,1) & L <= boundShare{nt}(2,1) &...
      a >= boundShare{nt}(1,2) & a <= boundShare{nt}(2,2) &...
      b >= boundShare{nt}(1,3) & b <= boundShare{nt}(2,3);
        
    for nn = 1:Ntr
      %     disp(listScenes(nt).name)
      load(['../data/' listCameras(nc).name],'camera')
      camera = modifyCamera(camera,3);
      camera.sensor.noiseFlag = 0;
      scene = sceneCreate('reflectance chart prefilled', Reffeasible(I,:)');
      %     load(['scenes/' listScenes(nt).name],'scene')
      
      scene = sceneAdjustIlluminant(scene,[illum,'.mat']);
      
      %   scene = sceneAdjustLuminance(scene,200);
      %     vcAddObject(scene); sceneWindow;
      
      [luminance,meanLuminance] = sceneCalculateLuminance(scene);
      targetLuminance = 1*meanLuminance/luminance(1,end);
      
      sensorResize = 1;
      sz = sceneGet(scene,'size');
      %   [srgbResult, srgbIdeal, raw, camera] =...
      %   cameraComputesrgb(camera,scene,scene.chartP.luminance,[],[],1,0);
      [srgbResult, srgbIdeal, raw, camera, xyzIdeal, lrgbResult] =...
        cameraComputesrgbNoCrop(camera,scene,targetLuminance,sz,[],1,2);
      %     camera = cameraCompute(camera,scene,[],sensorResize);
%       cameraWindow(camera,'ip');
      
      ip = cameraGet(camera,'ip');
      
      %% Collect up the chart ip data and the original XYZ
      
      % Use this to select by hand, say the chart is embedded in another image
      % cp = chartCornerpoints(ip);   % Corner points are (x,y) format
      
      % If the chart occupies the entire image, then cp can be the whole image
      %
      sz = imageGet(ip,'size');  % This could be a little routine.
      cp(1,1) = 25;     cp(1,2) = sz(1)-24;
      cp(2,1) = sz(2)-24; cp(2,2) = sz(1)-24;
      cp(3,1) = sz(2)-24; cp(3,2) = 25;
      cp(4,1) = 25;     cp(4,2) = 25;
      
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
      
      % These are down the first column, starting at the upper left.
      delta = round(min(pSize)/2);   % Central portion of the patch
      
      mRGB  = chartPatchData(ip,mLocs,delta);
      
      xyzIdeal = RGB2XWFormat(xyzIdeal);
      mXYZ = zeros(size(mRGB));
      for ii = 1:size(mLocs,2)
        [rr,cc] = meshgrid(mLocs(1,ii)+(-round(delta/2)+(0:delta)),...
          mLocs(2,ii)+(-round(delta/2)+(0:delta)));
        jj = sub2ind(sz(1:2),rr(:),cc(:));
        mXYZ(ii,:) = mean(xyzIdeal(jj,:));
      end
      XYZ = mXYZ;
      
      rectHandles = chartDrawRects(ip,mLocs,delta,'on'); pause(1);
      chartDrawRects(ip,mLocs,delta,'off');
      
      %% Color error analyses
      
      % XYZ = mRGB*L
%       L = mRGB\XYZ;
%       estXYZ = mRGB*L;
      
      matrix = colorTransformMatrix('lrgb2xyz');
      mRGB = XW2RGBFormat(mRGB,r,c);
      estXYZ = imageLinearTransform(mRGB, matrix);
      estXYZ = RGB2XWFormat(estXYZ);
      
      estXYZ = estXYZ * max(XYZ(:)) / max(estXYZ(:));

      
      %     vcNewGraphWin([],'tall');
      figure
      subplot(2,1,1)
      plot(XYZ(:),estXYZ(:),'o')
      xlabel('True XYZ'); ylabel('Estimated XYZ');
      grid on
      
      % LAB comparisons
      tmp = XW2RGBFormat(XYZ,r,c);
      whiteXYZ = tmp(1,end,:);
      cielab = xyz2lab(tmp,whiteXYZ);
      cielab = RGB2XWFormat(cielab(:,1:end,:));
      
      tmp = XW2RGBFormat(estXYZ,r,c);
      whiteXYZ = tmp(1,end,:);
      estCielab = xyz2lab(tmp,whiteXYZ);
      estCielab = RGB2XWFormat(estCielab(:,1:end,:));
      
      subplot(2,1,2)
      plot(cielab(:,1), estCielab(:,1),'ko', ...
        cielab(:,2), estCielab(:,2),'rs',...
        cielab(:,3),estCielab(:,3),'bx');
      grid on;
      axis equal
      
      xlabel('True LAB'); ylabel('Estimated LAB');
      legend({'L*','a*','b*'},'Location','SouthEast')
      pause(1)
      
      %     %% Show the two images
          vcNewGraphWin([],'tall');
%       figure
      subplot(2,1,1), image(xyz2srgb(XW2RGBFormat(XYZ,r,c)));
      subplot(2,1,2), image(xyz2srgb(XW2RGBFormat(estXYZ,r,c)));
      
      results(nt).XYZ(:,:,nn) = XYZ;
      results(nt).estXYZ(:,:,nn) = estXYZ;
      results(nt).cielab(:,:,nn) = cielab;
      results(nt).estCielab(:,:,nn) = estCielab;
      
      %% Error histogram
      vcNewGraphWin;
      dE = deltaEab(XYZ(1:100,:),estXYZ(1:100,:),XYZ(101,:));
      hist(dE,30);
      xlabel('\Delta E')
      ylabel('Count');
      v = sprintf('%.1f',mean(dE(:)));
      title(['Mean \Delta E ',v])
      
      %% End
%       pause(1)
      return
      close all

    end
  end

  save(['results2/' listCameras(nc).name(1:end-4) '_results.mat'], 'results')
  
end
