% s_convertSceneOI
%
% When we changed the format of the scene and oi structures from the
% dmin/dmax format to single() format, we may have old files containing the
% old format.
% This is the way to fix them.
%
% This shouldn't be needed very often because there aren't a lot of legacy
% files in my world.  But who knows, maybe people are saving their scenes
% as files.
%
%
% (c) Stanford VISTA Team, Jan 2015

clear, clc, close all

%% OLD FORMAT SCENE
sceneFileName = 'people_small_7_scene.mat';%fullfile(isetRootPath,'data','validate','sceneOldFormat.mat');
tmp = load(sceneFileName);
scene = tmp.scene;

% Create the right format
s = sceneCreate;
s = sceneSet(s,'wave',sceneGet(scene,'wave'));

% Uset the legacy uncompress to find the true photons 
photons = ieUncompressData(scene.data.photons,scene.data.dmin,scene.data.dmax,scene.data.bitDepth);

% Set them in the new format
s = sceneSet(s,'photons',photons);

% Copy the new data format over the old
scene.data = s.data;

% Now fix up the illuminant data to the new format
il = sceneGet(scene,'illuminant');
photons = ieUncompressData(il.data.photons,il.data.min,il.data.max,32);
illuminant = sceneGet(s,'illuminant');
illuminant = illuminantSet(illuminant,'photons',photons);
scene.illuminant = illuminant;

% This is the new scene.
%vcAddObject(scene); sceneWindow;

% Add another thing or two here.
%plotScene(scene,'illuminant photons');

save(sceneFileName,'scene');