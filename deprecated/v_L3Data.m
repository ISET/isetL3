% v_l3Data
%
% Testing the ISET data object, reading the scenes for training
% 
% HJ/BW Vistasoft Team, 2015

%% Testing l3DataISET version

l3D = l3DataISET;

l3D.get('n scenes')
l3D.get('camera')

%% Getting load data
s = l3D.get('scenes', [1 3]);
vcAddObject(s{1}); sceneWindow;

%% Compute training data
[inImg, outImg, pType] = l3D.dataGet();

%% Load remotely from scarlet, the same two scenes
url = 'http://scarlet.stanford.edu/validation/SCIEN/L3/people_small';
sList = {fullfile(url,'people_small_1_scene.mat'),fullfile(url,'people_small_3_scene.mat')};
l3D.scenesLoad(sList); % Everytime we change camera or scenes, we have to check FOV and wavelength consistency
s = l3D.get('scenes',1);

% Should be the same scene as above
vcAddObject(1); sceneWindow;

%% END