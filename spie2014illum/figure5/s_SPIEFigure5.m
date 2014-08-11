%% s_imageReflectanceChart
%
%  Illustrate the creation of the natural reflectance test charts with a
%  gray scale strip.  Show how to use chartPatchData.
%
% Copyright Imageval LLC, 2014

%%
clear all, clc, close all
s_initISET

%% Make a reflectance chart and show it

% The XYZ values of the chart are in the scene.chartP structure

scene = sceneCreate('default');
vcAddObject(scene); 
sceneWindow;

% camera = cameraCreate('default');
load ../data/L3camera_RGBW_Tungsten.mat;
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
[~, ~, ~, camera] = cameraComputesrgb(camera,scene,80,[],[],1,0);
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
cp(1,2) = 184;  cp(1,1) = 3;
cp(2,2) = 184; cp(2,1) = 239;
cp(3,2) = 24; cp(3,1) = 239;
cp(4,2) = 24;  cp(4,1) = 3;

r = 4; c = 6;
[mLocs,pSize] = chartRectanglesFG(cp,r,c);
delta = round(min(pSize)/2);   % Central portion of the patch

rectHandles = chartDrawRects(ip,mLocs,delta,'on'); pause(1);
chartDrawRects(ip,mLocs,delta,'off'); pause(1);
[macbethLAB, macbethXYZ, dE, ip] = macbethColorError(ip,'D65',cp);

