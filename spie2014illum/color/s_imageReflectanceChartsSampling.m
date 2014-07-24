%% s_imageReflectanceChart
%
%  Illustrate the creation of the natural reflectance test charts with a
%  gray scale strip.  Show how to use chartPatchData.
%
% Copyright Imageval LLC, 2014

%%
close all;clear all;clc
s_initISET
addpath ../../functions

whiteRGB = [1 1 1];
whiteXYZ = RGB2XWFormat(srgb2xyz(XW2RGBFormat(whiteRGB,1,1)));

%% Make a reflectance chart and show it

% The XYZ values of the chart are in the scene.chartP structure

N = 10000;
LABtests = [];
i = 0;
while size(LABtests,1)<N
  LAB = rand(2*N,3)*diag([100,250,250]) - ones(2*N,1)*[0,125,125];
  
  XYZ = RGB2XWFormat(lab2xyz(XW2RGBFormat(LAB,size(LAB,1),1),whiteXYZ));
  RGB = RGB2XWFormat(xyz2srgb(XW2RGBFormat(XYZ,size(XYZ,1),1)));
  XYZ2 = RGB2XWFormat(srgb2xyz(XW2RGBFormat(RGB,size(RGB,1),1)));
  LAB2 = RGB2XWFormat(xyz2lab(XW2RGBFormat(XYZ2,size(XYZ2,1),1),whiteXYZ));
  
  e = sqrt(sum((LAB-LAB2).^2,2));
  I = find(e < 1e-10,N-i);
  LABtests = [LABtests;LAB2(I,:)];
  i = i + length(I);
end

meanDE = zeros(length(LABtests),1);
medDE = zeros(size(meanDE));
p75DE = zeros(size(meanDE));
p90DE = zeros(size(meanDE));
maxDE = zeros(size(meanDE));


for nt = 1:N/100
  
  LABtest = LABtests(nt,:);
  
  LABsamples = LABtests((nt-1)*100+1:nt*100,:);
  
  scene = sceneCreate('reflectance chart custom',LABsamples);
  scene = sceneAdjustLuminance(scene,60);
%   vcAddObject(scene); sceneWindow;
  
  % camera = cameraCreate('default');
  load ../data/L3camera_CMY1_Tungsten.mat;
  camera = modifyCamera(camera,3);
  sensorResize = 1;
%   [srgbResult, srgbIdeal, raw, camera] = cameraComputesrgb(camera,scene,scene.chartP.luminance,[],[],1,0);
  camera = cameraCompute(camera,scene,[],sensorResize);
%   [srgbResult, srgbIdeal, raw, camera] = cameraComputesrgb(camera,scene,60,[],[],1,0);
%   cameraWindow(camera,'ip');
  
  ip = cameraGet(camera,'ip');
  
  %% Collect up the chart ip data and the original XYZ
  
  % Use this to select by hand, say the chart is embedded in another image
  % cp = chartCornerpoints(ip);   % Corner points are (x,y) format
  
  % If the chart occupies the entire image, then cp can be the whole image
  %
  sz = imageGet(ip,'size');  % This could be a little routine.
cp(1,1) = 2;     cp(1,2) = sz(1)-30;
cp(2,1) = sz(2); cp(2,2) = sz(1)-30;
cp(3,1) = sz(2); cp(3,2) = 33;
cp(4,1) = 2;     cp(4,2) = 33;
  
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
  
%   rectHandles = chartDrawRects(ip,mLocs,delta,'on'); pause(1);
%   chartDrawRects(ip,mLocs,delta,'off');
  
  %% Color error analyses
  
  % XYZ = mRGB*L
  L = mRGB\XYZ;
  estXYZ = mRGB*L;
  
%   vcNewGraphWin([],'tall');
  subplot(2,1,1)
  plot(XYZ(:),estXYZ(:),'o')
  xlabel('True XYZ'); ylabel('Estimated XYZ');
  grid on
  
  % LAB comparisons
  tmp = XW2RGBFormat(XYZ,r,c);
  whiteXYZ = tmp(1,end,:);
  cielab = xyz2lab(tmp,whiteXYZ);
  cielab = RGB2XWFormat(cielab(:,1:end-1,:));
  
  tmp = XW2RGBFormat(estXYZ,r,c);
  whiteXYZ = tmp(1,end,:);
  estCielab = xyz2lab(tmp,whiteXYZ);
  estCielab = RGB2XWFormat(estCielab(:,1:end-1,:));
  
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
  subplot(2,1,1), image(xyz2srgb(XW2RGBFormat(XYZ,r,c)));
  subplot(2,1,2), image(xyz2srgb(XW2RGBFormat(estXYZ,r,c)));
  
  %% Error histogram
  vcNewGraphWin;
  dE = deltaEab(XYZ,estXYZ,5*XYZ(end,:));
  hist(dE,30);
  xlabel('\Delta E')
  ylabel('Count');
  v = sprintf('%.1f',mean(dE(:)));
  title(['Mean \Delta E ',v])
  
  %% End
  pause(1)
  close all
  
  meanDE(nt) = mean(dE(:));
  medDE(nt) = median(dE(:));
  p75DE(nt) = prctile(dE(:),75);
  p90DE(nt) = prctile(dE(:),90);
  maxDE(nt) = max(dE(:));
  
  
end
