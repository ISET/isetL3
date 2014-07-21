%% s_imageReflectanceChart
%
%  Illustrate the creation of the natural reflectance test charts with a
%  gray scale strip.  Show how to use chartPatchData.
%
% Copyright Imageval LLC, 2014

%%
close all;clear all;clc

mkdir scenes

s_initISET
addpath ../../functions

whiteRGB = [1 1 1];
whiteXYZ = RGB2XWFormat(srgb2xyz(XW2RGBFormat(whiteRGB,1,1)));

%% Make a reflectance chart and show it

% The XYZ values of the chart are in the scene.chartP structure

N = 100;
LABtests = [];
i = 0;
while size(LABtests,1)<N
  LAB = round(rand(3*N,3)*diag([100,250,250]) - ones(3*N,1)*[0,125,125]);
  LAB = unique(LAB,'rows');
  LAB = LAB(randperm(size(LAB,1)),:);
  
  XYZ = RGB2XWFormat(lab2xyz(XW2RGBFormat(LAB,size(LAB,1),1),whiteXYZ));
  RGB = RGB2XWFormat(xyz2srgb(XW2RGBFormat(XYZ,size(XYZ,1),1)));
  XYZ2 = RGB2XWFormat(srgb2xyz(XW2RGBFormat(RGB,size(RGB,1),1)));
  LAB2 = RGB2XWFormat(xyz2lab(XW2RGBFormat(XYZ2,size(XYZ2,1),1),whiteXYZ));
  
  e = sqrt(sum((LAB-LAB2).^2,2));
  I = find(e < 1e-10,N-i);
  LABtests = [LABtests;LAB2(I,:)];
  i = i + length(I);
end

meanDE = zeros(size(LABtests,1),1);
medDE = zeros(size(meanDE));
p75DE = zeros(size(meanDE));
p90DE = zeros(size(meanDE));
maxDE = zeros(size(meanDE));


for nt = 1:length(LABtests)
  
  LABtest = LABtests(nt,:);
  
  LABsamples = [];
  i = 0;
  whiteRGB = [1 1 1];
  whiteXYZ = RGB2XWFormat(srgb2xyz(XW2RGBFormat(whiteRGB,1,1)));

  while size(LABsamples,1)<100
    LAB = round(ones(500,1)*LABtest + sphereSampling(5,500));
    LAB = unique([LAB;LABsamples],'rows');
    LAB = LAB(randperm(size(LAB,1)),:);
    
    XYZ = RGB2XWFormat(lab2xyz(XW2RGBFormat(LAB,size(LAB,1),1),whiteXYZ));
    RGB = RGB2XWFormat(xyz2srgb(XW2RGBFormat(XYZ,size(XYZ,1),1)));
    XYZ2 = RGB2XWFormat(srgb2xyz(XW2RGBFormat(RGB,size(RGB,1),1)));
    LAB2 = RGB2XWFormat(xyz2lab(XW2RGBFormat(XYZ2,size(XYZ2,1),1),whiteXYZ));
    
    e = sqrt(sum((LAB-LAB2).^2,2));
    I = find(e < 1e-10,100-i);
    LABsamples = [LABsamples;LAB2(I,:)];
    i = i + length(I);
  end
  
  [~,I] = sort(LABsamples(:,1));
  LABsamples = LABsamples(I,:);
  
  scene = sceneCreate('reflectance chart custom',LABsamples);
  vcAddObject(scene);
  sceneWindow;
  save(sprintf('scenes/chart_L%+.0f_a%+.0f_b%+.0f.mat',LABtest(:,1),LABtest(:,2),LABtest(:,3)),'scene');
end
