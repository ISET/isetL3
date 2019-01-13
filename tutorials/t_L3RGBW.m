%% Demonstrate L3 using an RGBW sensor, all the way to the IP window
%
% Dependencies:
%   To run this script you must download the data ZL prepared. We assume
%   you have placed the code in fullfile(L3rootpath,'local');
%
% Zheng Lyu, SCIEN Team, 2019

%% initialization
ieInit;

%%
patch_sz = [5 5];

%% Load RGBW sensor
fname = fullfile(L3rootpath,'local','isetl3','RGBW_sensor','rgbw1_sensor');
load(fname,'sensor'); 

%% Load oi data
fname = fullfile(L3rootpath,'local','isetl3','RGBW_ois','suburb_v7.5_oi1.mat');
load(fname,'ieObject'); 
oi1 = ieObject;

fname = fullfile(L3rootpath,'local','isetl3','RGBW_ois','suburb_v13.5_oi2.mat');
load(fname,'ieObject'); 
oi2 = ieObject;

fname = fullfile(L3rootpath,'local','isetl3','RGBW_ois','city4_v6.0_oi2.mat');
load(fname,'ieObject'); 
oi3 = ieObject;

% oiWindow(oi3); oiSet(oi3,'gamma',0.5);

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

%%  These are the ideal XYZ images

outImg1 = sensorComputeFullArray(sensorNF, oi1, xyzFilter);
outImg2 = sensorComputeFullArray(sensorNF, oi2, xyzFilter);
outImg3 = sensorComputeFullArray(sensorNF, oi3, xyzFilter);
%{
    vcNewGraphWin; srgbImg1 = xyz2srgb(outImg1); imagesc(srgbImg1);
    vcNewGraphWin; srgbImg2 = xyz2srgb(outImg2); imagesc(srgbImg2);
    vcNewGraphWin; srgbImg3 = xyz2srgb(outImg3); imagesc(srgbImg3);
%}
%% Create the L3 camera

l3dRGBW2 = l3DataCamera({voltMosaic1, voltMosaic2, voltMosaic3}, ...
    {outImg1, outImg2, outImg3},...
    cfa);
%% Train

l3tRGBW2 = l3TrainRidge();
l3tRGBW2.l3c.patchSize = patch_sz;
l3tRGBW2.l3c.satClassOption = 'none';

l3tRGBW2.l3c.cutPoints = {logspace(min_cut, max_cut, 40), []};                  
l3tRGBW2.train(l3dRGBW2);
%% Now check the linearity of the trained class

% Pick a class and channel
thisClass = 30;
thisChannel = 1;

% Make the plot
[X, y_pred, y_true] = checkLinearFit(l3tRGBW2, ...
    thisClass, thisChannel, ...
    l3tRGBW2.l3c.patchSize);

%% Let's check a few more
l3rRGBW = l3Render();
outImg  = l3rRGBW.render(voltMosaic1, cfa, l3tRGBW2, false);
outImg  = xyz2srgb(outImg);

ip = ipCreate;
ip = ipSet(ip,'result',outImg);
ip = ipSet(ip,'name','Mosaic 1');
ipWindow(ip);

%%
imwrite(outImg, 'rgbw.png');

%% END