%% s_imageReflectanceChart
%
%  Illustrate the creation of the natural reflectance test charts with a
%  gray scale strip.  Show how to use chartPatchData.
%
% Copyright Imageval LLC, 2014

%%
s_initISET

%% Make a reflectance chart and show it

% The XYZ values of the chart are in the scene.chartP structure

  whiteRGB = [1 1 1];
whiteXYZ = RGB2XWFormat(srgb2xyz(XW2RGBFormat(whiteRGB,1,1)));

  LABtest = [80 20 20];
  
  LABsamples = [];
  i = 0;
  while size(LABsamples,1)<100
    LAB = ones(200,1)*LABtest + sphereSampling(1,200);
    
    XYZ = RGB2XWFormat(lab2xyz(XW2RGBFormat(LAB,size(LAB,1),1),whiteXYZ));
    RGB = RGB2XWFormat(xyz2srgb(XW2RGBFormat(XYZ,size(XYZ,1),1)));
    XYZ2 = RGB2XWFormat(srgb2xyz(XW2RGBFormat(RGB,size(RGB,1),1)));
    LAB2 = RGB2XWFormat(xyz2lab(XW2RGBFormat(XYZ2,size(XYZ2,1),1),whiteXYZ));
    
    e = sqrt(sum((LAB-LAB2).^2,2));
    I = find(e < 1e-10,100-i);
    LABsamples = [LABsamples;LAB2(I,:)];
    i = i + length(I);
  end
  

scene = sceneCreate('reflectance chart custom',LABsamples);
vcAddObject(scene); 
sceneWindow;

% camera = cameraCreate('default');
load ../data/L3camera_CMY1_D65.mat;
camera = modifyCamera(camera,1);
sensorResize = 1;
oi     = cameraGet(camera,'oi');
sensor = cameraGet(camera,'sensor');
vci    = cameraGet(camera,'vci');

% Warn when FOV from scene and camera don't match
hfovScene     = sceneGet(scene,'fov horizontal');
hfovCamera    = sensorGet(sensor(1),'fov horizontal',scene,oi);
if sensorResize
  vfovScene = sceneGet(scene,'vfov');
  vfovCamera = sensorGet(sensor(1),'fov vertical',scene,oi);
  
  if abs((hfovScene - hfovCamera)/hfovScene) > 0.01 | ...
      abs((vfovScene - vfovCamera)/vfovScene) > 0.01
    
    % More than 1% off.  A little off because of
    % requirements for the CFA is OK.
    warning('ISET:Camera','Resizing sensor to match scene FOV (%.1f)',hfovScene);
    fov = [hfovScene,vfovScene];
    N = length(sensor);
    for ii=1:N
      sensor(ii) = sensorSetSizeToFOV(sensor(ii),fov,scene,oi);
    end
  end
end
% camera = cameraCompute(camera,scene,[],sensorResize);
[~, ~, ~, camera] = cameraComputesrgb(camera,scene,100,[],[],1,0);
cameraWindow(camera,'ip');

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

rectHandles = chartDrawRects(ip,mLocs,delta,'on'); pause(1);
chartDrawRects(ip,mLocs,delta,'off');

%% Color error analyses

% XYZ = mRGB*L
L = mRGB\XYZ;
estXYZ = mRGB*L;

vcNewGraphWin([],'tall'); 
subplot(2,1,1)
plot(XYZ(:),estXYZ(:),'o')
xlabel('True XYZ'); ylabel('Estimated XYZ');
grid on

% LAB comparisons
tmp = XW2RGBFormat(XYZ,r,c);
whiteXYZ = tmp(1,end,:);
cielab = xyz2lab(tmp,whiteXYZ);
cielab = RGB2XWFormat(cielab);

tmp = XW2RGBFormat(estXYZ,r,c);
whiteXYZ = tmp(1,end,:);
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
