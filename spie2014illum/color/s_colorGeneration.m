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


%% Make a reflectance chart and show it

% Default scene
scene = sceneCreate;
wave = sceneGet(scene,'wave');

nWave = length(wave);
defaultLuminance = 100;  % cd/m2

reflectance = zeros(nWave,1);

% Convert the scene reflectances into photons assuming an equal energy
% illuminant.
ee         = ones(nWave,1);           % Equal energy vector
e2pFactors = Energy2Quanta(wave,ee);  % Energy to photon factor

% Illuminant
illuminantPhotons = diag(e2pFactors)*ones(nWave,1);
dWave = wave(2) - wave(1);

S = ieReadSpectra('XYZ',wave);
whiteXYZ = 683*dWave*(S'*ee);

LABfeasible = [];
Reffeasible = [];

for l = 0:100
  
  [L,a,b] = meshgrid(l,-200:200,-200:200);
  LABsamples = [L(:),a(:),b(:)];
  nSamples = size(LABsamples,1);
  LABflag = zeros(nSamples,1);
  
  XYZtarget = RGB2XWFormat(lab2xyz(XW2RGBFormat(LABsamples,nSamples,1),whiteXYZ));
  sData = zeros(nSamples,1,nWave);
  
  for idx=1:nSamples
    clc
    disp(LABsamples(idx,:));
    [eData,~,~,exitflag] = lsqlinFG(eye(nWave),zeros(nWave,1),[],[],683*dWave*S',XYZtarget(idx,:)',zeros(nWave,1),ones(nWave,1));
    %   [eData,~,~,exitflag] = quadprog(eye(nWave),zeros(nWave,1),[],[],683*dWave*S',XYZtarget(idx,:)',zeros(nWave,1),ones(nWave,1));
    LABflag(idx) = (exitflag == 1);
    
    sData(idx,1,:) = Energy2Quanta(wave,eData);
    reflectance(:,idx) = diag(e2pFactors)\squeeze(sData(idx,1,:));
  end
  
  LABfeasible = [LABfeasible;LABsamples(LABflag,:)];

end

save LABfeasible LABfeasible
% XYZresult = RGB2XWFormat(ieXYZFromPhotons(sData,wave));
