%% s_L3Reflectance2Scene.mat
%
% This scripts converts L3 reflectance files to scenes.  
% 
% The script was written by SL and then modified by QT to adapt to the new
% scene format that has a separate 'illuminant' structure in a scene and
% photons are stored in floating point.
%
%
% (c) Stanford VISTA Team, Jan 2015

clear, clc, close all

%%

sNames = dir('*reflectance.mat');

for ss = 1:length(sNames)
    s = load(sNames(ss).name);
    sName = strrep(sNames(ss).name,'reflectance','scene'); 
    sceneFile = fullfile(L3rootpath,'data','scenes',sName);
    
    scene = sceneCreate;
    scene = sceneSet(scene,'name',sName);
    d65Energy = vcReadSpectra('D65',s.wave);
    d65Quanta = Energy2Quanta(s.wave(:),d65Energy(:));
    
    quanta = zeros(size(s.reflectances));
    for ii=1:length(s.wave)
        quanta(:,:,ii) = s.reflectances(:,:,ii)*d65Quanta(ii);
    end
    scene = sceneSet(scene,'wave',s.wave);
    scene = sceneSet(scene,'photons',quanta);
    scene = sceneSet(scene,'illuminant name','D65');
    scene = sceneSet(scene,'illuminant photons',d65Quanta);
    scene = sceneAdjustLuminance(scene,100);
    
    fullName = vcExportObject(scene,sceneFile);
    
end

vcAddAndSelectObject(scene); sceneWindow
