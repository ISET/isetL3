function testClassify(testCase)
% L3 Unittest: test for l3ClassifyFast.classify method
%
% To run this test, call
%    run(L3Test, 'testClassify')
% 
% This function tests:
%   1) Initialize the l3ClassifyFast class
%   2) Setting parameters
%   3) Classify random data using 1x1 patch
%   4) Test classify using data kernels
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
l3c.statFunc = {@(x, varargin) x(:)'};
l3c.statNames = {'test stat func'};
l3c.statFuncParam = {{}};
l3c.cutPoints = {0.1:0.1:0.9};
l3c.verbose = false;

% classify
l3d = l3DataCamera({rand(100)}, {}, 1);
labels = l3c.classify(l3d);

% check if patches get labels uniformly into 10 buckets
msg = 'Potential bugs in l3ClassifyFast.classify';
testCase.verifyEqual(unique(labels{1})', 1:10, msg);

% check if each bucket get the right patch
testCase.verifyLessThanOrEqual(cellfun(@max, l3c.p_data)', 0.1:0.1:1, msg);
testCase.verifyGreaterThan(cellfun(@min, l3c.p_data)', 0:0.1:0.9, msg);

% test classify using data kernels
l3c.dataKernel = @(x) x.^2;
labels = l3c.classify(l3d, true);

% check if patches get labels uniformly into 10 buckets
msg = 'Potential bugs in l3ClassifyFast.classify';
testCase.verifyEqual(unique(labels{1})', 1:10, msg);

% check if each bucket get the right patch
testCase.verifyLessThanOrEqual(cellfun(@max, l3c.p_data)', ...
    (0.1:0.1:1).^2, msg);
testCase.verifyGreaterThan(cellfun(@min, l3c.p_data)', ...
    (0:0.1:0.9).^2, msg);

end