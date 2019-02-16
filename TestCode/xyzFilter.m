%%  Check the appearnace of two different sensors
%
%
% ZL

%%
ieInit

%%
scene = sceneCreate('rings rays');
scene = sceneCreate('uniform equal photon');

% sceneWindow(scene);
%%
oi = oiCreate;
oi = oiCompute(oi, scene);
% oiWindow(oi);
%%
sensor = sensorCreate;
sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'));

sensor = sensorCompute(sensor, oi);

%%
ip = ipCreate;
ip = ipSet(ip,'correction method illuminant', 'gray world');
ip = ipCompute(ip, sensor);
ip = ipSet(ip,'name','RGB');

% ipWindow(ip);
%%
ipImg = ipGet(ip, 'data srgb');

%%  Now, let's try to make an image based an XYZ sesnsor

wave = sensorGet(sensor,'wave');

xyzValue = ieReadSpectra('XYZQuanta.mat', wave); % Here we need use Quanta.
xyzF = xyzValue / max(max(max(xyzValue)));
% vcNewGraphWin; plot(wave,xyzF);
sensorXYZ = sensorSet(sensor,'filter spectra',xyzF);
sensorXYZ = sensorCompute(sensorXYZ, oi);

sensorWindow(sensorXYZ);

%%
ipXYZ = ipCompute(ip, sensorXYZ);
ipXYZ = ipSet(ipXYZ,'name','XYZ');

ipWindow(ipXYZ);

%%

% l3dTmp = l3DataSuperResolution;
% idealCMF = l3dTmp.idealCMF; idealCMF = idealCMF ./ max(max(max(idealCMF)));

xyzImg = sensorComputeFullArray(sensor, oi, xyzF);

%%
vcNewGraphWin;
subplot(1, 2, 1); imshow(ipImg);
subplot(1, 2, 2); imshow(xyz2srgb(xyzImg));

