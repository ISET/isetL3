function testClassifyParams(testCase)
% L3 Unittest: test parameters of l3ClassifyFast class
%
% To run this test, call
%    run(L3Test, 'testClassifyParams')
% 
% This function tests:
%   1) Initialize the l3ClassifyFast class
%   2) Set / get fundamental parameters
%   3) Classify with the settings
%   4) Get / set dependent parameters
%
% See also:
%   L3Test
%
% HJ, VISTA TEAM, 2016

% Initialize l3ClassifyFast class
l3c = l3ClassifyFast('name', 'test');
testCase.verifyEqual(l3c.name, 'test', 'initialize l3c name failed');

% Set parameters
l3c.patchSize = [1 1]; % using 1x1 patch
l3c.statFunc = {@(x, varargin) x(:)' + varargin{3}};
l3c.statNames = {'test stat func'};
l3c.statFuncParam = {{1}};
l3c.cutPoints = {1.1:0.1:1.9};
l3c.verbose = false;

testCase.verifyEqual(l3c.patchSize, [1 1], ...
    'Set l3ClassifyFast Param (patch size) Failed');
testCase.verifyEmpty(l3c.p_data, 'p_data should be init to empty');

% classify
nChannelOut = 2;
l3d = l3DataCamera({rand(100)}, {rand(100, 100, nChannelOut)}, 1);
labels = l3c.classify(l3d);

% check if patches get labels uniformly into 10 buckets
msg = 'Potential bugs in l3ClassifyFast.classify';
testCase.verifyEqual(unique(labels{1})', 1:10, msg);

% check if each bucket get the right patch
testCase.verifyLessThanOrEqual(cellfun(@max, l3c.p_data)', 0.1:0.1:1, msg);
testCase.verifyGreaterThan(cellfun(@min, l3c.p_data)', 0:0.1:0.9, msg);

% Check dependent variables
testCase.verifyEqual(l3c.nChannelOut, nChannelOut, ...
    'Unexpected Dependent variable value: nChannelOut');
testCase.verifyEqual(l3c.nLabels, 10, ...
    'Unexpected Dependent variable value: nLabels');
testCase.verifyEqual(l3c.nPixelTypes, 1, ...
    'Unexpected Dependent variable value: nPixelTypes');
testCase.verifyEqual(l3c.classCenters{1}(2:end-1), 1.15:0.1:1.85, ...
    'absTol', 1e-8, 'Unexpected Dependent variable value: classCenters');

end