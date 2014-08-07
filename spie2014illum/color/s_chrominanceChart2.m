
%%
% close all;clear all;clc
s_initISET

%% Make a reflectance chart and show it

% The XYZ values of the chart are in the scene.chartP structure

listCameras = dir('../data/L3camera*.mat');

% listScenes = [listScenes(1) listScenes(end)];

C = length(listCameras);

load LABfeasible100x100

N = 100;
Lum = [.1 .2 .5 1 2 5 10 20 50 100 200 500 1000 2000 5000];
Nlum = length(Lum);
Nsam = 110;

mkdir('results4')

for nc = 1:C
  
  disp(listCameras(nc).name)
  results = repmat(struct('XYZ',[],'inXYZ',[],'outXYZ',[],...
    'lum',[],'sat',[],'cluster',[]),N,Nlum);
  
  k = strfind(listCameras(nc).name,'_');
  illum = listCameras(nc).name(k(end)+1:end-4);
  
  for nt = 1:N
    
    I = (1:100) + (nt-1)*100;
    
    for nn = 1:Nlum
      %     disp(listScenes(nt).name)
      load(['../data/' listCameras(nc).name],'camera')
      camera = modifyCamera(camera,1);
      camera.sensor.noiseFlag = 0;
      scene = sceneCreate('reflectance chart prefilled', Reffeasible(I,:)');
      %     load(['scenes/' listScenes(nt).name],'scene')
      
      %   scene = sceneAdjustLuminance(scene,200);
      % vcAddObject(scene); sceneWindow;
      
      [luminance,meanLuminance] = sceneCalculateLuminance(scene);
      targetLuminance = Lum(nn)*meanLuminance/luminance(1,end);
      
      sz = sceneGet(scene,'size');
      %   [srgbResult, srgbIdeal, raw, camera] =...
      %   cameraComputesrgb(camera,scene,scene.chartP.luminance,[],[],1,0);
      [srgbResult, srgbIdeal, raw, camera, xyzIdeal, lrgbResult] =...
        cameraComputesrgbNoCrop(camera,scene,targetLuminance,sz,[],1,0,illum);
      %     camera = cameraCompute(camera,scene,[],sensorResize);
      % cameraWindow(camera,'ip');
      
      ip = cameraGet(camera,'ip');
      
      %% Collect up the chart ip data and the original XYZ
      
      % Use this to select by hand, say the chart is embedded in another image
      % cp = chartCornerpoints(ip);   % Corner points are (x,y) format
      
      % If the chart occupies the entire image, then cp can be the whole image
      %
      sz = imageGet(ip,'size');  % This could be a little routine.
      cp(1,1) = 1+24;     cp(1,2) = sz(1)-23;
      cp(2,1) = sz(2)-23; cp(2,2) = sz(1)-23;
      cp(3,1) = sz(2)-23; cp(3,2) = 1+24;
      cp(4,1) = 1+24;     cp(4,2) = 1+24;
      
      % Number of rows/cols in the patch array
      XYZ = scene.chartP.XYZ;
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
      
      XYZ = RGB2XWFormat(XYZ);
      xyzIdeal = RGB2XWFormat(xyzIdeal);
      xyzResult = RGB2XWFormat(camera.vci.L3.processing.xyz);
      lumIdx = RGB2XWFormat(camera.vci.L3.processing.lumIdx);
      satIdx = RGB2XWFormat(camera.vci.L3.processing.satIdx);
      cluIdx = RGB2XWFormat(camera.vci.L3.processing.clusterIdx);
      
      inXYZ = zeros(size(XYZ));
      outXYZ = zeros(size(XYZ));
      outLum = zeros(size(XYZ,1),1);
      outSat = zeros(size(XYZ,1),1);
      outClu = zeros(size(XYZ,1),1);
      
      for ii = 1:size(mLocs,2)
        theseLocs = chartROI(mLocs(:,ii),delta);
        indLoc = sub2ind(sz,theseLocs(:,1),theseLocs(:,2));
        lumLoc = lumIdx(indLoc,:);
        satLoc = satIdx(indLoc,:);
        cluLoc = cluIdx(indLoc,:);
        
        inXYZ(ii,:) = mean(xyzIdeal(indLoc,:));
        outXYZ(ii,:) = mean(xyzResult(indLoc,:));
        
        if all(lumLoc == lumLoc(1)) && all(satLoc == satLoc(1)) && all(cluLoc == cluLoc(1))
          outLum(ii) = lumLoc(1);
          outSat(ii) = satLoc(1);
          outClu(ii) = cluLoc(1);
        else
          outLum(ii) = -1;
          outSat(ii) = -1;
          outClu(ii) = -1;
        end
      end
      
      results(nt,nn).XYZ = XYZ;
      results(nt,nn).inXYZ = inXYZ;
      results(nt,nn).outXYZ = outXYZ;
      results(nt,nn).lum = outLum;
      results(nt,nn).sat = outSat;
      results(nt,nn).cluster = outClu;
      
    end
  end
  
  save(['results4/' listCameras(nc).name(1:end-4) '_results.mat'], 'results')
  
end
