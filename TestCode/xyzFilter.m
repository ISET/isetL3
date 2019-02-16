%%
scene = sceneCreate('rings rays');
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
ip = ipCompute(ip, sensor);
% ipWindow(ip);
%%
ipImg = ipGet(ip, 'data srgb');

%%
l3dTmp = l3DataSuperResolution;
idealCMF = l3dTmp.idealCMF; idealCMF = idealCMF ./ max(max(max(idealCMF)));
xyzValue = ieReadSpectra('XYZQuanta.mat', wave); % Here we need use Quanta.
xyzFilter1 = xyzValue / max(max(max(xyzValue)));
xyzImg = sensorComputeFullArray(sensor, oi, xyzFilter1);

%%
vcNewGraphWin;
subplot(1, 2, 1); imshow(ipImg);
subplot(1, 2, 2); imshow(xyz2srgb(xyzImg));