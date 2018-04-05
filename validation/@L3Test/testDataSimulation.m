function testDataSimulation(testCase)
% L3 Unittest: test for l3DataSimulation class
%
% To run this test, call
%    run(L3Test, 'testDataSimulation')
% 
% This function tests:
%   1) Initialize the l3DataSimulation class
%   2) Setting parameters
%   3) Computing with scenes
%   4) Computing with OI
%   5) Computing with custom scene / oi
%
% See also:
%   L3Test
%
% HJ, VISTA TEAM, 2016

% Initialize l3DataCamera class
l3d = l3DataSimulation('name', 'test');
testCase.verifyInstanceOf(l3d, 'l3DataS');
testCase.verifyEqual(l3d.name, 'test');

% Set parameters
l3d.camera = cameraSet(l3d.camera, 'pixel size constant fill factor', 2e-6);
testCase.verifyEqual(cameraGet(l3d.camera, 'pixel size'), [2 2]*1e-6, ...
    'Camera parameter set failed in l3DataSimulation');

l3d.expFrac = [1 0.1];
testCase.verifyEqual(l3d.expFrac, [1 0.1], 'Parameter set failed');

l3d.verbose = false;

% Compute with scenes
l3d.sources = l3d.loadSources(1, 'scene');
[in, out, ~] = l3d.dataGet(1, true);
testCase.verifyNumElements(in, 2, 'Unexpected number of data returned');
testCase.verifyNumElements(out, 2, 'Unexpected number of data returned');

% Compute with oi
l3d.sources = l3d.loadSources(1, 'oi');
l3d.sources{1} = oiSet(l3d.sources{1}, 'optics f length', 0.01);
[in, out, ~] = l3d.dataGet(1, true);
testCase.verifyNumElements(in, 2, 'Unexpected number of data returned');
testCase.verifyNumElements(out, 2, 'Unexpected number of data returned');

% Compute with custom scene / oi
scene = sceneCreate;
oi = oiCompute(scene, cameraGet(l3d.camera, 'oi'));
l3d.sources = {scene, oiCompute(scene, oi)};

[in, out, ~] = l3d.dataGet(2, true);
errMsg = 'Mismatch between scene and oi, potential bug in l3DataSimutaion';
testCase.verifyEqual(double(in{1}), double(in{3}), 'absTol', 0.18, errMsg);
testCase.verifyEqual(out{2}, out{4}, 'absTol', 1e-10, errMsg);

end