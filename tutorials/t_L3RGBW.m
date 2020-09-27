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

%% Load oi data.  This way, we can have as many OIs as we want
fnames = {...
    fullfile(L3rootpath,'local','isetl3','RGBW_ois','suburb_v7.5_oi1.mat'), ...
    fullfile(L3rootpath,'local','isetl3','RGBW_ois','suburb_v13.5_oi2.mat'),...
    fullfile(L3rootpath,'local','isetl3','RGBW_ois','city4_v6.0_oi2.mat')};
oi = cell(size(fnames));

nScenes = length(fnames);
for ii = 1:nScenes
    load(fnames{ii},'ieObject');
    oi{ii} = ieObject;
    oi{ii} = oiSet(oi{ii}, 'mean illuminance', 20);
end

% ii = 3; oiWindow(oi{ii}); oiSet(oi{ii},'gamma',0.5);

%% compute sensor data for oi
thisSensor = cell(size(oi));
for ii=1:nScenes
    thisSensor{ii} = sensorCompute(sensor, oi{ii});
end
% ii = 3; sensorWindow(thisSensor{ii}); truesize;

%% 
voltMosaic = cell(size(oi));
for ii=1:nScenes
    voltMosaic{ii} = sensorGet(thisSensor{ii}, 'volts');
end

%%
cfa = [1 2; 3 4];
%%
min_cut = log10(20 * sensorGet(thisSensor{1}, 'pixel conversion gain'));
max_cut = log10(0.98 * sensorGet(thisSensor{1}, 'pixel voltage swing'));

%% Set the noise free function

%{
% This is another option but I think more lines of code are needed
% sensorNF = sensorCreateIdeal('matchxyz', sensor1);
% Let's make this do what we want.  Right now it returns 4 distinct
% sensors.  Not sure why rather than 3.
sensorNF = sensorCreateIdeal('match xyz',thisSensor{1});
xyzValue = sensorGet(sensorNF(2),'filter spectra');
vcNewGraphWin; plot(wave,xyzValue);
%}

sensorNF = thisSensor{1};
sensorNF = sensorSet(sensorNF, 'noise flag', -1);
wave = sensorGet(sensorNF, 'wave');
xyzValue = ieReadSpectra('XYZQuanta.mat', wave); % Here we need use Quanta.
xyzFilter = xyzValue / max(max(max(xyzValue)));

%{
    vcNewGraphWin;
    plot(xyzValue);
%}

%%  These are the ideal XYZ images

outImg = cell(size(oi));
for ii=1:nScenes
    outImg{ii} = sensorComputeFullArray(sensorNF, oi{ii}, xyzFilter);
end

% ii = 3; vcNewGraphWin; srgbImg = xyz2srgb(outImg{3}); imagescRGB(srgbImg);
    
%% Create the L3 camera

l3dRGBW2 = l3DataCamera(voltMosaic, outImg, cfa);

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
[X, y_pred, y_true] = l3ClassEvaluation(l3tRGBW2, ...
    thisClass, thisChannel, ...
    l3tRGBW2.l3c.patchSize);

%% Let's check a few more
ii = 1;

l3rRGBW = l3Render();
result  = l3rRGBW.render(voltMosaic{ii}, cfa, l3tRGBW2, false);
result  = xyz2srgb(result);

ip = ipCreate;
ip = ipSet(ip,'result',result);
[~,ipName] = fileparts(fnames{ii});
ip = ipSet(ip,'name',sprintf('%s',ipName));
ipWindow(ip);

%%  Could write out.

% rgb = ipGet(ip,'result');
% imwrite(rgb, 'rgbw.png');

%% END