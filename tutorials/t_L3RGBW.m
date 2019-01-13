%% Function to demonstrate the RGBW sensor ip

%% initialization
ieInit;

%%
patch_sz = [5 5];

%% Load RGBW sensor
data = load('rgbw1_sensor.mat'); sensor = data.sensor;

%% read oi
data = load('suburb_v7.5_oi1.mat'); oi1 = data.ieObject;
data = load('suburb_v13.5_oi2.mat'); oi2 = data.ieObject;

data = load('city4_v6.0_oi2.mat'); oi3 = data.ieObject;
%% change the illuminance
oi1 = oiSet(oi1, 'mean illuminance', 20);
oi2 = oiSet(oi2, 'mean illuminance', 20);
oi3 = oiSet(oi3, 'mean illuminance', 20);
%{
    oiWindow(oi1);
    oiWindow(oi2);
    oiWindow(oi3);
%}
%% compute sensor data for oi
sensor1 = sensorCompute(sensor, oi1);
sensor2 = sensorCompute(sensor, oi2);
sensor3 = sensorCompute(sensor, oi3);
%% 
voltMosaic1 = sensorGet(sensor1, 'volts');
voltMosaic2 = sensorGet(sensor2, 'volts');
voltMosaic3 = sensorGet(sensor3, 'volts');
%{
    sensorWindow(sensor1);
    sensorWindow(sensor2);
    sensorWindow(sensor3);
%}
%%
cfa = [1 2; 3 4];
%%
min_cut = log10(20 * sensorGet(sensor1, 'pixel conversion gain'));
max_cut = log10(0.98 * sensorGet(sensor1, 'pixel voltage swing'));
%% Set the noise free function
sensorNF = sensor1;
sensorNF = sensorSet(sensorNF, 'noise flag', -1);
wave = sensorGet(sensorNF, 'wave');
xyzValue = ieReadSpectra('XYZQuanta.mat', wave); % Here we need use Quanta.
xyzFilter = xyzValue / max(max(max(xyzValue)));
%{
    vcNewGraphWin;
    plot(xyzValue);
%}
%% This is another option but I think more lines of code are needed
% sensorNF = sensorCreateIdeal('matchxyz', sensor1);

%%
outImg1 = sensorComputeFullArray(sensorNF, oi1, xyzFilter);
outImg2 = sensorComputeFullArray(sensorNF, oi2, xyzFilter);
outImg3 = sensorComputeFullArray(sensorNF, oi3, xyzFilter);
%{
    vcNewGraphWin; srgbImg1 = xyz2srgb(outImg1); imagesc(srgbImg1);
    vcNewGraphWin; srgbImg2 = xyz2srgb(outImg2); imagesc(srgbImg2);
    vcNewGraphWin; srgbImg3 = xyz2srgb(outImg3); imagesc(srgbImg3);
%}
%%
l3dRGBW2 = l3DataCamera({voltMosaic1, voltMosaic2, voltMosaic3}, {outImg1, outImg2, outImg3},...
                      cfa); 
%%
l3tRGBW2 = l3TrainRidge();
l3tRGBW2.l3c.patchSize = patch_sz;
l3tRGBW2.l3c.satClassOption = 'none';

l3tRGBW2.l3c.cutPoints = {logspace(min_cut, max_cut, 40), []};                  
l3tRGBW2.train(l3dRGBW2);
%% Now check the linearity of the trained class
thisClass = 50;
thisChannel = 1;

[X, y_pred, y_true] = checkLinearFit(l3tRGBW2, thisClass, thisChannel, l3tRGBW2.l3c.patchSize);


%%
l3rRGBW = l3Render();
outImg = l3rRGBW.render(voltMosaic1, cfa, l3tRGBW2, false);
outImg = xyz2srgb(outImg);

vcNewGraphWin;
imshow(outImg); title('L3 Rendered Image');

%%
imwrite(outImg, 'rgbw.png');