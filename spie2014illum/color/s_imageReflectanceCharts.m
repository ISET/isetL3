%% s_imageReflectanceChart
%
%  Illustrate the creation of the natural reflectance test charts with a
%  gray scale strip.  Show how to use chartPatchData.
%
% Copyright Imageval LLC, 2014

%%
% close all;clear all;clc
s_initISET

%% Make a reflectance chart and show it

% The XYZ values of the chart are in the scene.chartP structure

listScenes = dir('scenes/*.mat');
listCameras = dir('../data/L3camera*.mat');

% listScenes = [listScenes(1) listScenes(end)];

N = length(listScenes);
C = length(listCameras);

mkdir('results')

for nc = 1:C
  
  disp(listCameras(nc).name)
  results = repmat(struct('XYZ',[],'estXYZ',[],'cielab',[],'estCielab',[]),N,1);
  
  k = strfind(listCameras(nc).name,'_');
  illum = listCameras(nc).name(k(end)+1:end-4);
  
  for nt = 1:N
    
    disp(listScenes(nt).name)
    load(['../data/' listCameras(nc).name],'camera')
    camera = modifyCamera(camera,3);
    load(['scenes/' listScenes(nt).name],'scene')
    
    scene = sceneAdjustIlluminant(scene,[illum,'.mat']);
    
    %   scene = sceneCreate('reflectance chart');
    %   scene = sceneAdjustLuminance(scene,200);
%     vcAddObject(scene); sceneWindow;
    
    [luminance,meanLuminance] = sceneCalculateLuminance(scene);
    targetLuminance = 100*meanLuminance/luminance(1,end);
        
    sensorResize = 1;
    sz = sceneGet(scene,'size')
    %   [srgbResult, srgbIdeal, raw, camera] =...
    %   cameraComputesrgb(camera,scene,scene.chartP.luminance,[],[],1,0);
      [srgbResult, srgbIdeal, raw, camera] =...
      cameraComputesrgb(camera,scene,targetLuminance,sz,[],1,2);
%     camera = cameraCompute(camera,scene,[],sensorResize);
    cameraWindow(camera,'ip');
    
    ip = cameraGet(camera,'ip');
    
    %% Collect up the chart ip data and the original XYZ
    
    % Use this to select by hand, say the chart is embedded in another image
    % cp = chartCornerpoints(ip);   % Corner points are (x,y) format
    
    % If the chart occupies the entire image, then cp can be the whole image
    %
    sz = imageGet(ip,'size');  % This could be a little routine.
    cp(1,1) = 2;     cp(1,2) = sz(1);
    cp(2,1) = sz(2); cp(2,2) = sz(1);
    cp(3,1) = sz(2); cp(3,2) = 2;
    cp(4,1) = 2;     cp(4,2) = 2;
    
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
    
    rectHandles = chartDrawRects(ip,mLocs,delta,'on'); pause(1);
    chartDrawRects(ip,mLocs,delta,'off');
    
    %% Color error analyses
    
    % XYZ = mRGB*L
    L = mRGB\XYZ;
    estXYZ = mRGB*L;
    
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
%     vcNewGraphWin([],'tall');
    figure
    subplot(2,1,1), image(xyz2srgb(XW2RGBFormat(XYZ,r,c)));
    subplot(2,1,2), image(xyz2srgb(XW2RGBFormat(estXYZ,r,c)));
    
    results(nt).XYZ = XYZ;
    results(nt).estXYZ = estXYZ;
    results(nt).cielab = cielab;
    results(nt).estCielab = estCielab;
    
%     %% Error histogram
    figure
%     vcNewGraphWin;
    dE = deltaEab(XYZ,estXYZ,5*XYZ(end,:));
    hist(dE,30);
    xlabel('\Delta E')
    ylabel('Count');
    v = sprintf('%.1f',mean(dE(:)));
    title(['Mean \Delta E ',v])
    
    %% End
    pause(1)
    close all

  end

  save(['results/' listCameras(nc).name(1:end-4) '_results.mat'], 'results')
  
end
