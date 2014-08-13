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

load LABfeasible5

whiteSRGB = srgb2xyz(XW2RGBFormat([1 1 1],1,1));

SRGBfeasible = [];
RefSRGBfeasible = [];

for i = 1:size(LABfeasible,1)
  LAB = XW2RGBFormat(LABfeasible(i,:),1,1);
  XYZ = lab2xyz(LAB,whiteSRGB);
  SRGB = xyz2srgb(XYZ);
  XYZ = srgb2xyz(SRGB);
  LAB2 = xyz2lab(XYZ,whiteSRGB);
  if norm(LAB(:)-LAB2(:)) < 1e-6
    SRGBfeasible = [SRGBfeasible;LABfeasible(i,:)];
    RefSRGBfeasible = [RefSRGBfeasible;Reffeasible(i,:)];
  end
end

save SRGBfeasible5 SRGBfeasible RefSRGBfeasible