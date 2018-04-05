function testClassifyMethods(testCase)
% L3 Unittest: test methods of l3ClassifyFast class
%
% To run this test, call
%    run(L3Test, 'testClassifyMethods')
% 
% This function tests:
%   1) l3ClassifyFast class initialization
%   2) copy method
%   3) getClassData method
%   4) clearData method
%   5) getClassCFA method
%   6) getLabelRange method
%   7) query method
%
% See also:
%   L3Test
%
% HJ, VISTA TEAM, 2016

% Initialize l3ClassifyFast class
l3c = l3ClassifyFast('name', 'test');
testCase.verifyEqual(l3c.name, 'test', 'initialize l3c name failed');

% Set parameters
l3c.patchSize = [5 3]; % using 3x1 patch
l3c.statFunc = {@(x, varargin) reshape(x(3:end-2, 2:end-1), 1, [])};
l3c.statNames = {'center value'};
l3c.statFuncParam = {{}};
l3c.cutPoints = {0.1:0.1:0.9};
l3c.verbose = false;

% classify
cfa = [1 2; 3 4];
l3c.classify(l3DataCamera({rand(100)}, {}, cfa));

% Test copy method
l3c_copy = l3c.copy();
l3c.name = 'original l3c';
testCase.verifyEqual(l3c_copy.name, 'test', 'initialize l3c name failed');

% Test getClassData method
[X, y] = l3c.getClassData(6);

msg = 'Potential bugs in getClassData';
testCase.verifyLessThanOrEqual(X(:, 8), 0.2, msg);
testCase.verifyGreaterThan(X(:, 8), 0.1, msg);
testCase.verifyEmpty(y, msg);

% Test getClassCFA method
pattern = l3c.getClassCFA(4, cfa);
testCase.verifyEqual(pattern(1:2, 1:2), [3 4; 1 2], ...
    'Potential bugs in getClassCFA');

% Test getLabelRange method
res = l3c.getLabelRange(5);
msg = 'Potential bugs in getLabelRange';
testCase.verifyEqual(res.label, 5, msg);
testCase.verifyEqual(res.pixeltype, 1, msg);
testCase.verifyEqual(res.(ieParamFormat(l3c.statNames{1})),[0.1 0.2],msg);

% Test query method
res = l3c.query('pixelType', 1);
testCase.verifyEqual(res, 1:4:l3c.nLabels, 'Potential bugs in l3c.query');

res = l3c.query('pixelType', 1, 'label', [24 28]);
testCase.verifyEqual(res, 25, 'Potential bugs in l3c.query');

res = l3c.query('pixelType', 1, 'label', [24 32], ...
    l3c.statNames{1}, [0.75 0.85]);
testCase.verifyEqual(res, 29, 'Potential bugs in l3c.query');

res = l3c.query('pixelType', 1, 'label', [24 32], ...
    'fhandle', @(x) ~isodd(10 * x.(ieParamFormat(l3c.statNames{1}))(1)));
testCase.verifyEqual(res, 25, 'Potential bugs in l3c.query');

% Test clearData method
l3c.clearData;
testCase.verifyEmpty(l3c.p_data{10}, 'Potential bugs in clearData');
testCase.verifyEmpty(l3c.p_out{1}, 'Potential bugs in clearData');

end