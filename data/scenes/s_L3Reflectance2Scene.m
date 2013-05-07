%% s_L3Reflectance2Scene - Convert L3 reflectance files to scenes
%
%
%
% (c) Stanford VISTA Team, 2012

sNames = dir('*reflectance.mat');

for ss = 1:length(sNames)
    s = load(sNames(ss).name);
    sName = strrep(sNames(ss).name,'reflectance','scene'); 
    sceneFile = fullfile(L3rootpath,'Data','Scenes',sName);
    
    scene = sceneCreate;
    scene = sceneSet(scene,'name',sName);
    d65Energy = vcReadSpectra('D65',s.wave);
    d65Quanta = Energy2Quanta(s.wave(:),d65Energy(:));
    
    quanta = zeros(size(s.reflectances));
    for ii=1:length(s.wave)
        quanta(:,:,ii) = s.reflectances(:,:,ii)*d65Quanta(ii);
    end
    scene = sceneSet(scene,'wave',s.wave);
    scene = sceneSet(scene,'cphotons',quanta);
    scene = sceneSet(scene,'illuminant energy',d65Energy);
    scene = sceneAdjustLuminance(scene,100);
    
    fullName = vcExportObject(scene,sceneFile);
    
end

vcAddAndSelectObject(scene); sceneWindow

%%