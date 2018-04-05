function testTrainMethods(testCase)
% L3 Unittest: test for l3TrainOLS methods
%
% To run this test, call
%    run(L3Test, 'testTrainMethods')
% 
% This function tests:
%   1) copy method
%   2) save / load method
%   3) inspectKernels method
%   4) inspectCutPoints method
%
% See also:
%   L3Test
%
% HJ, VISTA TEAM, 2016

% Initialize l3TrainOLS class
l3t = l3TrainOLS('name', 'test');
testCase.verifyEqual(l3t.name, 'test', 'initialize l3t name failed');
l3t.verbose = false;
l3t.l3c.verbose = false;

% test copy method
l3t_copy = l3t.copy();
l3t_copy.p_min = 10;
l3t.p_min = 0; 
testCase.verifyEqual(l3t_copy.p_min, 10, 'Potential bugs in l3t.copy');

% set parameters
l3t.l3c.statNames = {'center value'};
l3t.l3c.statFunc = {@(x, varargin) x(:)'};
l3t.l3c.statFuncParam = {{}};
l3t.l3c.cutPoints = {-1};
l3t.l3c.patchSize = [1 1];
raw = rand(100); out = 2 * raw + 1;
l3t.train(l3DataCamera({raw}, {out}, 1));

% inspectCutPoints method
res = l3t.inspectCutPoints();
testCase.verifyEmpty(res{1}, 'Potential bugs in l3t.inspectCutPoints');

% inspectKernels method
res = l3t.inspectKernels();
testCase.verifyEqual(res, [0 1]', 'Potential bugs in l3t.inspectKernels'); 

% test save / load method
fname = [tempname '.mat'];
l3t.save(fname);
l3t_loaded = l3TrainS.load(fname);

testCase.verifyEqual(l3t.kernels{1}, l3t_loaded.kernels{1}, ...
    'Potential bugs in l3t.save / l3t.load');
delete(fname);

end