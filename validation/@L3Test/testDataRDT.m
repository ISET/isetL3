function testDataRDT(testCase)
% L3 Unittest: loading data using remote data toolbox
%
% To run this test, call
%    run(L3Test, 'testDataRDT')
% 
% This function tests:
%   1) loading Nikon camera image pairs
%   2) loading faces scene data
%   3) loading sythetic OI data
%   4) loading multispectral data
%
% See also:
%   L3Test
%
% HJ, VISTA TEAM, 2016

% Init remote data toolbox
rdt = RdtClient('scien');
rdt.crp('/L3/Farrell/D200/garden');
s = rdt.searchArtifacts('dsc_', 'type', 'pgm');
testCase.verifyNotEmpty(s, 'Nikon camera data not found');

% Load Nikon image pairs
raw = rdt.readArtifact(s(1).artifactId, 'type', 'pgm');
rgb = rdt.readArtifact(s(1).artifactId, 'type', 'jpg');
testCase.verifyEqual(size(raw), [2592 3872], 'Unexpected raw size');
testCase.verifyEqual(size(rgb), [2592 3872 3], 'Unexpected jpeg size');

% Load faces scenes
scene = rdtScenesLoad('nScenes', 1);
testCase.verifyEqual(length(scene), 1, 'Bugs in rdtSceneLoad');
testCase.verifyEqual(scene{1}.type, 'scene', 'Unexpected data type');

% Load sythetic optical images
oi = rdtOILoad('nOI', 1);
testCase.verifyEqual(length(oi), 1, 'Bugs in rdtOILoad');
testCase.verifyEqual(oi{1}.type, 'opticalimage', 'Unexpected oi type');

% Load multispectral scene
rdt = RdtClient('isetbio');
rdt.crp('/resources/scenes/hyperspectral/stanford_database');
s = rdt.listArtifacts;

testCase.verifyNotEmpty(s, 'No hyperspectral data found');

end